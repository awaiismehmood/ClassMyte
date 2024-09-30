import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/edit_contacts.dart';
import 'package:flutter/material.dart';

class UpdateClassDialog extends StatefulWidget {
  final List<String> classes;
  final String existingClass;
  final List<Map<String, String>> allStudents;

  const UpdateClassDialog({
    super.key,
    required this.classes,
    required this.existingClass,
    required this.allStudents,
  });

  @override
  _UpdateClassDialogState createState() => _UpdateClassDialogState();
}

class _UpdateClassDialogState extends State<UpdateClassDialog> {
  late String selectedClass; 
  final TextEditingController newClassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedClass = widget.existingClass; // Initialize selected class
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Class'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedClass,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedClass = newValue; // Update selected class
                  });
                }
              },
              items: widget.classes.map((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem,
                  child: Text(classItem),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Class'),
            ),
            TextField(
              controller: newClassController,
              decoration: const InputDecoration(
                labelText: 'New Class Name (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            String newClassName = newClassController.text.trim();
            if (newClassName.isEmpty && selectedClass == widget.existingClass) {
              // Show feedback if nothing is selected or provided
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a new class or enter a new name.')),
              );
              return;
            }

            // Promote students
            await promoteStudents(widget.existingClass, newClassName.isNotEmpty ? newClassName : selectedClass);
            Navigator.pop(context);
            await StudentData.getStudentData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Students promoted successfully.')),
            );
          },
          child: const Text('Promote Students'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> promoteStudents(String fromClass, String toClass) async {
    List<String> studentIdsToUpdate = [];

    for (var student in widget.allStudents) {
      if (student['class'] == fromClass) {
        String? studentId = student['id'];
        if (studentId != null) {
          studentIdsToUpdate.add(studentId);
        }
      }
    }

    if (studentIdsToUpdate.isNotEmpty) {
      for (var studentId in studentIdsToUpdate) {
        await EditContactService.updateClass(studentId, toClass);
      }
    }

    await StudentData.getStudentData();
  }
}
