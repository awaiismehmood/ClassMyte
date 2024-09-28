// add_contact_dialog.dart

import 'package:classmyte/data_management/add_contacts.dart';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:flutter/material.dart';

class StudentDialogNotifier {
  ValueNotifier<String> name = ValueNotifier('');
  ValueNotifier<String> phoneNumber = ValueNotifier('');
  ValueNotifier<String> fatherName = ValueNotifier('');
  ValueNotifier<String> dob = ValueNotifier('');
  ValueNotifier<String> admissionDate = ValueNotifier('');
  ValueNotifier<String> altNumber = ValueNotifier('');
  ValueNotifier<String> selectedClass = ValueNotifier('');
  ValueNotifier<String> typedClass = ValueNotifier('');
}

void showAddContactDialog(BuildContext context, {Map<String, String>? student}) {
  final notifier = StudentDialogNotifier();

  if (student != null) {
    notifier.name.value = student['name'] ?? '';
    notifier.phoneNumber.value = student['phoneNumber'] ?? '';
    notifier.fatherName.value = student['fatherName'] ?? '';
    notifier.dob.value = student['DOB'] ?? '';
    notifier.admissionDate.value = student['Admission Date'] ?? '';
    notifier.altNumber.value = student['altNumber'] ?? '';
    notifier.selectedClass.value = student['class'] ?? '';
  }

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
              title: const Text('Add Contact'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: notifier.name,
                      builder: (context, value, child) {
                        return TextField(
                          onChanged: (newValue) {
                            notifier.name.value = newValue;
                          },
                          decoration: const InputDecoration(labelText: 'Name'),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<String>(
                            valueListenable: notifier.selectedClass,
                            builder: (context, selectedClassValue, child) {
                              return DropdownButtonFormField<String>(
                                value: selectedClassValue.isNotEmpty
                                    ? selectedClassValue
                                    : null,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    notifier.selectedClass.value = newValue;
                                    notifier.typedClass.value =
                                        ''; // Clear typed class
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
                                isExpanded: true,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ValueListenableBuilder<String>(
                            valueListenable: notifier.typedClass,
                            builder: (context, typedClassValue, child) {
                              return TextFormField(
                                onChanged: (value) {
                                  notifier.typedClass.value = value;
                                  notifier.selectedClass.value =
                                      ''; // Clear selected class
                                },
                                decoration: const InputDecoration(
                                  labelText: 'New Class',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: notifier.phoneNumber,
                      builder: (context, value, child) {
                        return TextField(
                          onChanged: (newValue) {
                            notifier.phoneNumber.value = newValue;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                        );
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: notifier.fatherName,
                      builder: (context, value, child) {
                        return TextField(
                          onChanged: (newValue) {
                            notifier.fatherName.value = newValue;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Father Name'),
                        );
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: notifier.dob,
                      builder: (context, value, child) {
                        return TextField(
                          onChanged: (newValue) {
                            notifier.dob.value = newValue;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Date of Birth'),
                        );
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: notifier.admissionDate,
                      builder: (context, value, child) {
                        return TextField(
                          onChanged: (newValue) {
                            notifier.admissionDate.value = newValue;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Admission Date'),
                        );
                      },
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: notifier.altNumber,
                      builder: (context, value, child) {
                        return TextField(
                          onChanged: (newValue) {
                            notifier.altNumber.value = newValue;
                          },
                          decoration:
                              const InputDecoration(labelText: 'Alt Number'),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Determine final class value
                    String finalClass = notifier.typedClass.value.isNotEmpty
                        ? notifier.typedClass.value
                        : notifier.selectedClass.value;

                    AddContactService.addContact(
                      notifier.name.value,
                      finalClass,
                      notifier.phoneNumber.value,
                      notifier.fatherName.value,
                      notifier.dob.value,
                      notifier.admissionDate.value,
                      notifier.altNumber.value,
                    );
                    Navigator.pop(context);
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
