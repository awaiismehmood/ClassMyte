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
        var excel = Excel.decodeBytes(bytes); // Wrap in try-catch

        // Dynamically get the first sheet name if not known
        String sheetName = excel.tables.keys.first;
        var sheet = excel[sheetName];

        print('Sheet Name: $sheetName');

        // Check if sheet exists
        if (sheet == null) {
          print('No sheet found in Excel file.');
          return;
        }

        // Read rows from the sheet
        for (var row in sheet.rows.skip(1)) {
          print('Row data: ${row.map((cell) => cell?.value).toList()}');

          // Extract fields as before
          String name = row[0]?.value?.toString() ?? '';
          String classValue = row[1]?.value?.toString() ?? '';
          String phoneNumber = row[2]?.value?.toString() ?? '0';
          String fatherName = row[3]?.value?.toString() ?? '';
          String DOB = row[4]?.value?.toString() ?? '';
          String admission = row[5]?.value?.toString() ?? '';
          String altNumber = row[6]?.value?.toString() ?? '';

          // Add the contact to the database
          await AddContactService.addContact(
            name,
            classValue,
            phoneNumber,
            fatherName,
            DOB,
            admission,
            altNumber,
          );
        }
        print('Data uploaded successfully!');
      } catch (e) {
        // Handle Excel parsing exceptions
        print('Error decoding Excel file: $e');
      }
    } else {
      print('No file selected');
    }
  }
}
