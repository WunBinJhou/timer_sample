import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  static SharedPreferencesProvider? _instance;
  static SharedPreferences? _preferences;
  static Future<SharedPreferencesProvider> getInstance() async {
    _instance ??= SharedPreferencesProvider._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  SharedPreferencesProvider._();

  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  Future<bool> setInt(String key, int value) {
    return _preferences!.setInt(key, value);
  }

  Future<bool> remove(String key) {
    return _preferences!.remove(key);
  }
}