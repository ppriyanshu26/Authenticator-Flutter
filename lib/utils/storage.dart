import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Storage {
  static const masterPasswordHashKey = 'master_password_hash';
  static const darkModeKey = 'dark_mode';

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Future<bool> hasMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(masterPasswordHashKey);
  }

  static Future<void> saveMasterPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = hashPassword(password);
    await prefs.setString(masterPasswordHashKey, hash);
  }

  static Future<bool> verifyMasterPassword(String input) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(masterPasswordHashKey);
    if (storedHash == null) return false;

    final inputHash = hashPassword(input);
    return inputHash == storedHash;
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
  }
}
