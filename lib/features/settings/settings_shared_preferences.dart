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
      // try, because if the model changes there will be an error trying to convert
      // the read string from shared preferences to the model with settingsFromJson
      try {
        return settingsFromJson(prefs.getString('settings') ?? '');
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }
}
