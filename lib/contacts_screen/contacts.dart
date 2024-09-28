import 'package:classmyte/contacts_screen/addcontact_dialouge.dart';
import 'package:classmyte/contacts_screen/filter_dialouge.dart';
import 'package:classmyte/services/functional.dart';
import 'package:classmyte/student%20details/student_details.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:flutter/material.dart';

class StudentContactsScreen extends StatefulWidget {
  const StudentContactsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentContactsScreenState createState() => _StudentContactsScreenState();
}

class _StudentContactsScreenState extends State<StudentContactsScreen> {
  final ValueNotifier<List<Map<String, String>>> studentListNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, String>>> allStudentsNotifier =
      ValueNotifier([]);

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<String>> selectedClassesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    getStudentData();
  }


  Future<void> getStudentData() async {
    isLoadingNotifier.value = true;
    List<Map<String, String>> students = await StudentData.getStudentData();
    allStudentsNotifier.value = students;
    studentListNotifier.value = List.from(students);
    isLoadingNotifier.value = false;
  }

  void _searchStudents(String query) {
    List<Map<String, String>> filteredList = SearchService.searchStudents(
      allStudentsNotifier.value,
      query,
      selectedClasses: selectedClassesNotifier.value,
    );
    studentListNotifier.value = filteredList;
  }

  void _applyFiltering() {
    studentListNotifier.value = FilteringService.filterByClasses(
      allStudentsNotifier.value,
      selectedClassesNotifier.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'STUDENTS',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
          elevation: 5,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                FilterDialog.show(
                  context,
                  allClasses: getUniqueClasses(allStudentsNotifier.value),
                  selectedClasses: selectedClassesNotifier.value,
                  onApply: _applyFiltering,
                );
              },
            ),
            IconButton(
              onPressed: () => showAddContactDialog(context, getStudentData),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: isLoadingNotifier,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onChanged: _searchStudents,
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, String>>>(
                      valueListenable: studentListNotifier,
                      builder: (context, studentList, child) {
                        if (studentList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No contacts available!',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: studentList.length,
                          itemBuilder: (context, index) {
                            final student = studentList[index];
                            return GestureDetector(
                              onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StudentDetailsScreen(
                                              student: student),
                                    ),
                                  );
                                  await getStudentData();
                                },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // CircleAvatar in the center
                                      Center(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.blue,
                                          child: Text(
                                            student['name']![0],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12), // Spacing

                                      // Student details
                                      Text(
                                        student['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Father: ${student['fatherName'] ?? ''}'),
                                      Text('Class: ${student['class'] ?? ''}'),
                                      Text(
                                          'Phone: ${student['phoneNumber'] ?? ''}'),
                                      Text(
                                          'Alternate: ${student['altNumber'] ?? ''}'),

                                      // Call Icon Button on bottom-right
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.phone,
                                              color: Colors.blue),
                                          onPressed: () {
                                            makeCall(student['phoneNumber']!);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
