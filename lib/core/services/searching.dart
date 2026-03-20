import 'package:classmyte/core/services/filtering.dart';

class SearchService {
  static List<Map<String, String>> searchStudents(
    List<Map<String, String>> students,
    String query, {
    List<String>? selectedClasses,
    int? selectedYear,
    int? selectedAge,
    bool showBirthdaysOnly = false,
  }) {
    // Apply filtering
    List<Map<String, String>> filteredStudents = FilteringService.filterStudents(
      students,
      selectedClasses: selectedClasses,
      selectedYear: selectedYear,
      selectedAge: selectedAge,
      showBirthdaysOnly: showBirthdaysOnly,
    );

    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      return filteredStudents.where((student) {
        final name = student['name']?.toLowerCase() ?? '';
        final phone = student['phoneNumber']?.toLowerCase() ?? '';
        return name.contains(lowercaseQuery) || phone.contains(lowercaseQuery);
      }).toList();
    } else {
      return filteredStudents;
    }
  }
}
