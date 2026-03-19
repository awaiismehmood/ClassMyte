import 'package:classmyte/core/services/student_utils.dart';

class FilteringService {
  static List<Map<String, String>> filterStudents(
    List<Map<String, String>> students, {
    List<String>? selectedClasses,
    int? selectedYear,
    int? selectedAge,
  }) {
    return students.where((student) {
      bool matchesClass = selectedClasses == null ||
          selectedClasses.isEmpty ||
          selectedClasses.contains(student['class']);

      bool matchesYear = selectedYear == null ||
          selectedYear == 0 ||
          StudentUtils.extractYear(student['Admission Date']) == selectedYear;

      bool matchesAge = selectedAge == null ||
          selectedAge == 0 ||
          StudentUtils.calculateAge(student['DOB']) == selectedAge;

      return matchesClass && matchesYear && matchesAge;
    }).toList();
  }

  // Deprecated usage, will be cleaned up
  static List<Map<String, String>> filterByClasses(
    List<Map<String, String>> students,
    List<String> selectedClasses,
  ) {
    return filterStudents(students, selectedClasses: selectedClasses);
  }
}
