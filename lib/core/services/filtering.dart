import 'package:classmyte/features/students/models/student_model.dart';
import 'package:classmyte/core/services/student_utils.dart';

class FilteringService {
  static List<Student> filterStudents(
    List<Student> students, {
    List<String>? selectedClasses,
    int? selectedYear,
    int? selectedAge,
    bool showBirthdaysOnly = false,
    String? selectedStatus,
  }) {
    return students.where((student) {
      bool matchesClass = selectedClasses == null ||
          selectedClasses.isEmpty ||
          selectedClasses.contains(student.className);

      bool matchesYear = selectedYear == null ||
          selectedYear == 0 ||
          StudentUtils.extractYear(student.admissionDate) == selectedYear;

      bool matchesAge = selectedAge == null ||
          selectedAge == 0 ||
          StudentUtils.calculateAge(student.dob) == selectedAge;

      bool matchesBirthday = !showBirthdaysOnly || StudentUtils.isBirthdayToday(student.dob);

      bool matchesStatus = selectedStatus == null ||
          selectedStatus == 'All' ||
          student.status == selectedStatus;

      return matchesClass && matchesYear && matchesAge && matchesBirthday && matchesStatus;
    }).toList();
  }
}
