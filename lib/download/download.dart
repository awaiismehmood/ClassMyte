import 'dart:io';
import 'package:classmyte/data_management/data_retrieval.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ExcelExport {
  Future<void> exportToExcel() async {
    // Check and request storage permission
    if (await requestStoragePermission()) {
      // Fetch data from Firestore
      List<Map<String, String>> studentData = await StudentData.getStudentData();

      // Create a new Excel document
      var excel = Excel.createExcel();
      
      // Access the default sheet (Sheet1)
      Sheet sheetObject = excel.sheets[excel.getDefaultSheet()]!;

      // Create headers
      List<String> headers = [
        'Name',
        'Class',
        'Phone Number',
        'Father Name',
        'DOB',
        'Admission Date',
        'Alt Number',
      ];
      sheetObject.appendRow(headers.map((header) => TextCellValue(header)).toList());

      // Add data to the sheet as plain text
      for (var student in studentData) {
        List<CellValue?> row = [
          TextCellValue(student['name'] ?? ''),
          TextCellValue(student['class'] ?? ''),
          TextCellValue(student['phoneNumber'] ?? ''),  // Store as text
          TextCellValue(student['fatherName'] ?? ''),
          TextCellValue(student['DOB'] ?? ''),
          TextCellValue(student['Admission Date'] ?? ''),
          TextCellValue(student['altNumber'] ?? ''),  // Store as text
        ];
        sheetObject.appendRow(row);
      }

      // Use File Picker to choose a save location
      String? path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
        String filePath = '$path/StudentContacts.xlsx';
        try {
          await File(filePath).writeAsBytes(await excel.encode()!);
          print('Excel file saved at $filePath');
        } catch (e) {
          print('Error saving file: $e');
        }
      } else {
        print('No directory selected');
      }
    } else {
      print('Permission denied');
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid && await Permission.manageExternalStorage.isGranted) {
      return true;
    } else if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      } else {
        if (await Permission.manageExternalStorage.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    } else {
      var status = await Permission.storage.request();
      return status.isGranted;
    }
  }
}
