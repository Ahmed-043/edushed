import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'data.dart' as teacherData;
import 'list_to_csv_converter.dart';
import 'select_timetable.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<String>> csvData = [];
  var csvContent = '';
  var file = File('');
  bool fileselected = false, newfile = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.blue,
      //   title: Text("Academic Scheduler"), // Hide the debug banner
      // ),
      body: Container(
        color: Colors.blueGrey.shade100,
        child: Center(
          child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Center(
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.01,
                              bottom: MediaQuery.of(context).size.width * 0.01,
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.01
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: double.infinity,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            double fontSize = (constraints.maxHeight + constraints.maxWidth) * 0.08-12; // 40% of parent height
                                            return Center(
                                              child: Text(
                                                'Academic Scheduler',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontFamily: 'arial',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey.shade800,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 20
                                      ),
                                      child: Center(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                await openfile();
                                                setState(() {});
                                              },
                                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                                              splashColor: Colors.blueGrey.withOpacity(0.3),
                                              child: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                                                      border: Border.all(
                                                        color: !fileselected ?  Colors.blueGrey.shade200 : Colors.blueGrey.shade800,
                                                        width: !fileselected ? 2 : 3,
                                                      )
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: LayoutBuilder(
                                                            builder: (context, constraints) {
                                                              double fontSize = constraints.maxHeight * 0.25; // 50% of parent height
                                                              return Text(
                                                                "Browse CSV File",
                                                                style: TextStyle(
                                                                  fontSize: fontSize,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.blueGrey.shade800,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      // SizedBox( width: 10),
                                                      Expanded(
                                                        flex: 1,
                                                        child: LayoutBuilder(builder: (context,constraints){
                                                          double iconSize = constraints.maxHeight * 0.4; // 50% of parent height
                                                          return Icon(
                                                            Icons.file_open_outlined,
                                                            size: iconSize,
                                                            color: Colors.blueGrey.shade800,);
                                                        }),
                                                      )

                                                    ],
                                                  )
                                              ),
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 20
                                      ),
                                      child: Center(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                createnew();
                                                setState(() {});
                                              },
                                              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                                              splashColor: Colors.blueGrey.withOpacity(0.3),
                                              child: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.04),
                                                      border: Border.all(
                                                        color: !newfile ? Colors.blueGrey.shade200 : Colors.blueGrey.shade800,
                                                        width: !newfile ? 2 : 3,
                                                      )
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: LayoutBuilder(
                                                            builder: (context, constraints) {
                                                              double fontSize = constraints.maxHeight * 0.25; // 50% of parent height
                                                              return Text(
                                                                "Create New",
                                                                style: TextStyle(
                                                                  fontSize: fontSize,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.blueGrey.shade800,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      // SizedBox( width: 10),
                                                      Expanded(
                                                        flex: 1,
                                                        child: LayoutBuilder(builder: (context,constraints){
                                                          double iconSize = constraints.maxHeight * 0.4; // 50% of parent height
                                                          return Icon(
                                                            Icons.add,
                                                            size: iconSize,
                                                            color: Colors.blueGrey.shade800,);
                                                        }),
                                                      )

                                                    ],
                                                  )
                                              ),
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        color: Colors.white,
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 30, right: 30,bottom: 5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (csvData.isNotEmpty) {
                                                            showSectionPreferencesDialog(context, csvData);
                                                          } else {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text("Please load a CSV file first.")),
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          width: double.infinity,
                                                          child: LayoutBuilder(
                                                            builder: (context, constraints) {
                                                              double fontSize = constraints.maxHeight * 0.7; // 40% of parent height
                                                              return Text(
                                                                "Set Priorities",
                                                                style: TextStyle(
                                                                  fontSize: fontSize,
                                                                  color: Colors.blueGrey.shade800,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40,
                                            right: 40,
                                            bottom: 20,
                                            top: 20
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  teachercsvLoaded = false;
                                                  teacherData.clear();
                                                  csvData.removeWhere((row) => row.isEmpty || row[0].trim().isEmpty || row[1].trim().isEmpty);
                                                });
                                                String csvString = const ListToCsvConverter().convert(csvData);
                                                if (csvData.isNotEmpty) {

                                                  if(checkFormat(csvString)) {
                                                    calculateData(csvString);
                                                    // csvData.clear(); // Clear visible data
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => const GenerateTimetable(),
                                                      ),
                                                    );
                                                  }


                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Please load a CSV file first.")),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blueGrey.shade800,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(50),
                                                ),
                                                elevation: 5,
                                              ),
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  double fontSize = (constraints.maxHeight + constraints.maxWidth) * 0.08; // Adjust the multiplier as needed
                                                  return Text(
                                                    "Generate Timetable",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: fontSize,
                                                    ),
                                                  );
                                                },
                                              )
                                          ),
                                        )
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(

                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )

                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10,
                          right: 20
                      ),
                      child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade800,
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12
                                      ),
                                      child: !(fileselected||newfile) ? Center(
                                        child: Text(
                                          file.path.isNotEmpty ? p.basename(file.path) : 'No file selected',
                                          style: TextStyle(fontSize: 20, color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ) :
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    saveCsvData();
                                                  },
                                                  borderRadius: BorderRadius.circular(12),
                                                  splashColor: Colors.blueGrey.withOpacity(0.3),
                                                  child: Text(
                                                    file.path.isNotEmpty ? p.basename(file.path) : newfile ? 'New File': 'No file selected',

                                                    style: TextStyle(fontSize: 20, color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.12,
                                                      height: 35,
                                                      child: TextField(
                                                        controller: TextEditingController(
                                                          text: '$totalrooms',
                                                        ),
                                                        onChanged: (value) {
                                                          totalrooms = int.tryParse(value) ?? 0;
                                                        },

                                                        style: TextStyle(color: Colors.white, ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                                                        decoration: InputDecoration(
                                                          labelText: 'Rooms',
                                                          labelStyle: TextStyle(color: Colors.white),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(color: Colors.white, width: 2),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(20),
                                                            borderSide: BorderSide(color: Colors.white, width: 2),
                                                          ),
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.12,
                                                      height: 35,
                                                      child: TextField(
                                                        controller: TextEditingController(
                                                          text: '$totaldays',
                                                        ),
                                                        onChanged: (value) {
                                                          totaldays = int.tryParse(value) ?? 0;
                                                        },

                                                        style: TextStyle(color: Colors.white, ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                                                        decoration: InputDecoration(
                                                          labelText: 'Days',
                                                          labelStyle: TextStyle(color: Colors.white),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(color: Colors.white, width: 2),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(20),
                                                            borderSide: BorderSide(color: Colors.white, width: 2),
                                                          ),
                                                          isDense: true,
                                                          contentPadding:
                                                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.12,
                                                      height: 35,
                                                      child: TextField(
                                                        controller: TextEditingController(
                                                          text: '$totalslots',
                                                        ),
                                                        onChanged: (value) {
                                                          totalslots = int.tryParse(value) ?? 0;
                                                        },

                                                        style: TextStyle(color: Colors.white, ),
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                                                        decoration: InputDecoration(
                                                          labelText: 'Lectures per day',
                                                          labelStyle: TextStyle(color: Colors.white),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(color: Colors.white, width: 2),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(20),
                                                            borderSide: BorderSide(color: Colors.white, width: 2),
                                                          ),
                                                          isDense: true,
                                                          contentPadding:
                                                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: ElevatedButton(onPressed: (){
                                              closefile();
                                            },
                                              child: Text("Delete", style: TextStyle(fontSize: 16, color: Colors.white)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red.shade700,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              ),
                                            ),

                                          ),

                                        ],
                                      )
                                      ,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 10,
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: csvData.isEmpty
                                        ? Center(child: Text("No data loaded", style: TextStyle(fontSize: 18)))
                                        :
                                    Stack(
                                      children: [
                                        // Your scrollable table widget here
                                        Positioned.fill(child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Column(
                                              children: [
                                                // Header Row
                                                Row(
                                                  children: List.generate(csvData[0].length, (index) {
                                                    return Container(
                                                      width: index % 2 == 0 ? 150 : 75,
                                                      margin: EdgeInsets.all(4),
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        index == 0
                                                            ? 'Department'
                                                            : index == 1
                                                            ? 'Sections'
                                                            : index % 2 == 0
                                                            ? 'Subject ${(index - 2) ~/ 2 + 1}'
                                                            : 'C.hr ${(index - 3) ~/ 2 + 1}',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                                // Data Rows
                                                ...List.generate(csvData.length, (rowIndex) {
                                                  return Row(
                                                    children: List.generate(csvData[rowIndex].length, (colIndex) {
                                                      return Container(
                                                        width: colIndex % 2 == 0 ? 150 : 75,
                                                        margin: EdgeInsets.all(4),
                                                        child: TextField(
                                                          controller: TextEditingController(
                                                            text: csvData[rowIndex][colIndex],
                                                          ),
                                                          onChanged: (value) {
                                                            csvData[rowIndex][colIndex] = value;
                                                          },
                                                          keyboardType: colIndex % 2 == 1 ? TextInputType.number : TextInputType.text,
                                                          inputFormatters: colIndex % 2 == 1
                                                              ? [FilteringTextInputFormatter.digitsOnly]
                                                              : [],
                                                          decoration: InputDecoration(
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                              borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(16),
                                                              borderSide: BorderSide(color: Colors.blueGrey.shade700, width: 2.5),
                                                            ),
                                                            isDense: true,
                                                            contentPadding:
                                                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        )

                                        ),

                                        // Two FABs: Add Row and Add Column
                                        Positioned(
                                          bottom: 16,
                                          right: 16,
                                          child: Column(
                                            //  mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FloatingActionButton(
                                                heroTag: 'add_row',
                                                backgroundColor: Colors.blue.shade100,
                                                onPressed: () {
                                                  setState(() {
                                                    csvData.add(List.generate(csvData[0].length, (_) => ''));
                                                  });
                                                },
                                                tooltip: 'Add Row',
                                                child: Icon(Icons.table_rows,color: Colors.blueGrey.shade700),
                                              ),
                                              SizedBox(height: 12),
                                              FloatingActionButton(
                                                heroTag: 'add_column',
                                                backgroundColor: Colors.blue.shade100,
                                                onPressed: () {
                                                  setState(() {
                                                    csvData[0].add(''); // Add subject column
                                                    csvData[0].add(''); // Add credit hour column
                                                    for (int i = 1; i < csvData.length; i++) {
                                                      csvData[i].add('');
                                                      csvData[i].add('');
                                                    }
                                                  });
                                                },
                                                tooltip: 'Add Column',
                                                child: Icon(Icons.view_column,color: Colors.blueGrey.shade700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )


                                ),
                              ),

                            ],
                          )
                      ),
                    )
                ),

              ]

          ),


        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  openfile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      fileselected = true;
      newfile = false;
      file = File(result.files.single.path!);
      csvContent = await file.readAsString();

      // Parse CSV into 2D list
      csvData = const LineSplitter()
          .convert(csvContent)
          .map((line) => line.split(','))
          .toList();

      setState(() {}); // update UI

      print('CSV Loaded: ${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV file loaded successfully.")),
      );
    } else {
      print('No file selected');
    }
  }

  void closefile() {
    setState(() {
      fileselected = false;
      newfile = false;
      file = File('');
      csvData.clear();
      csvContent = '';

    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("File closed and data cleared.")),
    );
  }

  void createnew() {
    setState(() {
      csvData = [
        ['BSCS', '1', 'Subject 1', '3', 'Subject 2', '4'],
        ['BSIT', '2', 'Subject 3', '2', 'Subject 4', '3'],
        ['BBA', '3', 'Subject 5', '3', 'Subject 6', '4'],
        ['', '', '', '', '', ''],
      ];
      newfile = true;
      fileselected = false;
      file = File(''); // Placeholder for new file
      csvContent = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("New file created.")),
    );
  }

  bool checkFormat(String csvString) {
    final rows = const CsvToListConverter().convert(csvString);
    for (final row in rows) {
      for (int i = 1; i < row.length; i += 2) {
        final value = row[i].toString();
        if (int.tryParse(value) == null && value.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid data format in row "
                "${rows.indexOf(row) + 1}, column "
                "${i + 1}. Expected an integer.")),
          );
          return false;
        }
      }
    }
    return true;
  }

  void saveCsvData() async {
    try {
      String csvString = csvData.map((row) => row.join(',')).join('\n');
      String? path = await FilePicker.saveFile(
        dialogTitle: 'Save CSV File',
        fileName: 'timetable.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (path == null) return;

      // Ensure .csv extension
      if (!path.toLowerCase().endsWith('.csv')) {
        path += '.csv';
      }

      file = File(path);
      await file!.writeAsString(csvString);

      print('CSV saved at: ${file!.path}');
      setState(() { });  // Update UI if needed
    } catch (e) {
      print('Error saving CSV: $e');
    }
  }



// Function to display dialog with departments and sections with dropdowns using csvData
  void showSectionPreferencesDialog(BuildContext context, List<List<String>> csvData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(16.0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.3, // Reduced width (30% of screen width)
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(csvData.length, (deptIndex) {
                  // Skip empty rows
                  if (csvData[deptIndex].isEmpty || csvData[deptIndex][0].trim().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final department = csvData[deptIndex][0]; // Department from first column
                  final sectionCount = int.tryParse(csvData[deptIndex][1]) ?? 0; // Sections from second column
                  // Calculate section number offset based on previous departments' sections
                  int sectionNumberOffset = csvData
                      .sublist(0, deptIndex)
                      .fold(0, (sum, row) => sum + (int.tryParse(row[1]) ?? 0));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          department,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      ...List.generate(sectionCount, (sectionIndex) {
                        final sectionNumber = sectionNumberOffset + sectionIndex + 1;
                        // Map stored preference to dropdown display value
                        String selectedValue = sectionPreferences[sectionNumber] == 'E'
                            ? 'Early'
                            : sectionPreferences[sectionNumber] == 'M'
                            ? 'Middle'
                            : sectionPreferences[sectionNumber] == 'L'
                            ? 'Late'
                            : 'Default';

                        return Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Section ${String.fromCharCode(65 + sectionIndex)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: selectedValue,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.blueGrey.shade700, width: 2.5),
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    filled: true,
                                    fillColor: Colors.blueGrey.shade50,
                                  ),
                                  items: ['Default', 'Early', 'Middle', 'Late']
                                      .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      // Update global sectionPreferences
                                      if (newValue == 'Default') {
                                        sectionPreferences.remove(sectionNumber);
                                      } else {
                                        sectionPreferences[sectionNumber] =
                                        newValue == 'Early'
                                            ? 'E'
                                            : newValue == 'Middle'
                                            ? 'M'
                                            : 'L';
                                      }
                                      (context as Element).markNeedsBuild(); // Trigger rebuild to update dropdown
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('Section Preferences: $sectionPreferences');
                Navigator.pop(context);},
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

