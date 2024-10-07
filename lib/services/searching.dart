import 'package:classmyte/services/filtering.dart';

class SearchService {
  static List<Map<String, String>> searchStudents(
    List<Map<String, String>> students,
    String query, {
    List<String>? selectedClasses,
  }) {
    // Filter by classes if selectedClasses is not null and not empty
    List<Map<String, String>> filteredStudents = students;
    if (selectedClasses != null && selectedClasses.isNotEmpty) {
      filteredStudents =
          FilteringService.filterByClasses(students, selectedClasses);
    }

    if (query.isNotEmpty) {
      return filteredStudents.where((student) {
        return student['name']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      return filteredStudents;
    }
  }
}
