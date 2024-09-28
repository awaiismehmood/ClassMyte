import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:classmyte/data_management/edit_contacts.dart';
import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Map<String, String> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  // ValueNotifiers for student data
  late final ValueNotifier<String> nameNotifier;
  late final ValueNotifier<String> fatherNameNotifier;
  late final ValueNotifier<String> classNotifier;
  late final ValueNotifier<String> phoneNumberNotifier;
  late final ValueNotifier<String> altNumberNotifier;
  late final ValueNotifier<String> dobNotifier;
  late final ValueNotifier<String> admissionNotifier;

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(true);
  final ValueNotifier<bool> isEditableNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    nameNotifier = ValueNotifier(widget.student['name'] ?? '');
    fatherNameNotifier = ValueNotifier(widget.student['fatherName'] ?? '');
    classNotifier = ValueNotifier(widget.student['class'] ?? '');
    phoneNumberNotifier = ValueNotifier(widget.student['phoneNumber'] ?? '');
    altNumberNotifier = ValueNotifier(widget.student['altNumber'] ?? '');
    dobNotifier = ValueNotifier(widget.student['DOB'] ?? '');
    admissionNotifier = ValueNotifier(widget.student['Admission Date'] ?? '');
    getStudentData();
  }

 void deleteStudent() {
    EditContactService.deleteContact(widget.student['id'] ?? '');
    Navigator.pop(context);
  }

  void saveChanges() {
    EditContactService.updateContact(
      widget.student['id'] ?? '',
      nameNotifier.value,
      classNotifier.value,
      phoneNumberNotifier.value,
      fatherNameNotifier.value,
      dobNotifier.value,
      admissionNotifier.value,
      altNumberNotifier.value,
    );
    isEditableNotifier.value = false;
    getStudentData(); 
    Navigator.pop(context); 
  }

  Future<void> getStudentData() async {
    await Future.delayed(const Duration(seconds: 1));
    isLoadingNotifier.value = false;
  }

  void _selectDate(BuildContext context, ValueNotifier<String> dateNotifier) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student['name']!),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              isEditableNotifier.value = true; // Enable editing
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => saveChanges(),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingNotifier,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.student['profilePictureUrl'] != null
                        ? NetworkImage(widget.student['profilePictureUrl']!)
                        : null,
                    child: widget.student['profilePictureUrl'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildEditableTile('Father Name', fatherNameNotifier),
                        _buildEditableTile('Class', classNotifier),
                        _buildEditableTile('Phone#', phoneNumberNotifier, isPhone: true),
                        _buildEditableTile('Alternate#', altNumberNotifier, isPhone: true),
                        _buildDateTile('Date of Birth', dobNotifier),
                        _buildDateTile('Admission Date', admissionNotifier),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: deleteStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }


  Widget _buildEditableTile(String title, ValueNotifier<String> valueNotifier, {bool isPhone = false}) {
    return ValueListenableBuilder<bool>(
      valueListenable: isEditableNotifier,
      builder: (context, isEditable, child) {
        return ValueListenableBuilder<String>(
          valueListenable: valueNotifier,
          builder: (context, value, child) {
            return ListTile(
              title: Text(title),
              subtitle: isEditable
                  ? TextField(
                      onChanged: (newValue) {
                        valueNotifier.value = newValue;
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter $title',
                      ),
                      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
                    )
                  : Text(value, style: const TextStyle(fontSize: 16)),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTile(String title, ValueNotifier<String> dateNotifier) {
    return ValueListenableBuilder<bool>(
      valueListenable: isEditableNotifier,
      builder: (context, isEditable, child) {
        return ValueListenableBuilder<String>(
          valueListenable: dateNotifier,
          builder: (context, value, child) {
            return ListTile(
              title: Text(title),
              subtitle: GestureDetector(
                onTap: isEditable ? () => _selectDate(context, dateNotifier) : null,
                child: Text(
                  value.isNotEmpty ? value : 'Select $title',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
