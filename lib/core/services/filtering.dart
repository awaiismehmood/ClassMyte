import 'package:classmyte/core/services/student_utils.dart';

class FilteringService {
  static List<Map<String, String>> filterStudents(
    List<Map<String, String>> students, {
    List<String>? selectedClasses,
    int? selectedYear,
    int? selectedAge,
    bool showBirthdaysOnly = false,
    String? selectedStatus,
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

      bool matchesBirthday = !showBirthdaysOnly || StudentUtils.isBirthdayToday(student['DOB']);

      bool matchesStatus = selectedStatus == null ||
          selectedStatus == 'All' ||
          (student['status'] ?? 'Active') == selectedStatus;

      return matchesClass && matchesYear && matchesAge && matchesBirthday && matchesStatus;
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
