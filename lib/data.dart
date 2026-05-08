import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'alternateformats.dart';
import 'list_to_csv_converter.dart';
import 'timetable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

  int totalrooms = 10, totalslots = 5, totaldays = 6;
  int  totalsec = 0 , reqslots = 0, avslots = 0,  reqrooms = 0;
  List<Timetable> sectimetable = [], roomtimetable = [], teachertimetable = [];
  List<List<String>> data = [], subj = [], subjnum = [];
  List<String> dept = [], sec = [], warnings = [];
  Map<int, String> sectionPreferences = {};

void clear() {
  data.clear();
  subj.clear();
  subjnum.clear();
  dept.clear();
  sec.clear();
  totalsec = 0;
  reqrooms = 0;
  reqslots = 0;
  avslots = 0;
  totalsec = 0;
  warnings = [];
}

Future<void> calculateData(String csvData) async {
  // Ensures Flutter bindings are initialized
  clear();
  WidgetsFlutterBinding.ensureInitialized();
  // Load CSV file
  totalsec = await filterData(csvData);
  // Print each line
  if(sectionPreferences.isEmpty) {
    // Default section preferences if not provided
    allocateTimetable();
  }
  else {
    pallocateTimetable();
  }
  //optimize();
  checkSectionConflicts();
  //alternateAllocateTimetable();

}

List<List<String>> removeCol(List<List<String>> input) {
  return input.map((row) => row.sublist(1)).toList();
}

Future<int> filterData(String csvData) async {
  final fields = CsvToListConverter().convert(csvData);
  // Convert all dynamic to string and remove empty cells
  data = fields
    .map((row) =>
    row.map((e) => e.toString()).where((cell) => cell.trim().isNotEmpty).toList())
    .toList();

  for (var row in data) {
    List<String> evenRow = [], oddRow = [];
    for (int i = 0; i < row.length; i++) {
      if (i % 2 == 0) {
        evenRow.add(row[i]);
      } else {
        oddRow.add(row[i]);
      }
    }
    subj.add(evenRow);
    subjnum.add(oddRow);
  }
  dept = subj.map((v) => v[0]).toList();
  sec = subjnum.map((v) => v[0]).toList();

  subj = removeCol(subj);
  subjnum = removeCol(subjnum);

  int totalSec = 0;
  for (var row in data) {
    totalSec += int.tryParse(row[1]) ?? 0;
  }
  print("Data Filtered");
  print("subjnum: $subjnum");
  print("subj: $subj");
  print("dept: $dept");
  print("sec: $sec");
  return totalSec;
}

void allocateTimetable() {
  List<Timetable> sections = List.generate(totalsec, (_) => Timetable());
  List<Timetable> rooms = List.generate(totalrooms, (_) => Timetable());

  int c = 0;
  for (var row in data) {
    int numsect = int.parse(row[1]);
    for (int i = 0; i < numsect; i++) {
      sections[c++].dept = row[0];
    }
  }

  // Calculate required slots
  reqslots = 0;
  for (int i = 0; i < sec.length; i++) {
    int num = 0;
    for (var l in subjnum[i]) {
      num += int.parse(l);
    }
    reqslots += num * int.parse(sec[i]);
  }
  reqrooms = (reqslots / (totaldays * totalslots)).ceil();
  avslots = totalrooms * totaldays * totalslots;

  print("Required Slots: $reqslots");
  print("Available are: $avslots");
  print("Required rooms: $reqrooms");
  print("Available are: $totalrooms");

  // Timetable allocation with counters
  int roomIndex = 0, dayIndex = 0, slotIndex = 0;
  int i = 0, scount = 0;
  for (var department in dept) {
    int deptnum = int.parse(sec[i]);
    for (int sectnum = 0; sectnum < deptnum; sectnum++) {
      List<String> subjs = subj[i];
      List<String> subjn = subjnum[i];
      sections[scount].section = sectnum + 1;
      sections[scount].dept = department;
      for (int j = 0; j < subjs.length; j++) {
        String currentsubj = subjs[j];
        int repeat = int.parse(subjn[j]);
        for (int rep = 0; rep < repeat; rep++) {
          bool assigned = false;
          int totalAttempts = totalrooms * totaldays * totalslots;
          int attempts = 0;
          while (!assigned && attempts < totalAttempts) {
            int r = roomIndex;
            int d = dayIndex;
            int s = slotIndex;

            if (rooms[r].slot[d][s].isEmpty) {
              // Assign to room timetable
              rooms[r].slot[d][s]
                ..dept = department
                ..section = sectnum + 1
                ..subject = currentsubj
                ..isEmpty = false;

              // Assign to section timetable
              sections[scount].slot[d][s]
                ..subject = currentsubj
                ..room = r + 1
                ..isEmpty = false;

              assigned = true;
            }
            // Move counter forward
            dayIndex++;
            if (dayIndex >= totaldays) {
              dayIndex = 0;
              slotIndex++;
              if (slotIndex >= totalslots) {
                slotIndex = 0;
                roomIndex++;
                if (roomIndex >= totalrooms) {
                  roomIndex = 0;
                }
              }
            }
            attempts++;
          }
          if (!assigned) {
            print("⚠️ Warning: Could not assign '$currentsubj' for $department section ${sectnum + 1} (No empty room slot)");
            warnings.add("Could not assign '$currentsubj' for $department section ${sectnum + 1} (No empty room slot)");
          }
        }
      }

      scount++;
    }

    i++;
  }

  sectimetable = sections;
  roomtimetable = rooms;

  // Print room-wise timetable
  for (int count = 0; count < roomtimetable.length; count++) {
    print("Room: ${count + 1}");
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        var slot = roomtimetable[count].slot[i][j];
        stdout.write("${slot.dept} ${slot.section} ${slot.subject} | ");
      }
      print("");
    }
  }

  // Print section-wise timetable
  for (var v in sectimetable) {
    print("${v.dept} ${v.section}");
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        var slot = v.slot[i][j];
        stdout.write("${slot.subject} ${slot.room} | ");
      }
      print("");
    }
  }

  print("Optimized with Continuous Counter ✅");
}

