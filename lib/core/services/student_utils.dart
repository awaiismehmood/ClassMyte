class StudentUtils {
  static int calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty || dobString == 'Not set') {
      return 0;
    }
    try {
      // Assuming DOB format is yyyy-MM-dd or similar
      final birthDate = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  static int extractYear(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'Not set') {
      return 0;
    }
    try {
      final date = DateTime.parse(dateString);
      return date.year;
    } catch (e) {
      return 0;
    }
  }

  static bool isBirthdayToday(String? dobString) {
    if (dobString == null || dobString.isEmpty || dobString == 'Not set') {
      return false;
    }
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      return dob.month == today.month && dob.day == today.day;
    } catch (e) {
      return false;
    }
  }
}
