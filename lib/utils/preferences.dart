import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Future<Map<String, dynamic>?> load(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? teamPref = prefs.getString(key);
    if (teamPref != null) {
      return jsonDecode(teamPref) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> save(String key, Map<String, dynamic>? value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, jsonEncode(value));
    } else {
      await prefs.remove(key);
    }
  }
}
