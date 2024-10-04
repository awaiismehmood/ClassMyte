// ignore_for_file: library_private_types_in_public_api

import 'package:classmyte/classes/deletion.dart';
import 'package:classmyte/classes/promotion.dart';
import 'package:classmyte/Students/addcontact_dialouge.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/getSubscribe.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  ValueNotifier<List<String>> allClassesNotifier = ValueNotifier([]);
  List<Map<String, String>> allStudents = [];
  BannerAd? _bannerAd;
  final SubscriptionData subscriptionData = SubscriptionData(); // Instance of SubscriptionData

  @override
  void initState() {
    super.initState();
    getStudentData();
    subscriptionData.checkSubscriptionStatus(); // Check subscription status on init
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Load ad only if user is not premium
    if (!subscriptionData.isPremiumUser.value) {
      _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {});
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      _bannerAd!.load();
    }
  }

  Future<void> getStudentData() async {
    List<Map<String, String>> students = await StudentData.getStudentData();
    allStudents = students;
    allClassesNotifier.value = students.map((student) => student['class'] ?? '').toSet().toList();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    allClassesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
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
                              vertical: 4.0,
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Class: $className',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      'Total students: $studentCount',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                                  allClassesNotifier: allClassesNotifier,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            showDeleteClassDialog(
                                                context, className, allClassesNotifier);
                                          },
                                        ),
                                      ],
                                    )
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
          ),
          if (_bannerAd != null && !subscriptionData.isPremiumUser.value) // Only show ad if not premium
         
            Positioned(
              bottom: 0,
              child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        
        ],
      ),
    );
  }
}
