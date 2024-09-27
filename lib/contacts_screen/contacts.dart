// StudentContactsScreen.dart

import 'package:classmyte/data_management/add_contacts.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/edit_contacts.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/filtering.dart';
import '../services/searching.dart';

class StudentContactsScreen extends StatefulWidget {
  const StudentContactsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentContactsScreenState createState() => _StudentContactsScreenState();
}

class _StudentContactsScreenState extends State<StudentContactsScreen> {
  List<Map<String, String>> studentList = [];
  List<Map<String, String>> allStudents = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedClasses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getStudentData();
  }

  Future<void> getStudentData() async {
    List<Map<String, String>> students = await StudentData.getStudentData();
    setState(() {
      studentList = students;
      allStudents = List.from(students);
      isLoading = false;
    });
  }

  void _searchStudents(String query) {
    setState(() {
      studentList = SearchService.searchStudents(
        allStudents,
        query,
        selectedClasses: selectedClasses,
      );
    });
  }

  void _applyFiltering() {
    setState(() {
      studentList =
          FilteringService.filterByClasses(allStudents, selectedClasses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'STUDENTS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 5,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.filter_alt,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Filter by Class'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8.0,
                                  children:
                                      getUniqueClasses().map((classValue) {
                                    return ChoiceChip(
                                      label: Text(classValue),
                                      selected:
                                          selectedClasses.contains(classValue),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedClasses.add(classValue);
                                          } else {
                                            selectedClasses.remove(classValue);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: () {
                                    _applyFiltering();
                                    _searchController.clear();
                                    Navigator.pop(context);
                                    setState(() {
                                      selectedClasses.clear();
                                    });
                                  },
                                  child: const Text('Apply'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            IconButton(
              onPressed: () => showAddContactDialog(context),
              icon: const Icon(Icons.add_box_outlined),
              color: Colors.white,
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.lightBlue],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(22)),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Search',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                        ),
                        onChanged: _searchStudents,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Total: ${allStudents.length}',
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Selected: ${studentList.length}',
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: isLoading // Check loading state
                        ? const Center(child: CircularProgressIndicator())
                        : studentList.isEmpty // Check if studentList is empty
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No contacts!!!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: studentList.length,
                                itemBuilder: (context, index) {
                                  final student = studentList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 4,
                                      child: ListTile(
                                        onTap: () {
                                          showContactDetailsDialog(
                                              context, student);
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        title: Text(
                                          student['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(TextSpan(
                                                text: 'Father Name: ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        student['fatherName'] ??
                                                            '',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ])),
                                            Text.rich(TextSpan(
                                                text: 'Class: ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        student['class'] ?? '',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ])),
                                            Text.rich(TextSpan(
                                                text: 'Phone#: ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: student[
                                                            'phoneNumber'] ??
                                                        '',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ])),
                                            Text.rich(TextSpan(
                                                text: 'Alternate#: ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        student['altNumber'] ??
                                                            '',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ])),
                                          ],
                                        ),
                                        trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  showEditDeleteDialog(
                                                      context, student);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.call),
                                                onPressed: () {
                                                  makeCall(
                                                      student['phoneNumber']!);
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
            // Positioned(
            //   bottom: 20,
            //   right: 20,
            //   child: SizedBox(
            //     width: 50,
            //     height: 50,
            //     child: FloatingActionButton(
            //       onPressed: () {
            //         showAddContactDialog(context);
            //       },
            //       backgroundColor: const Color.fromARGB(255, 215, 214, 214),
            //       child: const Icon(
            //         Icons.add,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void showContactDetailsDialog(
      BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student['name']!),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Father Name: ${student['fatherName'] ?? ''}'),
                Text('Class: ${student['class'] ?? ''}'),
                Text('Phone#: ${student['phoneNumber'] ?? ''}'),
                Text('Alternate#: ${student['altNumber'] ?? ''}'),
                Text('Date of Birth: ${student['DOB'] ?? ''}'),
                Text('Admission Date: ${student['Admission Date'] ?? ''}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<String> getUniqueClasses() {
    List<String> classes =
        allStudents.map((student) => student['class']!).toSet().toList();
    return classes;
  }

  void showEditDeleteDialog(BuildContext context, Map<String, String> student) {
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
                  showAddContactDialog(context, student: student);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  EditContactService.deleteContact(student['id'] ?? '');
                  getStudentData();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showAddContactDialog(BuildContext context,
      {Map<String, String>? student}) {
    final TextEditingController nameController = TextEditingController(
        text: student != null ? student['name'] ?? '' : '');
    final TextEditingController phoneNumberController = TextEditingController(
        text: student != null ? student['phoneNumber'] ?? '' : '');
    final TextEditingController fatherNameController = TextEditingController(
        text: student != null ? student['fatherName'] ?? '' : '');
    final TextEditingController dobController = TextEditingController(
        text: student != null ? student['DOB'] ?? '' : '');
    final TextEditingController admissionController = TextEditingController(
        text: student != null ? student['Admission Date'] ?? '' : '');
    final TextEditingController altNumberController = TextEditingController(
        text: student != null ? student['altNumber'] ?? '' : '');

    String selectedClass = student != null ? student['class'] ?? '' : '';
    TextEditingController classController =
        TextEditingController(text: selectedClass);
    String typedClass = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, String>>>(
          future: StudentData.getStudentData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Loading....'),
                content: SizedBox(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 4.0,
                    ),
                  ),
                ),
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
              List<Map<String, String>> allStudents = snapshot.data ?? [];
              List<String> allClasses = allStudents
                  .map((student) => student['class'] ?? '')
                  .toSet()
                  .toList();

              return AlertDialog(
                title: student != null
                    ? const Text('Edit Contact')
                    : const Text('Add Contact'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Dropdown for selecting an existing class
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedClass.isNotEmpty
                                  ? selectedClass
                                  : null,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedClass = newValue;
                                    classController.text =
                                        newValue; // Synchronize with Text
                                  });
                                }
                              },
                              items: allClasses.map((classItem) {
                                return DropdownMenuItem<String>(
                                  value: classItem,
                                  child: Text(classItem),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Class',
                              ),
                              isExpanded:
                                  true, // Ensure dropdown expands to avoid overflow
                            ),
                          ),

                          const SizedBox(
                              width:
                                  8), // Add space between dropdown and text field

                          // Text field for typing in a new class
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: classController,
                              onChanged: (value) {
                                setState(() {
                                  typedClass =
                                      value; // Store the new class being typed
                                  selectedClass =
                                      ''; // Clear the selected class from dropdown
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'New Class',
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: phoneNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                      ),
                      TextField(
                        controller: fatherNameController,
                        decoration:
                            const InputDecoration(labelText: 'Father Name'),
                      ),
                      TextField(
                        controller: dobController,
                        decoration:
                            const InputDecoration(labelText: 'Date of Birth'),
                      ),
                      TextField(
                        controller: admissionController,
                        decoration:
                            const InputDecoration(labelText: 'Admission Date'),
                      ),
                      TextField(
                        controller: altNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Alt Number'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Determine final class value
                      String finalClass =
                          typedClass.isNotEmpty ? typedClass : selectedClass;

                      if (student == null) {
                        // Add new contact logic
                        AddContactService.addContact(
                          nameController.text,
                          finalClass,
                          phoneNumberController.text,
                          fatherNameController.text,
                          dobController.text,
                          admissionController.text,
                          altNumberController.text,
                        );
                      } else {
                        // Edit contact logic
                        EditContactService.updateContact(
                          student['id'] ?? '',
                          nameController.text,
                          finalClass,
                          phoneNumberController.text,
                          fatherNameController.text,
                          dobController.text,
                          admissionController.text,
                          altNumberController.text,
                        );
                      }
                      Navigator.pop(context);
                      // Call function to refresh student data
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
  }

  void makeCall(String phoneNumber) async {
    final Uri call = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    // ignore: deprecated_member_use
    if (await canLaunch(call.toString())) {
      // ignore: deprecated_member_use
      await launch(call.toString());
    }
  }
}
