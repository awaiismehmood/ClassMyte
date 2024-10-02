// filter_dialog.dart

import 'package:flutter/material.dart';

class FilterDialog {
  static Future<void> show(
    BuildContext context, {
    required List<String> allClasses,
    required List<String> selectedClasses,
    required Function onApply,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter by Class'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      children: allClasses.map((classValue) {
                        return ChoiceChip(
                          label: Text(classValue),
                          selected: selectedClasses.contains(classValue),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedClasses.add(classValue);
                              } else {
                                selectedClasses.remove(classValue);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        onApply();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}