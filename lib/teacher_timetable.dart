import 'dart:io';
import 'dart:ui';

import 'select_timetable.dart';
import 'teacher.dart';

import 'data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'timetable.dart';
import 'package:flutter/material.dart';

class TeacherTimetable extends StatefulWidget {
  final String title;
  final List<Timetable> timetable;
  // Optional teacher data

  TeacherTimetable({required this.title, required this.timetable});

  @override
  State<TeacherTimetable> createState() => _TeacherTimetable();
}

class _TeacherTimetable extends State<TeacherTimetable> {
  ScrollController _scrollController = ScrollController();
  TextEditingController searchValue = TextEditingController();
  List<GlobalKey> cardKeys = [];


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Initialize in initState
    cardKeys = List.generate(widget.timetable.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 52,
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 180,
                height: 35,
                child: TextField(
                  controller: searchValue,
                  onSubmitted: (value) {
                    search(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Search',
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.blueGrey.shade800),
                      onPressed: () {
                        // Trigger search when icon is tapped
                        search(searchValue.text);
                      },
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  ),
                  style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 20,fontWeight: FontWeight.w600,),


                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'Print') {
                  printTimetables(widget.timetable);
                  // Do nothing for now
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Print',
                  child: Text('Save'),
                ),

              ],
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blueGrey.shade800,
          child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(Colors.blueGrey.shade800), // Darker grey for thumb
                    trackColor: WidgetStateProperty.all(Colors.grey[300]), // Lighter grey for track
                    trackBorderColor: WidgetStateProperty.all(Colors.blueGrey.shade800)
                ),
              ),

              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true, // Always show scrollbar
                thickness: 8,
                radius: Radius.circular(10),
                trackVisibility: true,
                interactive: true,
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: List.generate(widget.timetable.length, (index) {
                        if (widget.timetable.isEmpty) {
                          return Center(child: Text("No timetable data available"));
                        }
                        else { return RepaintBoundary(
                          key: cardKeys[index],
                          child: Container(
                              margin: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width - 40,
                              height: MediaQuery.of(context).size.height * 0.85, // 40% of screen height
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),

                              child: Column(
                                children: [
                                  Expanded( //top
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(//top left
                                              flex: 1,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double fontSize = constraints.maxWidth * 0.12;


                                                  return Container(
                                                    height: double.infinity,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(10),

                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "${widget.timetable[index].dept}",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.blueGrey.shade800,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )

                                          ),
                                          Expanded( //top right
                                              flex: 7,
                                              child: Row(
                                                  children: List.generate(totalslots,(s) {
                                                    return Expanded(
                                                        flex: 1,
                                                        child: LayoutBuilder(
                                                            builder: (context,constraints){
                                                              double fontSize = constraints.maxWidth * 0.1;
                                                              return Container(
                                                                margin: EdgeInsets.all(5),
                                                                height: double.infinity,
                                                                width: double.infinity,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.blueGrey.shade100,
                                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Time ${s + 1}",
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                      fontSize: fontSize,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.blueGrey.shade800,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                        )
                                                    );
                                                  })
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      flex: 8,
                                      child: Row(
                                        children: [
                                          Expanded( //bottom left
                                              flex: 1,
                                              child: Container(
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(10),

                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: List.generate(totaldays, (d) {
                                                      return Expanded(
                                                          flex: 1,
                                                          child: LayoutBuilder(
                                                              builder: (context,constraints){
                                                                double fontSize = constraints.maxWidth * 0.13;
                                                                return Container(
                                                                  margin: EdgeInsets.all(5),
                                                                  height: double.infinity,
                                                                  width: double.infinity,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.blueGrey.shade100,
                                                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Day ${d + 1}",
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                        fontSize: fontSize,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: Colors.blueGrey.shade800,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                          )
                                                      );
                                                    }),
                                                  )
                                              )
                                          ),
                                          Expanded( //bottom right
                                              flex: 7,
                                              child: Container(
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey.shade100,
                                                    borderRadius: BorderRadius.only(
                                                        bottomRight: Radius.circular(10),
                                                        topLeft: Radius.circular(10)

                                                    ),
                                                  ),
                                                  child: Column(
                                                      children: List.generate(totaldays, (d){
                                                        return Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                                children: List.generate(totalslots, (s){
                                                                  return Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        height: double.infinity,
                                                                        width: double.infinity,
                                                                        margin: EdgeInsets.all(5),
                                                                        decoration: BoxDecoration(
                                                                          color: widget.timetable[index].slot[d][s].isEmpty ? Colors.blueGrey.shade100 : Colors.white,
                                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                        ),
                                                                        child: Center(
                                                                          child: LayoutBuilder( builder: (context,constraints){
                                                                            double fontSize = constraints.maxWidth * 0.08;
                                                                            return Text("${widget.timetable[index].slot[d][s].subject} "
                                                                                "\n ${ widget.timetable[index].slot[d][s].room != 0 ? "Room ${widget.timetable[index].slot[d][s].room}" : "" } "
                                                                                "${widget.timetable[index].slot[d][s].dept} ${widget.timetable[index].slot[d][s].section != 0 ? "${String.fromCharCode(64 + widget.timetable[index].slot[d][s].section)}" : ""} "
                                                                              , style: TextStyle(fontSize: fontSize,fontWeight: FontWeight.w600,color: Colors.blueGrey.shade800, ) ,textAlign: TextAlign.center,);
                                                                          }
                                                                          ),
                                                                        ),
                                                                      )
                                                                  );
                                                                })
                                                            )
                                                        );
                                                      })
                                                  )
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              )
                          ),
                        );}
                      }),
                    ),
                  ),
                ),
              )

          ),
        )
    );
  }
  search(var value){
    final normalize = (String str) => str.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    final query = normalize(value);

    final index = widget.timetable.indexWhere(
          (t) => normalize(t.dept).contains(query),
    );

    if (index != -1) {
      _scrollController.animateTo(
        index * (MediaQuery.of(context).size.height * 0.85 + 20),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Department not found')),
      );
    }
  }

  Future<void> printTimetables(List<Timetable> timetables) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Saving timetables..."),
            ],
          ),
        );
      },
    );

    try {
      String? selectedDir = await FilePicker.getDirectoryPath();
      if (selectedDir == null && mounted) {
        Navigator.of(context).pop();
        return;
      }

      final timetablesDir = Directory('$selectedDir/Class_Timetables');
      if (!timetablesDir.existsSync()) {
        timetablesDir.createSync();
      }

      for (int i = 0; i < cardKeys.length; i++) {
        final boundary = cardKeys[i].currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData = await image.toByteData(format: ImageByteFormat.png);
          final pngBytes = byteData!.buffer.asUint8List();

          final dept = timetables[i].dept;
          final section = String.fromCharCode(65 + (timetables[i].section) ?? 0);

          final fileName = '$dept $section.png';

          final file = File('${timetablesDir.path}/$fileName');
          await file.writeAsBytes(pngBytes);
        }
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetables saved in Timetables folder')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving timetables: $e')),
      );
    }
  }

}