class FilteringService {
  static List<Map<String, String>> filterByClasses(
    List<Map<String, String>> students,
    List<String> selectedClasses,
  ) {
    if (selectedClasses.isNotEmpty) {
      return students
          .where((student) => selectedClasses.contains(student['class']))
          .toList();
    } else {
      return students;
    }
  }
}
