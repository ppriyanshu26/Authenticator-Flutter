import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'crypto.dart';
import 'totp_store.dart';

class Storage {
  static const _pwKey = 'master_password_hash';
  static const _darkKey = 'dark_mode';

  static Future<void> saveMasterPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = sha256.convert(utf8.encode(password)).toString();
    await prefs.setString(_pwKey, hash);
  }

  static Future<bool> verifyMasterPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pwKey);
    if (stored == null) return false;
    final hash = sha256.convert(utf8.encode(password)).toString();
    return stored == hash;
  }

  static Future<bool> hasMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pwKey);
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkKey) ?? false;
  }
  static Future<void> resetMasterPassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedStore = prefs.getString(TotpStore.storeKey);
      String decrypted = '';
      if (encryptedStore != null && encryptedStore.isNotEmpty) {
        decrypted = await Crypto.decryptAesWithPassword(
          encryptedStore,
          oldPassword,
        );
      }
      await saveMasterPassword(newPassword);
      if (decrypted.isNotEmpty) {
        final reEncrypted = await Crypto.encryptAesWithPassword(
          decrypted,
          newPassword,
        );
        await prefs.setString(TotpStore.storeKey, reEncrypted);
      }
    } catch (e) {
      rethrow;
    }
  }
}
