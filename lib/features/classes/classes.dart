import 'package:classmyte/core/providers/providers.dart';
import 'package:classmyte/features/classes/deletion.dart';
import 'package:classmyte/features/classes/promotion.dart';
import 'package:classmyte/features/students/addcontact_dialouge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassScreen extends ConsumerWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentDataAsync = ref.watch(studentDataProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremiumUser;
    final adManager = ref.read(adManagerProvider);

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
        title: const Text('Classes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddContactDialog(context, () => ref.invalidate(studentDataProvider)),
          ),
        ],
      ),
      body: studentDataAsync.when(
        data: (allStudents) {
          final allClasses = allStudents.map((s) => s['class'] ?? '').toSet().toList();
          return Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  child: Text('Total Classes: ${allClasses.length}', style: const TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allClasses.length,
                    itemBuilder: (context, index) {
                      final className = allClasses[index];
                      final studentCount = allStudents.where((s) => s['class'] == className).length;
                      return _buildClassCard(context, ref, className, studentCount, allClasses, allStudents);
                    },
                  ),
                ),
                if (!isPremium) adManager.displayBannerAd(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, WidgetRef ref, String className, int count, List<String> allClasses, List<Map<String, String>> allStudents) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text('Class: $className', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
          subtitle: Text('Total students: $count', style: const TextStyle(fontSize: 16, color: Colors.black54)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (cx) => UpdateClassDialog(
                    classes: allClasses,
                    existingClass: className,
                    allStudents: allStudents,
                    // Note: UpdateClassDialog might need refactoring too if it uses a notifier
                    onUpdate: () => ref.invalidate(studentDataProvider),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => showDeleteClassDialog(context, className, () => ref.invalidate(studentDataProvider)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