void checkSectionConflicts() {
  for (int i = 0; i < sectimetable.length; i++) {
    Timetable a = sectimetable[i];
    for (int day = 0; day < totaldays; day++) {
      for (int slot = 0; slot < totalslots; slot++) {
        Slot sa = a.slot[day][slot];
        if (!sa.isEmpty) {
          for (int j = i + 1; j < sectimetable.length; j++) {
            Timetable b = sectimetable[j];
            Slot sb = b.slot[day][slot];
            if (!sb.isEmpty && sa.room == sb.room) {
              // Same room, same time, two different sections
              String conflict =
                  '❌ Conflict: ${a.dept}-Sec${a.section} and ${b.dept}-Sec${b.section} both have Room ${sa.room} on Day $day, Slot $slot.';
              warnings.add(conflict);
              print(conflict);
            }
          }
        }
      }
    }
  }

  if (warnings.isEmpty) {
    print('✅ No section-to-section room conflicts found.');
  }
}

void optimize(){
  print("Optimizing timetable...");
  for (int i = 0; i < sectimetable.length; i++) {
    sectimetable[i].removeTeacher();
  }
  for (int i = 0; i < roomtimetable.length; i++) {
    roomtimetable[i].removeTeacher();
  }
  teachertimetable = [];

  for(int s=0; s<sectimetable.length; s++){
    for(int day = 0; day < totaldays; day++){
      for(int slot = 0; slot < totalslots; slot++){
        bool found1 = false,found2 = false;
        if(!sectimetable[s].slot[day][slot].isEmpty){
          found1 = true;
        }
        int i=0, newslot = 0;
        for(int m=slot+1; m<totalslots && found1 ; m++){
          if(sectimetable[s].slot[day][m].isEmpty){
            i++;
          }else{
            found2 = true;
            newslot = m;
            break;
          }
        }
        if(i>1 && (found2 && found1)){

          var o = totalslots/2;

          int count1 = 0, count2 =0;
         for(int i=0; i<=o; i++){
           for(int j=0; j<totaldays; j++){
             if(!sectimetable[s].slot[j][i].isEmpty){
               count1++;
             }
           }
         }
          for(int i=o.toInt()+1; i<totalslots; i++){
            for(int j=0; j<totaldays; j++){
              if(!sectimetable[s].slot[j][i].isEmpty){
                count2++;
              }
            }
          }
          if(count1 >= count2) {
            bool moved = false;
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][slot + 1].isEmpty &&
                  sectimetable[s].slot[day][slot + 1].isEmpty) {
                swapSlots(s, day, slot + 1, day, newslot, findroom);
                moved = true;
                break;
              }
            }
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][slot + 2].isEmpty &&
                  sectimetable[s].slot[day][slot + 2].isEmpty) {
                swapSlots(s, day, slot + 2, day, newslot, findroom);
                moved = true;
                break;
              }
            }
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][newslot - 1].isEmpty &&
                  sectimetable[s].slot[day][newslot - 1].isEmpty) {
                swapSlots(s, day, newslot - 1, day, slot, findroom);
                moved = true;
                break;
              }
            }
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][newslot - 2].isEmpty &&
                  sectimetable[s].slot[day][newslot - 2].isEmpty) {
                swapSlots(s, day, newslot - 2, day, slot, findroom);
                moved = true;
                break;
              }
            }
          }
          else{
            bool moved = false;
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][newslot - 1].isEmpty &&
                  sectimetable[s].slot[day][newslot - 1].isEmpty) {
                swapSlots(s, day, newslot - 1, day, slot, findroom);
                moved = true;
                break;
              }
            }
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][newslot - 2].isEmpty &&
                  sectimetable[s].slot[day][newslot - 2].isEmpty) {
                swapSlots(s, day, newslot - 2, day, slot, findroom);
                moved = true;
                break;
              }
            }
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][slot + 1].isEmpty &&
                  sectimetable[s].slot[day][slot + 1].isEmpty) {
                swapSlots(s, day, slot + 1, day, newslot, findroom);
                moved = true;
                break;
              }
            }
            for (int findroom = 0; findroom < totalrooms && !moved; findroom++) {
              if (roomtimetable[findroom].slot[day][slot + 2].isEmpty &&
                  sectimetable[s].slot[day][slot + 2].isEmpty) {
                swapSlots(s, day, slot + 2, day, newslot, findroom);
                moved = true;
                break;
              }
            }

          }
        }
      }
    }
  }
}

