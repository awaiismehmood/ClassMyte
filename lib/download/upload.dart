import 'dart:io';
import 'package:classmyte/data_management/add_contacts.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelImport {
  Future<void> importFromExcel() async {
    // Pick an Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      // Get the file path
      File file = File(result.files.single.path!);

      try {
        // Decode the Excel file
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        // Get the first sheet's name (ensure it exists)
        if (excel.tables.isEmpty) {
          print('No sheets found in Excel file.');
          return;
        }
        String sheetName = excel.tables.keys.first;
        var sheet = excel[sheetName];

        // Check if the sheet is empty
        if (sheet == null || sheet.rows.isEmpty) {
          print('No data found in the Excel sheet.');
          return;
        }

        print('Sheet Name: $sheetName');

        // Process each row, skip headers (index 0)
        for (var row in sheet.rows.skip(1)) {
          try {
            // Ensure row data exists and has required number of cells
            if (row.length < 7) {
              print('Skipping invalid or incomplete row: ${row.map((cell) => cell?.value).toList()}');
              continue;
            }

            // Parse each field and handle null values by reading as strings
            String name = row[0]?.value?.toString() ?? '';
            String classValue = row[1]?.value?.toString() ?? '';
            String phoneNumber = row[2]?.value?.toString() ?? '0';  // Convert to string
            String fatherName = row[3]?.value?.toString() ?? '';
            String DOB = row[4]?.value?.toString() ?? '';
            String admissionDate = row[5]?.value?.toString() ?? '';
            String altNumber = row[6]?.value?.toString() ?? '0';  // Convert to string

            // Validate critical fields (e.g., name or class cannot be empty)
            if (name.isEmpty || classValue.isEmpty) {
              print('Skipping row due to missing critical data: $name, $classValue');
              continue;
            }

            // Add the contact to the database
            await AddContactService.addContact(
              name,
              classValue,
              phoneNumber,
              fatherName,
              DOB,
              admissionDate,
              altNumber,
            );
            print('Successfully uploaded contact: $name');
          } catch (cellError) {
            print('Error processing row: ${row.map((cell) => cell?.value).toList()}');
            print('Row processing error: $cellError');
          }
        }
        print('All data uploaded successfully!');
      } catch (e) {
        print('Error decoding Excel file: $e');
      }
    } else {
      print('No file selected');
    }
  }
}
