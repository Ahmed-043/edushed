import 'teacher_timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'teacher.dart';
import 'data.dart';
import 'class_timetable.dart';
import 'room_timetable.dart';

bool teachercsvLoaded = false;
List<List<String>> teacherData = [];

class GenerateTimetable extends StatefulWidget {
  const GenerateTimetable({Key? key}) : super(key: key);

  @override
  State<GenerateTimetable> createState() => _GenerateTimetableState();
}

class _GenerateTimetableState extends State<GenerateTimetable> {

  Map<String, TextEditingController> subjectControllers = {};

  @override
  void initState() {
    super.initState();

    // Initialize controllers for any pre-existing teacher data
    for (var teacher in teacherData) {
      subjectControllers[teacher[0]] = TextEditingController();
    }
  }

  @override


  // Extract unique subjects from subj for autocomplete
  List<String> getUniqueSubjects() {
    Set<String> uniqueSubjects = {};
    for (var row in subj) {
      for (int i = 2; i < row.length; i += 2) {
        if (row[i].isNotEmpty) {
          uniqueSubjects.add(row[i]);
        }
      }
    }
    return uniqueSubjects.toList()..sort();
  }

  void addSubject(String teacherName, String newSubject) {
    if (newSubject.trim().isEmpty) return;
    setState(() {
      for (var teacher in teacherData) {
        if (teacher[0] == teacherName) {
          List<String> currentSubjects = teacher[1].split(',').map((s) => s.trim()).toList();
          if (!currentSubjects.contains(newSubject.trim())) {
            teacher[1] = '${teacher[1]},${newSubject.trim()}';
            print('Added subject for $teacherName: $newSubject'); // Debug print
          }
          subjectControllers[teacherName]?.clear();
          break;
        }
      }
    });
  }

  void deleteTeacher(String teacherName) {
    setState(() {
      teacherData.removeWhere((teacher) => teacher[0] == teacherName);
      subjectControllers.remove(teacherName);
      print('Deleted teacher: $teacherName'); // Debug print
    });
  }

  void addNewTeacher(String name, String subjects) {
    if (name.trim().isEmpty || subjects.trim().isEmpty) return;
    setState(() {
      teacherData.add([name.trim(), subjects.trim()]);
      subjectControllers[name.trim()] = TextEditingController();
      print('Added new teacher: $name, Subjects: $subjects'); // Debug print
    });
  }

  void showSubjectMenu(BuildContext context, String teacherName) {
    showDialog(
      context: context,
      builder: (context) => _SubjectMenuDialog(
        teacherName: teacherName,
        teacherData: teacherData,
        uniqueSubjects: getUniqueSubjects(),
        addSubject: addSubject,
      ),
    );
  }



