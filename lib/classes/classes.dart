// StudentContactsScreen.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:classmyte/classes/deletion.dart';
import 'package:classmyte/data_management/add_contacts.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/edit_contacts.dart';
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
                                      text: 'Class Name: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: allClasses[index],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ])),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Students in class: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '$studentCount',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                   
                                    IconButton(
                                      icon: const Icon(Icons.more_vert_outlined),
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
                    showAddContactDialog(context, allClasses);
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
      final PermissionStatus permissionStatus = await Permission.storage.request();
      if (!permissionStatus.isGranted) {
        'SMS permission denied. Please enable it to send messages.';
        }
        return;
      }
    }

Future<void> downloadClassData(String className) async {
  // Retrieve all student data
  List<Map<String, String>> allStudents = await StudentData.getStudentData();
  List<Map<String, String>> classStudents = allStudents.where((student) => student['class'] == className).toList();

  // Request storage permission
  var status = await Permission.storage.request();

  if (status.isGranted) {
    if (classStudents.isNotEmpty) {
      // Prepare CSV data
      String csvData = "Name,Phone Number,Father's Name,Date of Birth,Admission Date,Alternate Phone Number\n";
      for (var student in classStudents) {
        csvData += "${student['name']},${student['phone']},${student['fatherName']},${student['dob']},${student['admissionDate']},${student['altPhone']}\n";
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
      final filePath = "$downloadPath/${className.replaceAll(' ', '_')}_students.csv";

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
          content: Text('Are you sure you want to download student data for class "$className"?'),
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
        // Show download progress indicator
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
          // Write the file
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
      const SnackBar(content: Text('Storage permission is required to download files.')),
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
  int studentCount = allStudents
      .where((student) => student['class'] == className)
      .length;

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
                Navigator.pop(context);
                showAddContactDialog(
                  context,
                  allClasses,
                  existingClass: className,
                );
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


  void showAddContactDialog(BuildContext context, List<String> classes,
      {String? existingClass}) {
    String selectedClass = existingClass ?? '';
    TextEditingController classController =
        TextEditingController(text: selectedClass);
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController admissionController = TextEditingController();
  TextEditingController altPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, String>>>(
          future: StudentData.getStudentData(), // Fetch the student data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Loading'),
                content: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load classes: ${snapshot.error}'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            } else {
              // Data is successfully fetched
              List<Map<String, String>> allStudents = snapshot.data ?? [];
              List<String> allClasses = allStudents
                  .map((student) => student['class'] ?? '')
                  .toSet()
                  .toList();

               return AlertDialog(
              title: existingClass != null
                  ? const Text('Promote Class')
                  : const Text('Add New Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (existingClass == null) ...[
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: fatherNameController,
                        decoration: const InputDecoration(
                          labelText: 'Father\'s Name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: admissionController,
                        decoration: const InputDecoration(
                          labelText: 'Admission Date',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: altPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Alternate Phone Number',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    DropdownButtonFormField<String>(
                      value: selectedClass.isNotEmpty
                          ? selectedClass
                          : null,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedClass = newValue;
                          classController.text = newValue;
                        }
                      },
                      items: allClasses.map((classItem) {
                        return DropdownMenuItem<String>(
                          value: classItem,
                          child: Text(classItem),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: 'Class'),
                    ),
                    const SizedBox(height: 10),
                    if (existingClass == null) ...[
                      TextField(
                        controller: classController,
                        decoration: const InputDecoration(
                          labelText: 'Type new class',
                        ),
                        onChanged: (value) {
                          selectedClass = value;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AlertDialog(
                        title: Text('Updating Classes...'),
                        content: SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );

                    String finalClass = selectedClass;

                    if (existingClass != null) {
                      List<Future<void>> updateFutures = [];
                      for (var student in allStudents) {
                        if (student['class'] == existingClass) {
                          String? studentId = student['id'];
                          if (studentId != null) {
                            updateFutures.add(EditContactService.updateClass(
                                studentId, finalClass));
                          }
                        }
                      }

                      await Future.wait(updateFutures);
                    } else {
                      await AddContactService.addContact(
                        nameController.text,
                        finalClass,
                        phoneController.text,
                        fatherNameController.text,
                        dobController.text,
                        admissionController.text,
                        altPhoneController.text,
                      );
                    }

                    // Close the dialogs and refresh data
                    Navigator.pop(context);
                    Navigator.pop(context);
                    getStudentData();
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          }
        },
      );
    },
  );
}}