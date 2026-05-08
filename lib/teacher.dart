import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'data.dart';
import 'timetable.dart';

// Function to load teachers.csv into teacherData using file picker
Future<List<List<String>>> loadTeacherData() async {
  try {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String data = await file.readAsString();
      List<List<String>> teacherData = [];
      List<String> lines = data.split('\n');
      // Skip header
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isNotEmpty) {
          List<String> row = _parseCsvLine(lines[i]);
          if (row.length >= 2) {
            teacherData.add([row[0], row[1]]);
            print('Loaded teacher: ${row[0]}, Subjects: ${row[1]}'); // Debug print
          }
        }
      }
      return teacherData;
    }
    print('No file selected');
    return [];
  } catch (e) {
    print('Error loading CSV: $e');
    return [];
  }
}

// Helper function to parse CSV line, preserving commas in subjects
List<String> _parseCsvLine(String line) {
  List<String> result = [];
  int firstCommaIndex = line.indexOf(',');
  if (firstCommaIndex == -1) {
    return [line.trim(), ''];
  }
  String teacherName = line.substring(0, firstCommaIndex).trim();
  String subjects = line.substring(firstCommaIndex + 1).trim();
  result.add(teacherName);
  result.add(subjects);
  return result;
}



void assignTeachersToClasses(List<List<String>> teacherData) {
  for (int i = 0; i < sectimetable.length; i++) {
    sectimetable[i].removeTeacher();
  }
  for (int i = 0; i < roomtimetable.length; i++) {
    roomtimetable[i].removeTeacher();
  }
  teachertimetable = []; // Clear existing teacher timetable

  Map<String, String> teacherSubjectSection = {};

  for (var teacher in teacherData) {
    String teacherName = teacher[0];
    List<String> subjects = teacher[1].split(',').map((s) => s.trim().toLowerCase()).toList();
    Timetable teacherTimetable = Timetable();

    for (int sectionIndex = 0; sectionIndex < sectimetable.length; sectionIndex++) {
      var section = sectimetable[sectionIndex];
      for (String subject in subjects) {
        // Collect all slots for this subject in this section
        List<Map<String, int>> subjectSlots = [];
        for (int day = 0; day < totaldays; day++) {
          for (int slotIndex = 0; slotIndex < totalslots; slotIndex++) {
            var slot = section.slot[day][slotIndex];
            if (!slot.isEmpty && slot.subject.toLowerCase() == subject) {
              subjectSlots.add({
                'sectionIndex': sectionIndex,
                'day': day,
                'slotIndex': slotIndex,
              });
            }
          }
        }

        // Check if teacher can cover all slots without conflicts
        bool canAssignAll = true;
        for (var slotInfo in subjectSlots) {
          int sectionIndex = slotInfo['sectionIndex']!;
          int day = slotInfo['day']!;
          int slotIndex = slotInfo['slotIndex']!;
          for (var t in teachertimetable) {
            if (t.slot[day][slotIndex].teacher == teacherName && !t.slot[day][slotIndex].isEmpty) {
              canAssignAll = false;
              break;
            }
          }
          for (var s in sectimetable) {
            if (s.slot[day][slotIndex].teacher == teacherName && !s.slot[day][slotIndex].isEmpty) {
              canAssignAll = false;
              break;
            }
          }
          for (var r in roomtimetable) {
            if (r.slot[day][slotIndex].teacher == teacherName && !r.slot[day][slotIndex].isEmpty) {
              canAssignAll = false;
              break;
            }
          }
          if (!canAssignAll) break;
        }

        // Try alternative slots if conflicts exist
        if (!canAssignAll) {
          List<Map<String, int>> newSlots = [];
          bool allValid = true;
          for (var slotInfo in subjectSlots) {
            int sectionIndex = slotInfo['sectionIndex']!;
            int day = slotInfo['day']!;
            int slotIndex = slotInfo['slotIndex']!;
            Slot slot = sectimetable[sectionIndex].slot[day][slotIndex];
            bool conflict = false;
            for (var r in roomtimetable) {
              if (r.slot[day][slotIndex].teacher == teacherName && !r.slot[day][slotIndex].isEmpty) {
                conflict = true;
                break;
              }
            }
            for (var t in teachertimetable) {
              if (t.slot[day][slotIndex].teacher == teacherName && !t.slot[day][slotIndex].isEmpty) {
                conflict = true;
                break;
              }
            }
            for (var s in sectimetable) {
              if (s.slot[day][slotIndex].teacher == teacherName && !s.slot[day][slotIndex].isEmpty) {
                conflict = true;
                break;
              }
            }


            int newSlotIndex = slotIndex;
            if (conflict) {
              newSlotIndex = findAlternativeSlot(sectionIndex, day, slotIndex, teacherName, subjects, slot);
              if (newSlotIndex == -1) {
                allValid = false;
                break;
              }
              // Clear original slot in sectimetable and roomtimetable
              sectimetable[sectionIndex].slot[day][slotIndex].clear();
              int roomIndex = slot.room - 1;
              if (roomIndex >= 0 && roomIndex < totalrooms) {
                roomtimetable[roomIndex].slot[day][slotIndex].clear();
              }
            }
            newSlots.add({
              'sectionIndex': sectionIndex,
              'day': day,
              'slotIndex': newSlotIndex,
            });
          }

          if (allValid) {
            String key = '${section.dept}_${section.section}_${subject}';
            if (!teacherSubjectSection.containsKey(key) || teacherSubjectSection[key] == teacherName) {
              for (var newSlot in newSlots) {
                int sectionIndex = newSlot['sectionIndex']!;
                int day = newSlot['day']!;
                int newSlotIndex = newSlot['slotIndex']!;
                assignSlot(teacherTimetable, sectionIndex, day, newSlotIndex, teacherName);
              }
              teacherSubjectSection[key] = teacherName;
            }
          } else {
            warnings.add('Could not assign $subject for ${section.dept} ${section.section} to $teacherName');
          }
        } else {
          // Assign all slots if no conflicts
          String key = '${section.dept}_${section.section}_${subject}';
          if (!teacherSubjectSection.containsKey(key) || teacherSubjectSection[key] == teacherName) {
            for (var slotInfo in subjectSlots) {
              int sectionIndex = slotInfo['sectionIndex']!;
              int day = slotInfo['day']!;
              int slotIndex = slotInfo['slotIndex']!;
              assignSlot(teacherTimetable, sectionIndex, day, slotIndex, teacherName);
            }
            teacherSubjectSection[key] = teacherName;
          }
        }
      }
    }

    teachertimetable.add(teacherTimetable);
  }
}

