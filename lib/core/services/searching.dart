import 'package:classmyte/features/students/models/student_model.dart';
import 'package:classmyte/core/services/filtering.dart';

class SearchService {
  static List<Student> searchStudents(
    List<Student> students,
    String query, {
    List<String>? selectedClasses,
    int? selectedYear,
    int? selectedAge,
    bool showBirthdaysOnly = false,
    String? selectedStatus,
  }) {
    // Apply filtering
    List<Student> filteredStudents = FilteringService.filterStudents(
      students,
      selectedClasses: selectedClasses,
      selectedYear: selectedYear,
      selectedAge: selectedAge,
      showBirthdaysOnly: showBirthdaysOnly,
      selectedStatus: selectedStatus,
    );

    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      return filteredStudents.where((student) {
        final name = student.name.toLowerCase();
        final phone = student.phoneNumber.toLowerCase();
        return name.contains(lowercaseQuery) || phone.contains(lowercaseQuery);
      }).toList();
    } else {
      return filteredStudents;
    }
  }
}
