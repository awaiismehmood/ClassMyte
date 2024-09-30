// StudentContactsScreen.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:classmyte/classes/deletion.dart';
import 'package:classmyte/classes/dialouge_test.dart';
import 'package:classmyte/contacts_screen/addcontact_dialouge.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  List<Map<String, String>> studentList = [];
  List<Map<String, String>> allStudents = [];
  List<String> allClasses = [];
  List<String> selectedClasses = [];

  @override
  void initState() {
    super.initState();
    getStudentData();
    requestPermissions();
  }

  Future<void> getStudentData() async {
    List<Map<String, String>> students = await StudentData.getStudentData();
    setState(() {
      studentList = students;
      allStudents = List.from(students);
      allClasses =
          allStudents.map((student) => student['class'] ?? '').toSet().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Classes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 5,
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.blue],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Total Classes: ${allClasses.length}',
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allClasses.length,
                      itemBuilder: (context, index) {
                        String className = allClasses[index];
                        int studentCount = allStudents
                            .where((student) => student['class'] == className)
                            .length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(TextSpan(
                                    text: 'Class: ${allClasses[index]}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Total students: $studentCount',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          const Icon(Icons.more_vert_outlined),
                                      onPressed: () {
                                        showEditDeleteDialog(
                                            context, allClasses, index);
                                      },
                                    ),
                                  ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    showAddContactDialog(context, getStudentData);
                  },
                  backgroundColor: const Color.fromARGB(255, 215, 214, 214),
                  child: const Icon(
                    Icons.add,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    // Request storage permissions
    final PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      final PermissionStatus permissionStatus =
          await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        'SMS permission denied. Please enable it to send messages.';
      }
      return;
    }
  }

  Future<void> downloadClassData(String className) async {
    // Retrieve all student data
    List<Map<String, String>> allStudents = await StudentData.getStudentData();
    List<Map<String, String>> classStudents =
        allStudents.where((student) => student['class'] == className).toList();

    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      if (classStudents.isNotEmpty) {
        // Prepare CSV data
        String csvData =
            "Name,Phone Number,Father's Name,Date of Birth,Admission Date,Alternate Phone Number\n";
        for (var student in classStudents) {
          csvData +=
              "${student['name']},${student['phone']},${student['fatherName']},${student['dob']},${student['admissionDate']},${student['altPhone']}\n";
        }

        // Get the Downloads directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get download directory.')),
          );
          return;
        }

        final downloadPath = "${directory.path}/Download";
        final filePath =
            "$downloadPath/${className.replaceAll(' ', '_')}_students.csv";
        // Create the Downloads directory if it doesn't exist
        final downloadDir = Directory(downloadPath);
        if (!(await downloadDir.exists())) {
          await downloadDir.create(recursive: true);
        }

        // Show download confirmation dialog
        bool confirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Download Student Data'),
            content: Text(
                'Are you sure you want to download student data for class "$className"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
            ],
          ),
        );

        if (confirmed) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              title: Text('Downloading...'),
              content: SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          );

          try {
            final File file = File(filePath);
            await file.writeAsString(csvData);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Student data downloaded to: $filePath')),
            );
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download failed: $e')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download canceled.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No students found in this class.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Storage permission is required to download files.')),
      );
    }
  }

  List<String> getUniqueClasses() {
    List<String> classes =
        allStudents.map((student) => student['class']!).toSet().toList();
    return classes;
  }

  void showEditDeleteDialog(
      BuildContext context, List<String> allClasses, int index) {
    String className = allClasses[index];
    // ignore: unused_local_variable
    int studentCount =
        allStudents.where((student) => student['class'] == className).length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context); // Close the current dialog or screen

                  // Open the UpdateClassDialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return UpdateClassDialog(
                        classes: allClasses, // List of classes
                        existingClass: className, // Current class name
                        allStudents: allStudents, // List of all students
                      );
                    },
                    
                  );
                getStudentData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  showDeleteClassDialog(context, className);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download Data'),
                onTap: () async {
                  Navigator.pop(context);
                  await downloadClassData(className);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
