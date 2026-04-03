// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:classmyte/core/data/add_contacts.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelImport {
  Future<void> importFromExcel() async {
    // Pick an Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      try {
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        if (excel.tables.isEmpty) return;
        
        String sheetName = excel.tables.keys.first;
        var sheet = excel[sheetName];

        if (sheet == null || sheet.rows.isEmpty) return;

        // 1. Identify Column Map
        final headerRow = sheet.rows.first;
        final indexMap = <String, int>{};

        for (int i = 0; i < headerRow.length; i++) {
          final val = headerRow[i]?.value?.toString().toLowerCase() ?? '';
          if (val.contains('name') && !val.contains('father')) indexMap['name'] = i;
          else if (val.contains('class')) indexMap['class'] = i;
          else if (val.contains('phone') || val.contains('number') || val.contains('contact')) {
             if (val.contains('alt') || val.contains('secondary')) indexMap['alt'] = i;
             else indexMap['phone'] = i;
          }
          else if (val.contains('father')) indexMap['father'] = i;
          else if (val.contains('dob') || val.contains('birth')) indexMap['dob'] = i;
          else if (val.contains('admission')) indexMap['admission'] = i;
        }

        // Required Check
        if (indexMap['name'] == null || indexMap['phone'] == null) {
           // Fallback to old behavior if headers not found? 
           // Better to warn the user, but for now let's try to be smart.
        }

        // 2. Process Data Rows
        for (var row in sheet.rows.skip(1)) {
          try {
            String getValue(String key, {String def = ''}) {
              final idx = indexMap[key];
              if (idx != null && idx < row.length) {
                return row[idx]?.value?.toString() ?? def;
              }
              return def;
            }

            String name = getValue('name');
            String classValue = getValue('class', def: 'General');
            String phoneNumber = getValue('phone', def: '0');
            String fatherName = getValue('father');
            String dob = getValue('dob');
            String admissionDate = getValue('admission');
            String altNumber = getValue('alt', def: '0');

            if (name.isEmpty || phoneNumber == '0') continue;

            await AddContactService.addContact(
              name,
              classValue,
              phoneNumber,
              fatherName,
              dob,
              admissionDate,
              altNumber,
            );
          } catch (e) {
            // Log error for specific row
          }
        }
      } catch (e) {
         // Log global error
      }
    }
  }
}