  Widget teacherWidget() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            child: Center(
              child: Text(
                "Teachers",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade600,
                ),
              ),
            ),
          )
        ),
        Expanded(
          flex: 10,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              itemCount: teacherData.length,
              itemBuilder: (context, index) {
                final teacherName = teacherData[index][0];
                final subjects = teacherData[index][1].split(',').map((s) => s.trim()).toList();
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6.0),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${index+1}) $teacherName",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      ),
                      Text("  (Subjects: ${subjects.length})"),

                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            showSubjectMenu(context, teacherName);
                          },
                          child: const Text('Add Subjects'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade700),
                          onPressed: () => deleteTeacher(teacherName),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        toolbarHeight: 60,
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        title: const Text('Generate Timetable'),

      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Colors.white,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                          shadowColor: Colors.grey.withOpacity(0.8),
                          child: InkWell(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 50), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClassTimetable(title: "Classes", timetable: sectimetable),
                                  ),
                                );
                              });
                            },
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                            splashColor: Colors.blueGrey.withOpacity(0.3),
                            child: Container(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double height = constraints.maxHeight;
                                  return Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Icon(
                                          Icons.sticky_note_2_rounded,
                                          size: height * 0.35,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Class Timetable",
                                          style: TextStyle(
                                            fontSize: height * 0.1,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Colors.white,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                          shadowColor: Colors.grey.withOpacity(0.8),
                          child: InkWell(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 50), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoomTimetable(title: "Rooms", timetable: roomtimetable),
                                  ),
                                );
                              });
                            },
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                            splashColor: Colors.blueGrey.withOpacity(0.3),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double height = constraints.maxHeight;
                                return Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Icon(
                                        Icons.meeting_room,
                                        size: height * 0.35,
                                        color: Colors.blueGrey.shade800,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "Rooms Timetable",
                                        style: TextStyle(
                                          fontSize: height * 0.1,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Colors.white,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                          shadowColor: Colors.grey.withOpacity(0.8),
                          child: InkWell(
                            onTap: () {
                              //Teacher Timetables
                              if(!teachercsvLoaded) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please load teacher data first!"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              else {
                                assignTeachersToClasses(teacherData);
                                printTeacherDetails();
                                Future.delayed(const Duration(milliseconds: 50), () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeacherTimetable (title: "Teachers", timetable: teachertimetable),
                                    ),
                                  );
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                            splashColor: Colors.blueGrey.withOpacity(0.3),
                            child: Container(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double height = constraints.maxHeight;
                                  return Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Icon(
                                          Icons.person,
                                          size: height * 0.35,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Teacher Timetable",
                                          style: TextStyle(
                                            fontSize: height * 0.1,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey.shade700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: EdgeInsets.only( left: 8, right: 8, bottom: 2),
                                          child: Row(
                                            children: [
                                             Expanded(
                                               flex: 1,
                                               child: Container(
                                                 margin: EdgeInsets.all(4),
                                                 height: double.infinity,
                                                 width: double.infinity,
                                                 child: ElevatedButton(onPressed: () async {
                                                    final data = await loadTeacherData();
                                                    setState(() {
                                                      teachercsvLoaded = true;
                                                      teacherData = data;
                                                      for (var teacher in teacherData) {
                                                        if (!subjectControllers.containsKey(teacher[0])) {
                                                            subjectControllers[teacher[0]] = TextEditingController();
                                                          }
                                                      }
                                                    });
                                                   },
                                                     child: Text("Browse CSV"),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.blueGrey.shade500,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(100),
                                                         // side: BorderSide(color: Colors.blueGrey.shade300, width: 1.5),
                                                        ),

                                                      )
                                                 ),
                                               )
                                             ),

                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.all(4),
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    child: ElevatedButton(onPressed: () {

                                                        setState(() {
                                                          teachercsvLoaded = true;
                                                        });

                                                    },
                                                        child: Text("Create New"),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          foregroundColor: Colors.blueGrey.shade500,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(100),
                                                            side: BorderSide(color: Colors.blueGrey.shade500, width: 1.5),
                                                          ),

                                                        )
                                                    ),
                                                  )
                                              ),
                                            ]
                                          )
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: totalrooms < reqrooms ? Colors.red.shade400 : Colors.blue.shade50,
                                  border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double fontSize = (constraints.maxHeight + constraints.maxWidth) * 0.04;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Available Rooms: $totalrooms",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: fontSize,
                                              color: totalrooms < reqrooms ? Colors.white : Colors.blueGrey.shade800),
                                        ),
                                        Text(
                                          "Required Rooms: $reqrooms",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: fontSize,
                                              color: totalrooms < reqrooms ? Colors.white : Colors.blueGrey.shade800),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: totalrooms < reqrooms ? Colors.red.shade400 : Colors.blue.shade50,
                                  border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double fontSize = (constraints.maxHeight + constraints.maxWidth) * 0.04;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Available Slots: $avslots",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: fontSize,
                                              color: totalrooms < reqrooms ? Colors.white : Colors.blueGrey.shade800),
                                        ),
                                        Text(
                                          "Required Slots: $reqslots",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: fontSize,
                                              color: totalrooms < reqrooms ? Colors.white : Colors.blueGrey.shade800),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double fontSize = (constraints.maxHeight + constraints.maxWidth) * 0.04;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Departments: ${dept.length}",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic, fontSize: fontSize, color: Colors.blueGrey.shade800),
                                        ),
                                        Text(
                                          "Sections: $totalsec",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic, fontSize: fontSize, color: Colors.blueGrey.shade800),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double fontSize = (constraints.maxHeight + constraints.maxWidth) * 0.04;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Days per week: $totaldays",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic, fontSize: fontSize, color: Colors.blueGrey.shade800),
                                        ),
                                        Text(
                                          "Slots per Day: $totalslots",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic, fontSize: fontSize, color: Colors.blueGrey.shade800),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: !teachercsvLoaded
                          ? Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade500,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: warnings.isEmpty
                            ? Center(child: Text("No Error Recorded", style: TextStyle(fontSize: 20, color: Colors.white)))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade500,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            padding: EdgeInsets.all(4),
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(warnings.length, (index) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading: Icon(Icons.warning, color: Colors.yellow),
                                      title: Text(warnings[index], style: TextStyle(color: Colors.white)),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      )
                          : teacherWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: teachercsvLoaded
          ? FloatingActionButton(
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blueGrey.shade700,
        onPressed: () {
          TextEditingController nameController = TextEditingController();
          TextEditingController subjectsController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add New Teacher'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Teacher Name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueGrey.shade700, width: 2.5),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                  SizedBox(
                    height: 10
                  ),
                  TextField(
                    controller: subjectsController,
                    decoration: InputDecoration(
                      labelText: 'Subjects (comma-separated)',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blueGrey.shade700, width: 2.5),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addNewTeacher(nameController.text, subjectsController.text);
                    Navigator.pop(context);
                    nameController.dispose();
                    subjectsController.dispose();
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

// Stateful dialog to dynamically update the subject list
class _SubjectMenuDialog extends StatefulWidget {
  final String teacherName;
  final List<List<String>> teacherData;
  final List<String> uniqueSubjects;
  final void Function(String, String) addSubject;

  const _SubjectMenuDialog({
    required this.teacherName,
    required this.teacherData,
    required this.uniqueSubjects,
    required this.addSubject,
  });

  @override
  _SubjectMenuDialogState createState() => _SubjectMenuDialogState();
}

class _SubjectMenuDialogState extends State<_SubjectMenuDialog> {
  late TextEditingController dialogSubjectController;

  @override
  void initState() {
    super.initState();
    dialogSubjectController = TextEditingController();
  }

  @override
  void dispose() {
    dialogSubjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.teacherData
        .firstWhere((teacher) => teacher[0] == widget.teacherName)[1]
        .split(',')
        .map((s) => s.trim())
        .toList();

    return AlertDialog(
      title: Text('${widget.teacherName} Subjects'),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return widget.uniqueSubjects.where((subject) {
                        return subject.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (String selection) {
                      dialogSubjectController.text = selection;
                    },
                    fieldViewBuilder: (context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,) {
                      return TextField(
                        controller: dialogSubjectController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Add Subject',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Colors.blueGrey.shade700, width: 2.5),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                        ),
                        onSubmitted: (value) {
                          widget.addSubject(widget.teacherName, value);
                          dialogSubjectController.clear();
                          setState(() {}); // Refresh subject list
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blueGrey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    widget.addSubject(
                        widget.teacherName, dialogSubjectController.text);
                    dialogSubjectController.clear();
                    setState(() {}); // Refresh subject list
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: subjects.isEmpty
                  ? const Center(child: Text('No subjects'))
                  : ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      subjects[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}