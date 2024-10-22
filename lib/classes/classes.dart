// ignore_for_file: library_private_types_in_public_api

import 'package:classmyte/ads/ads.dart';
import 'package:classmyte/classes/deletion.dart';
import 'package:classmyte/classes/promotion.dart';
import 'package:classmyte/Students/addcontact_dialouge.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:flutter/material.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  ValueNotifier<List<String>> allClassesNotifier = ValueNotifier([]);
  List<Map<String, String>> allStudents = [];
  final adManager = AdManager();
  final SubscriptionData subscriptionData = SubscriptionData();
    bool adLoaded = false;

@override
void initState() {
  super.initState();
  _initializeData();
}

Future<void> _initializeData() async {
  await subscriptionData.checkSubscriptionStatus(); // Ensure this completes first
  if (!subscriptionData.isPremiumUser.value) {
    adManager.loadBannerAd(() {
        if (mounted && !subscriptionData.isPremiumUser.value) {
          setState(() {
            adLoaded = true;  // Ad is loaded and user is not premium
          });
        }
      });
    }
    await getStudentData();
  }

  Future<void> getStudentData() async {
    List<Map<String, String>> students = await StudentData.getStudentData();
    allStudents = students;
    allClassesNotifier.value =
        students.map((student) => student['class'] ?? '').toSet().toList();
  }

  @override
  void dispose() {
    allClassesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
          'Classes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showAddContactDialog(context, getStudentData);
            },
          ),
        ],
      ),
      body: Container(
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ValueListenableBuilder<List<String>>(
                valueListenable: allClassesNotifier,
                builder: (context, allClasses, child) {
                  return Text(
                    'Total Classes: ${allClasses.length}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: allClassesNotifier,
                builder: (context, allClasses, child) {
                  return ListView.builder(
                    itemCount: allClasses.length,
                    itemBuilder: (context, index) {
                      String className = allClasses[index];
                      int studentCount = allStudents
                          .where((student) => student['class'] == className)
                          .length;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(
                              'Class: $className',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                            subtitle: Text(
                              'Total students: $studentCount',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return UpdateClassDialog(
                                          classes: allClasses,
                                          existingClass: className,
                                          allStudents: allStudents,
                                          allClassesNotifier:
                                              allClassesNotifier,
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    showDeleteClassDialog(
                                      context,
                                      className,
                                      allClassesNotifier,
                                    );
                                  },
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

              // Display ad only if it has loaded and user is not premium
            if (adLoaded && !subscriptionData.isPremiumUser.value)
              adManager.displayBannerAd(),
          ],
        ),
      ),
    );
  }
}