void assignSlot(Timetable teacherTimetable, int sectionIndex, int day, int slotIndex, String teacherName) {
  // Use sectimetable[sectionIndex] for dept and section to ensure valid values
  Slot sourceSlot = sectimetable[sectionIndex].slot[day][slotIndex];
  String dept = sectimetable[sectionIndex].dept ?? sourceSlot.dept ?? '';
  int section = sectimetable[sectionIndex].section ?? sourceSlot.section ?? 0;

  // Copy slot data to teachertimetable
  teacherTimetable.dept = teacherName;
  teacherTimetable.slot[day][slotIndex] = Slot()
    ..dept = dept
    ..section = section
    ..room = sourceSlot.room ?? 0
    ..subject = sourceSlot.subject ?? ''
    ..teacher = teacherName
    ..isEmpty = false;

  // Update sectimetable with the same slot data and new teacher
  sectimetable[sectionIndex].slot[day][slotIndex] = Slot()
    ..dept = dept
    ..section = section
    ..room = sourceSlot.room ?? 0
    ..subject = sourceSlot.subject ?? ''
    ..teacher = teacherName
    ..isEmpty = false;

  // Update roomtimetable with the same slot data and new teacher
  int roomIndex = (sourceSlot.room ?? 1) - 1;
  if (roomIndex >= 0 && roomIndex < totalrooms) {
    roomtimetable[roomIndex].slot[day][slotIndex] = Slot()
      ..dept = dept
      ..section = section
      ..room = sourceSlot.room ?? 0
      ..subject = sourceSlot.subject ?? ''
      ..teacher = teacherName
      ..isEmpty = false;
  }

  // Debug to verify dept and section
  print("Assigned slot: dept=$dept, section=$section, subject=${sourceSlot.subject}, teacher=$teacherName, day=$day, slot=$slotIndex");
}

int findAlternativeSlot(int sectionIndex, int day, int originalSlot, String teacherName, List<String> subjects, Slot slot) {
  Timetable section = sectimetable[sectionIndex];
  List<int> subjectSlots = [];
  for (int s = 0; s < totalslots; s++) {
    if (!section.slot[day][s].isEmpty && subjects.contains(section.slot[day][s].subject.toLowerCase())) {
      subjectSlots.add(s);
    }
  }

  for (int offset = 1; offset <= totalslots; offset++) {
    for (int sign = -1; sign <= 1; sign += 2) {
      int newSlot = originalSlot + sign * offset;
      if (newSlot >= 0 && newSlot < totalslots) {
        // Check if new slot is empty in all timetables
        bool isEmpty = section.slot[day][newSlot].isEmpty;
        for (var s in sectimetable) {
          if (s != section && !s.slot[day][newSlot].isEmpty) {
            isEmpty = false;
            break;
          }
        }
        for (var r in roomtimetable) {
          if (!r.slot[day][newSlot].isEmpty) {
            isEmpty = false;
            break;
          }
        }

        if (isEmpty) {
          bool valid = true;
          for (int existingSlot in subjectSlots) {
            if ((newSlot - existingSlot).abs() > 1 && existingSlot != originalSlot) {
              valid = false;
              break;
            }
          }
          if (valid) {
            bool conflict = false;
            for (var t in teachertimetable) {
              if (t.slot[day][newSlot].teacher == teacherName && !t.slot[day][newSlot].isEmpty) {
                conflict = true;
                break;
              }
            }
            if (!conflict) {
              // Update sectimetable with the original slot data, using section-level dept and section
              String dept = sectimetable[sectionIndex].dept ?? slot.dept ?? '';
              int sectionNum = sectimetable[sectionIndex].section ?? slot.section ?? 0;
              sectimetable[sectionIndex].slot[day][newSlot] = Slot()
                ..dept = dept
                ..section = sectionNum
                ..room = slot.room ?? 0
                ..subject = slot.subject ?? ''
                ..teacher = teacherName
                ..isEmpty = false;
              int roomIndex = (slot.room ?? 1) - 1;
              if (roomIndex >= 0 && roomIndex < totalrooms) {
                roomtimetable[roomIndex].slot[day][newSlot] = Slot()
                  ..dept = dept
                  ..section = sectionNum
                  ..room = slot.room ?? 0
                  ..subject = slot.subject ?? ''
                  ..teacher = teacherName
                  ..isEmpty = false;
              }
              print("Assigned ${slot.subject} to $teacherName in section $dept ${String.fromCharCode(64 + sectionNum)} on day $day, slot $newSlot");
              return newSlot;
            }
          }
        }
      }
    }
  }
  return -1; // No suitable slot found
}

void printTeacherDetails() {

  for (var v in teachertimetable) {
    print("${v.dept}");
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        var slot = v.slot[i][j];
        stdout.write("${slot.subject} ${slot.dept} ${slot.room} | ");
      }
      print("");
    }
  }
}