swapSlots(int s,int day, int slot, int newday, int newslot, int findroom) {
  // print("Slot found in room ${findroom+1} on day $day slot $slot+1");
  int freeroom = (sectimetable[s].slot[day][newslot].room) -1;
  sectimetable[s].slot[newday][slot].room = findroom + 1;
  sectimetable[s].slot[newday][slot].subject = sectimetable[s].slot[day][newslot].subject;
  sectimetable[s].slot[newday][slot].section = sectimetable[s].slot[day][newslot].section;
 // sectimetable[s].slot[newday][slot].teacher = sectimetable[s].slot[day][newslot].teacher;

  sectimetable[s].slot[newday][slot].isEmpty = false;
  sectimetable[s].slot[day][newslot].clear();

  roomtimetable[findroom].slot[newday][slot].isEmpty = false;
  roomtimetable[findroom].slot[newday][slot].dept = sectimetable[s].dept;
  roomtimetable[findroom].slot[newday][slot].subject = sectimetable[s].slot[newday][slot].subject;
  roomtimetable[findroom].slot[newday][slot].section = sectimetable[s].section;
  roomtimetable[freeroom].slot[day][newslot].clear();
}


void pallocateTimetable() {
  // Allocate section names from CSV data
  List<Timetable> sections = List.generate(totalsec, (_) => Timetable());
  List<Timetable> rooms = List.generate(totalrooms, (_) => Timetable());

  int c = 0;
  for (var row in data) {
    int numsect = int.tryParse(row[1]) ?? 0;
    if (numsect == 0) {
      warnings.add("Invalid section count for department ${row[0]}: ${row[1]}");
      continue;
    }
    for (int i = 0; i < numsect; i++) {
      sections[c++].dept = row[0];
    }
  }

  // Calculate required slots
  c = 0;
  reqslots = 0;
  for (int i = 0; i < sec.length; i++) {
    int num = 0;
    for (var l in subjnum[i]) {
      num += int.tryParse(l) ?? 0;
    }
    reqslots += num * (int.tryParse(sec[i]) ?? 0);
  }
  reqrooms = (reqslots / (totaldays * totalslots)).ceil();
  avslots = totalrooms * totaldays * totalslots;
  print("Required Slots: $reqslots");
  print("Available are: $avslots");
  print("Required rooms: $reqrooms");
  print("Available are: $totalrooms");

  // Group sections by preference
  List<int> earlySections = [];
  List<int> middleSections = [];
  List<int> lateSections = [];
  List<int> defaultSections = [];
  for (int i = 0; i < totalsec; i++) {
    int sectionNumber = i + 1;
    String? pref = sectionPreferences[sectionNumber];
    if (pref == 'E') {
      earlySections.add(i);
    } else if (pref == 'M') {
      middleSections.add(i);
    } else if (pref == 'L') {
      lateSections.add(i);
    } else {
      defaultSections.add(i);
    }
  }
  // Timetable allocation for preferred sections
  List<int> unallocatedSections = [];
  int i = 0, scount = 0;
  for (var department in dept) {
    int deptnum = int.tryParse(sec[i]) ?? 0;
    if (deptnum == 0) {
      i++;
      continue;
    }

    for (int sectnum = 0; sectnum < deptnum; sectnum++) {
      List<String> subjs = subj[i];
      List<String> subjn = subjnum[i];
      sections[scount].section = sectnum + 1;
      sections[scount].dept = department;

      String? pref = sectionPreferences[scount + 1];
      bool isEarly = pref == 'E', isMiddle = pref == 'M', isLate = pref == 'L';
      int startSlot = 0;
      if (isEarly) {
        startSlot = 0; // Start at first slot
      } else if (isMiddle) {
        startSlot = (totalslots / 2).floor() - 1; // Start at middle-1
        if (startSlot < 0) startSlot = 0; // Ensure valid slot
      } else if (isLate) {
        startSlot = totalslots - 1; // Start at last slot
      }

      for (int j = 0; j < subjs.length; j++) {
        String currentsubj = subjs[j];
        int repeat = int.tryParse(subjn[j]) ?? 0;
        if (repeat == 0) {
          warnings.add("Invalid credit hours for $department section ${sectnum + 1}: ${subjn[j]}");
          continue;
        }

        int slotsAssigned = 0;
        if (isEarly || isMiddle || isLate) {
          // Allocate preferred sections column-wise
          for (int sOffset = 0; sOffset < totalslots && slotsAssigned < repeat; sOffset++) {
            int s = isLate ? (startSlot - sOffset + totalslots) % totalslots : (startSlot + sOffset) % totalslots;
            for (int d = isLate ? totaldays - 1 : 0; isLate ? d >= 0 : d < totaldays; d += isLate ? -1 : 1) {
              for (int r = 0; r < totalrooms && slotsAssigned < repeat; r++) {
                if (rooms[r].slot[d][s].isEmpty && sections[scount].slot[d][s].isEmpty) {
                  rooms[r].slot[d][s]
                    ..dept = department
                    ..section = sectnum + 1
                    ..subject = currentsubj
                    ..isEmpty = false;
                  sections[scount].slot[d][s]
                    ..subject = currentsubj
                    ..room = r + 1
                    ..isEmpty = false;
                  slotsAssigned++;
                  break;
                }
              }
            }
          }
        }

        if (slotsAssigned < repeat) {
          if (slotsAssigned == 0) {
            unallocatedSections.add(scount);
          } else {
            warnings.add("Could not assign all $repeat slots for $currentsubj in $department section ${sectnum + 1} ($pref slots). Assigned: $slotsAssigned.");
          }
        }
      }
      scount++;
    }
    i++;
  }

  // Allocate default and unallocated sections column-wise
  scount = 0;
  i = 0;
  for (var department in dept) {
    int deptnum = int.tryParse(sec[i]) ?? 0;
    if (deptnum == 0) {
      i++;
      continue;
    }

    for (int sectnum = 0; sectnum < deptnum; sectnum++) {
      if (!defaultSections.contains(scount) && !unallocatedSections.contains(scount)) {
        scount++;
        continue; // Skip already allocated preferred sections
      }
      List<String> subjs = subj[i];
      List<String> subjn = subjnum[i];
      sections[scount].section = sectnum + 1;
      sections[scount].dept = department;

      for (int j = 0; j < subjs.length; j++) {
        String currentsubj = subjs[j];
        int repeat = int.tryParse(subjn[j]) ?? 0;
        if (repeat == 0) {
          warnings.add("Invalid credit hours for $department section ${sectnum + 1}: ${subjn[j]}");
          continue;
        }

        int slotsAssigned = 0;
        // Count already assigned slots for this subject
        for (int d = 0; d < totaldays; d++) {
          for (int s = 0; s < totalslots; s++) {
            if (sections[scount].slot[d][s].subject == currentsubj) {
              slotsAssigned++;
            }
          }
        }

        for (int rep = slotsAssigned; rep < repeat; rep++) {
          bool assigned = false;
          for (int r = 0; r < totalrooms && !assigned; r++) {
            for (int s = 0; s < totalslots && !assigned; s++) {
              for (int d = 0; d < totaldays && !assigned; d++) {
                if (rooms[r].slot[d][s].isEmpty && sections[scount].slot[d][s].isEmpty) {
                  rooms[r].slot[d][s]
                    ..dept = department
                    ..section = sectnum + 1
                    ..subject = currentsubj
                    ..isEmpty = false;
                  sections[scount].slot[d][s]
                    ..subject = currentsubj
                    ..room = r + 1
                    ..isEmpty = false;
                  assigned = true;
                  slotsAssigned++;
                }
              }
            }
          }
          if (!assigned) {
            warnings.add("Could not assign '$currentsubj' for $department section ${sectnum + 1} (No empty room slot)");
          }
        }
      }
      scount++;
    }
    i++;
  }

  sectimetable = sections;
  roomtimetable = rooms;
  // Print room-wise timetable
  for (int count = 0; count < roomtimetable.length; count++) {
    print("Room: ${count + 1}");
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        var slot = roomtimetable[count].slot[i][j];
        stdout.write("${slot.dept} ${slot.section} ${slot.subject} | ");
      }
      print("");
    }
  }

  for (var v in sectimetable) {
    print("${v.dept} ${v.section}");
    for (int i = 0; i < totaldays; i++) {
      for (int j = 0; j < totalslots; j++) {
        var slot = v.slot[i][j];
        stdout.write("${slot.subject} ${slot.room} | ");
      }
      print("");
    }
  }
  print("Preferred Allocation");
}