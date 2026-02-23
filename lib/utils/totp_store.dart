import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'crypto.dart';

class TotpStore {
  static const storeKey = 'totp_store';
  static const deletionLogKey = 'totp_deletion_log';

  static String generateId(String platform, String username, String secret) {
    final input = '$platform$username$secret';
    return sha256.convert(input.codeUnits).toString();
  }

  static Future<Map<String, int>> getDeletionLog() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(deletionLogKey);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (e) {
      return {};
    }
  }

  static Future<void> _trackDeletedIds(List<String> deletedIds) async {
    if (deletedIds.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await getDeletionLog();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    for (final id in deletedIds) {
      existing[id] = timestamp;
    }
    await prefs.setString(deletionLogKey, jsonEncode(existing));
  }

  static Future<List<String>> getDeletedIds() async {
    final deletionLog = await getDeletionLog();
    return deletionLog.keys.toList();
  }

  static Future<List<Map<String, String>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(storeKey);

    if (encrypted == null || encrypted.isEmpty) return [];

    final decrypted = await Crypto.decryptAes(encrypted);
    final List<dynamic> decoded = jsonDecode(decrypted);

    return decoded.map<Map<String, String>>((e) {
      return {
        'id': e['id'] as String,
        'platform': e['platform'] as String,
        'username': e['username'] as String,
        'secretcode': e['secretcode'] as String,
      };
    }).toList();
  }

  static Future<bool> add(String platform, String url) async {
    final list = await load();

    final uri = Uri.parse(url);
    final label = uri.pathSegments.last;

    String username = '';
    if (label.contains(':')) {
      username = label.split(':').sublist(1).join(':');
    }

    final secret = (uri.queryParameters['secret'] ?? '').toUpperCase();

    final p = platform.trim().toLowerCase();
    final u = username.trim().toLowerCase();

    for (final item in list) {
      final itemSecret = item['secretcode'] ?? '';

      if (item['platform']!.trim().toLowerCase() == p &&
          item['username']!.trim().toLowerCase() == u &&
          itemSecret == secret) {
        return false;
      }
    }

    final newItem = {
      'id': generateId(platform, username, secret),
      'platform': platform,
      'username': username,
      'secretcode': secret,
    };

    list.add(newItem);

    list.sort(
      (a, b) =>
          a['platform']!.toLowerCase().compareTo(b['platform']!.toLowerCase()),
    );

    final encrypted = await Crypto.encryptAes(jsonEncode(list));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, encrypted);
    return true;
  }

  static Future<void> saveAll(List<Map<String, String>> items) async {
    final currentList = await load();
    final currentIds = {
      for (final item in currentList)
        if (item['id'] != null) item['id']!,
    };
    final newIds = {
      for (final item in items)
        if (item['id'] != null) item['id']!,
    };
    final deletedIds = currentIds.difference(newIds).toList();

    if (deletedIds.isNotEmpty) {
      await _trackDeletedIds(deletedIds);
    }

    final encrypted = await Crypto.encryptAes(jsonEncode(items));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, encrypted);
  }

  static Future<void> saveAllAndMerge(
    List<Map<String, String>> items,
    Map<String, int> remoteDeletedIds,
  ) async {
    final currentList = await load();
    final currentIds = {
      for (final item in currentList)
        if (item['id'] != null) item['id']!,
    };
    final newIds = {
      for (final item in items)
        if (item['id'] != null) item['id']!,
    };
    final locallyDeletedIds = currentIds.difference(newIds).toList();

    final existingLog = await getDeletionLog();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (final id in locallyDeletedIds) {
      existingLog[id] = timestamp;
    }
    for (final entry in remoteDeletedIds.entries) {
      if (!existingLog.containsKey(entry.key) ||
          entry.value < existingLog[entry.key]!) {
        existingLog[entry.key] = entry.value;
      }
    }

    final filteredItems = items
        .where((item) => !existingLog.containsKey(item['id']))
        .toList();

    final encrypted = await Crypto.encryptAes(jsonEncode(filteredItems));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, encrypted);

    await prefs.setString(deletionLogKey, jsonEncode(existingLog));
  }
}
