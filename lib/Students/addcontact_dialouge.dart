// ignore_for_file: use_build_context_synchronously

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

  void selectDate(
      BuildContext context, ValueNotifier<String> dateNotifier) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateNotifier.value = "${picked.toLocal()}".split(' ')[0];
    }
  }

void showAddContactDialog(BuildContext context, Function refreshContacts,
    {Map<String, String>? student}) {
  final notifier = StudentDialogNotifier();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController altNumberController = TextEditingController();

  if (student != null) {
    nameController.text = student['name'] ?? '';
    phoneController.text = student['phoneNumber'] ?? '';
    fatherController.text = student['fatherName'] ?? '';
    notifier.dob.value = student['DOB'] ?? '';
    notifier.admissionDate.value = student['Admission Date'] ?? '';
    altNumberController.text = student['altNumber'] ?? '';
    notifier.selectedClass.value = student['class'] ?? '';
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<List<Map<String, String>>>(
        future: StudentData.getStudentData(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              title: Text('Loading....'),
              content: SizedBox(
                width: 150,
                height: 150,
                child: Center(child: CircularProgressIndicator(strokeWidth: 4.0)),
              ),
            );
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to load classes: ${snapshot.error}'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                    // Name input
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                       textCapitalization: TextCapitalization.words,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<String>(
                            valueListenable: notifier.selectedClass,
                            builder: (context, selectedClassValue, child) {
                              return DropdownButtonFormField<String>(
                                value: selectedClassValue.isNotEmpty ? selectedClassValue : null,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    notifier.selectedClass.value = newValue;
                                    notifier.typedClass.value = '';
                                  }
                                },
                                items: allClasses.map((classItem) {
                                  return DropdownMenuItem<String>(
                                    value: classItem,
                                    child: Text(classItem),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(labelText: 'Class'),
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
                                  notifier.selectedClass.value = '';
                                },
                                decoration: const InputDecoration(labelText: 'New Class'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: fatherController,
                      decoration: const InputDecoration(labelText: 'Father Name'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    TextField(
                      onTap: () => selectDate(context, notifier.dob),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(text: notifier.dob.value),
                    ),
                    TextField(
                      onTap: () => selectDate(context, notifier.admissionDate),
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Admission Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(text: notifier.admissionDate.value),
                    ),
                    TextField(
                      controller: altNumberController,
                      decoration: const InputDecoration(labelText: 'Alt Number'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name and Phone Number cannot be empty')),
                      );
                      return;
                    }

                    String finalClass = notifier.typedClass.value.isNotEmpty
                        ? notifier.typedClass.value
                        : notifier.selectedClass.value;
                    AddContactService.addContact(
                      nameController.text,
                      finalClass,
                      phoneController.text,
                      fatherController.text,
                      notifier.dob.value,
                      notifier.admissionDate.value,
                      altNumberController.text,
                    ).then((_) {
                      refreshContacts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact added successfully')),
                      );
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add contact: $error')),
                      );
                    });
                  },
                  child: const Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
