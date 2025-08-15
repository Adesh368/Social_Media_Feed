import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  // Saves data to SharedPreferences under the given key
  static Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    // Gets the SharedPreferences instance (singleton).

    final jsonString = json.encode(value);
    // Converts the value (object, list, etc.) to a JSON string.

    await prefs.setString(key, jsonString);
    // Stores the JSON string under the given key in SharedPreferences.
  }

  // Retrieves data from SharedPreferences by key
  static Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    // Gets the SharedPreferences instance.

    final jsonString = prefs.getString(key);
    // Reads the stored string for the given key, or null if not found.

    if (jsonString == null) return null;
    // If no data was stored, return null immediately.

    return json.decode(jsonString);
    // Parses the JSON string back into its original Dart object.
  }

  // Removes a specific entry from SharedPreferences
  static Future<void> clearData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    // Gets the SharedPreferences instance.

    await prefs.remove(key);
    // Deletes the entry with the given key from SharedPreferences.
  }
}
