import 'package:classmyte/Students/addcontact_dialouge.dart';
import 'package:classmyte/Students/filter_dialouge.dart';
import 'package:classmyte/ads/ads.dart';
import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:classmyte/services/functional.dart';
import 'package:classmyte/sms_screen/whatsapp_msg.dart';
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
  final adManager = AdManager();
  final SubscriptionData subscriptionData = SubscriptionData();
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getStudentData();
    await subscriptionData.checkSubscriptionStatus();
    if (!subscriptionData.isPremiumUser.value) {
      adManager.loadBannerAd(() {
        if (mounted && !subscriptionData.isPremiumUser.value) {
          setState(() {
            adLoaded = true; // Ad is loaded and user is not premium
          });
        }
      });
    }
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
  void dispose() {
    adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Students',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
            icon: const Icon(Icons.add, color: Colors.white),
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
                colors: [Colors.white, Colors.blueAccent],
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
                    style: TextStyle(
                      fontSize: screenWidth > 500
                          ? screenHeight * 0.022
                          : screenHeight * 0.018, // Responsive font size
                    ),
                    onChanged: _searchStudents,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3),
                        child: Text(
                          'Total Students: ${allStudentsNotifier.value.length}',
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3),
                        child:
                            ValueListenableBuilder<List<Map<String, String>>>(
                          valueListenable: studentListNotifier,
                          builder: (context, filteredList, child) {
                            return Text(
                              'Filtered Students: ${filteredList.length}',
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
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

                      if (screenWidth > 500) {
                        // Display as GridView for wider screens
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: studentList.length,
                          itemBuilder: (context, index) {
                            final student = studentList[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentDetailsScreen(student: student),
                                  ),
                                );
                                await getStudentData();
                              },
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
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
                                      const SizedBox(height: 12),
                                      Text(
                                        student['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Father Name: ${student['fatherName'] ?? ''}'),
                                      Text('Class: ${student['class'] ?? ''}'),
                                      Text(
                                          'Phone#: ${student['phoneNumber'] ?? ''}'),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.phone,
                                                color: Colors.blue),
                                            onPressed: () {
                                              makeCall(student['phoneNumber']!);
                                            },
                                          ),
                                          IconButton(
                                            icon: Image.asset(
                                                'assets/whatsapp.png',
                                                width: 24,
                                                height: 24),
                                            onPressed: () {
                                              WhatsAppMessaging()
                                                  .sendWhatsAppMessageIndividually(
                                                      student['phoneNumber']!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        // Display as ListView for narrower screens
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
                                        StudentDetailsScreen(student: student),
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
                                      const SizedBox(height: 12),
                                      Text(
                                        student['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Father Name: ${student['fatherName'] ?? ''}'),
                                      Text('Class: ${student['class'] ?? ''}'),
                                      Text(
                                          'Phone#: ${student['phoneNumber'] ?? ''}'),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.phone,
                                                color: Colors.blue),
                                            onPressed: () {
                                              makeCall(student['phoneNumber']!);
                                            },
                                          ),
                                          IconButton(
                                            icon: Image.asset(
                                                'assets/whatsapp.png',
                                                width: 24,
                                                height: 24),
                                            onPressed: () {
                                              WhatsAppMessaging()
                                                  .sendWhatsAppMessageIndividually(
                                                      student['phoneNumber']!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                if (adLoaded && !subscriptionData.isPremiumUser.value)
                  adManager.displayBannerAd(),
              ],
            ),
          );
        },
      ),
    );
  }
}
