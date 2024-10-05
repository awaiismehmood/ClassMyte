import 'package:classmyte/data_management/edit_contacts.dart';
import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Map<String, String> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        EditContactService.deleteContact(widget.student['id'] ?? '');
        Navigator.pop(context);
      } else {
        // print('Deletion canceled');
      }
    });
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

  void _selectDate(
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // Make the font size a bit larger
            fontWeight: FontWeight.bold,
          ),
        ),
           actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isEditableNotifier,
            builder: (context, isEditable, child) {
              return isEditable
                  ? IconButton(
                      icon: const Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                      onPressed: () => saveChanges(),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        isEditableNotifier.value = true; // Enable editing
                      },
                    );
            },
          ),
        ],
      ),
 
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingNotifier,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(
               decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue,
                            child: Text(
                              nameNotifier.value[0],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24),
                            )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: ListView(
                          children: [
                            Container(
                                decoration: BoxDecoration(

                                    border: Border.all(color: Colors.black)),
                                child: Column(
                                  children: [
                                    Container(
                                        child: _buildEditableTile(
                                            'Name', nameNotifier)),
                                    _buildEditableTile(
                                        'Father Name', fatherNameNotifier),
                                    _buildEditableTile('Class', classNotifier),
                                    _buildEditableTile(
                                        'Phone#', phoneNumberNotifier,
                                        isPhone: true),
                                    _buildEditableTile(
                                        'Alternate#', altNumberNotifier,
                                        isPhone: true),
                                    _buildDateTile(
                                        'Date of Birth', dobNotifier),
                                    _buildDateTile(
                                        'Admission Date', admissionNotifier),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: deleteStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEditableTile(String title, ValueNotifier<String> valueNotifier,
      {bool isPhone = false}) {
    TextEditingController controller = TextEditingController(
        text: valueNotifier
            .value); // Initialize controller with the current value

    return ValueListenableBuilder<bool>(
      valueListenable: isEditableNotifier,
      builder: (context, isEditable, child) {
        return ValueListenableBuilder<String>(
          valueListenable: valueNotifier,
          builder: (context, value, child) {
            if (isEditable) {
              controller.value = TextEditingValue(text: value);
            }
            return ListTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: isEditable
                  ? TextField(
                      controller: controller,
                      onChanged: (newValue) {
                        valueNotifier.value = newValue;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          isPhone ? TextInputType.phone : TextInputType.text,
                    )
                  : Text(
                      value,
                      style: const TextStyle(fontSize: 16),
                    ),
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
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: GestureDetector(
                onTap: isEditable
                    ? () => _selectDate(context, dateNotifier)
                    : null,
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
