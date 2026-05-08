import 'package:edushed/timetable.dart';
import 'data.dart';

void alternateAllocateTimetable() {
  List<Timetable> sections = List.generate(totalsec, (_) => Timetable());
  List<Timetable> rooms = List.generate(totalrooms, (_) => Timetable());

  int secIndex = 0;

  for (int i = 0; i < sec.length; i++) {
    int sectionCount = int.parse(sec[i]);
    for (int k = 0; k < sectionCount; k++) {
      List<String> subjects = subj[i];
      List<String> subjectNums = subjnum[i];

      for (int j = 0; j < subjects.length; j++) {
        String subjectName = subjects[j];
        int hours = int.parse(subjectNums[j]);

        int assignedCount = 0;

        // Loop to assign each subject 'hours' times
        while (assignedCount < hours) {
          bool assigned = false;

          // Try all day/slot/room combinations
          for (int d = 0; d < totaldays && !assigned; d++) {
            for (int s = 0; s < totalslots && !assigned; s++) {
              for (int r = 0; r < totalrooms && !assigned; r++) {
                // Check both section and room availability
                if (sections[secIndex].slot[d][s].isEmpty && rooms[r].slot[d][s].isEmpty) {
                  // Assign to section timetable
                  sections[secIndex].slot[d][s]
                    ..subject = subjectName
                    ..room = r + 1
                    ..isEmpty = false;

                  // Assign to room timetable
                  rooms[r].slot[d][s]
                    ..dept = dept[i]
                    ..section = k + 1
                    ..subject = subjectName
                    ..isEmpty = false;

                  assignedCount++;
                  assigned = true;
                }
              }
            }
          }

          // If not assigned, raise a warning
          if (!assigned) {
            String msg = "⚠️ Could not assign '$subjectName' for ${dept[i]} section ${k + 1}";
            warnings.add(msg);
            print(msg);
            break;
          }
        }
      }

      sections[secIndex].section = k + 1;
      sections[secIndex].dept = dept[i];
      secIndex++;
    }
  }

  sectimetable = sections;
  roomtimetable = rooms;
}

