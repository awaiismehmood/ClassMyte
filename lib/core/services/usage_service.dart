import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UsageService {
  static const String _generateFormCountKey = 'generate_form_count';
  static const String _lastResetDateKey = 'last_reset_date';

  static Future<int> getDailyFormCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastReset = prefs.getString(_lastResetDateKey) ?? '';

    if (lastReset != today) {
      await prefs.setString(_lastResetDateKey, today);
      await prefs.setInt(_generateFormCountKey, 0);
      return 0;
    }

    return prefs.getInt(_generateFormCountKey) ?? 0;
  }

  static Future<void> incrementFormCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getDailyFormCount();
    await prefs.setInt(_generateFormCountKey, current + 1);
  }
}
