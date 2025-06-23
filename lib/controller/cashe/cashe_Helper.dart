import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (_preferences == null) await init();

    if (value is String) return await _preferences!.setString(key, value);
    if (value is int) return await _preferences!.setInt(key, value);
    if (value is bool) return await _preferences!.setBool(key, value);
    if (value is double) return await _preferences!.setDouble(key, value);
    if (value is List<String>) {
      return await _preferences!.setStringList(key, value);
    }

    throw Exception("Unsupported type");
  }

  static dynamic getData({required String key}) {
    if (_preferences == null) return null;
    return _preferences!.get(key);
  }

  static Future<bool> removeData({required String key}) async {
    if (_preferences == null) return false;
    return await _preferences!.remove(key);
  }

  static Future<bool> clearAll() async {
    if (_preferences == null) return false;
    return await _preferences!.clear();
  }
}
