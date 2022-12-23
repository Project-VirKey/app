import 'package:shared_preferences/shared_preferences.dart';
import 'package:virkey/features/settings/settings_model.dart';

class AppSharedPreferences {
  static void saveData(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', settingsToJson(settings));
  }

  static Future<Settings?> loadData() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('settings')) {
      return settingsFromJson(prefs.getString('settings') ?? '');
    } else {
      return null;
    }
  }
}