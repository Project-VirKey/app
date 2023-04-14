import 'package:shared_preferences/shared_preferences.dart';
import 'package:virkey/features/recordings/recordings_provider.dart';
import 'package:virkey/features/settings/settings_model.dart';
import 'package:virkey/utils/timestamp.dart';

class AppSharedPreferences {
  static Map<String, dynamic>? loadedSharedPreferences;

  static void saveData(
      {Settings? settings, List<Recording>? recordings}) async {
    final prefs = await SharedPreferences.getInstance();
    if (settings != null) {
      await prefs.setString('settings', settingsToJson(settings));
    }
    if (recordings != null) {
      print(recordings.toString());
      // await prefs.setString('recordings', recordings.toString());
    }
    await prefs.setInt('lastUpdated', AppTimestamp.now);
  }

  static Future<Map<String, dynamic>?> loadData() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> loadedSharedPreferences = {
      'lastUpdated': null,
      'settings': null,
      'recordings': null
    };

    if (prefs.containsKey('lastUpdated')) {
      loadedSharedPreferences['lastUpdated'] = prefs.getInt('lastUpdated');
    } else {
      return null;
    }

    if (prefs.containsKey('settings')) {
      // try, because if the model changes there will be an error trying to convert
      // the read string from shared preferences to the model with settingsFromJson
      try {
        loadedSharedPreferences['settings'] =
            settingsFromJson(prefs.getString('settings') ?? '');

        // TODO: implement array with Recordings-objects
        print(prefs.getString('recordings'));
        loadedSharedPreferences['recordings'] = prefs.getString('recordings');
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }

    return loadedSharedPreferences;
  }
}
