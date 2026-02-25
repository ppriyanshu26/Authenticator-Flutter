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

  static String getFormattedTimestamp() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().padLeft(4, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$day$month$year $hour$minute$second';
  }

  static int parseTimestampToMillis(String timestamp) {
    try {
      final parts = timestamp.split(' ');
      if (parts.length != 2) return 0;
      final datePart = parts[0];
      final timePart = parts[1];
      if (timePart.length != 6) return 0;
      final day = int.parse(datePart.substring(0, 2));
      final month = int.parse(datePart.substring(2, 4));

      int year;
      if (datePart.length == 8) {
        year = int.parse(datePart.substring(4, 8));
      } else if (datePart.length == 6) {
        year = 2000 + int.parse(datePart.substring(4, 6));
      } else {
        return 0;
      }

      final hour = int.parse(timePart.substring(0, 2));
      final minute = int.parse(timePart.substring(2, 4));
      final second = int.parse(timePart.substring(4, 6));
      final dateTime = DateTime(year, month, day, hour, minute, second);
      return dateTime.millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
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

  static Future<void> trackDeletedIds(List<String> deletedIds) async {
    if (deletedIds.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await getDeletionLog();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    for (final id in deletedIds) {
      existing[id] = timestamp;
    }
    await prefs.setString(deletionLogKey, jsonEncode(existing));
  }

  static Future<void> removeFromDeletionLog(List<String> ids) async {
    if (ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await getDeletionLog();
    for (final id in ids) {
      existing.remove(id);
    }
    await prefs.setString(deletionLogKey, jsonEncode(existing));
  }

  static Future<void> clearTombstones(Iterable<String> ids) async {
    final list = ids.where((e) => e.isNotEmpty).toList();
    await removeFromDeletionLog(list);
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
        'createdAt': e['createdAt'] as String? ?? '',
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

    final id = generateId(platform, username, secret);
    final newItem = {
      'id': id,
      'platform': platform,
      'username': username,
      'secretcode': secret,
      'createdAt': getFormattedTimestamp(),
    };

    list.add(newItem);

    list.sort(
      (a, b) =>
          a['platform']!.toLowerCase().compareTo(b['platform']!.toLowerCase()),
    );

    final encrypted = await Crypto.encryptAes(jsonEncode(list));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, encrypted);
    await removeFromDeletionLog([id]);

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
      await trackDeletedIds(deletedIds);
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
      final localDeletedAt = existingLog[entry.key];
      if (localDeletedAt == null || entry.value > localDeletedAt) {
        existingLog[entry.key] = entry.value;
      }
    }

    final List<String> resurrectedIds = [];
    final filteredItems = items.where((item) {
      final itemId = item['id'];
      if (!existingLog.containsKey(itemId)) {
        return true;
      }
      final createdAtStr = item['createdAt'] ?? '';
      final createdAtMillis = parseTimestampToMillis(createdAtStr);
      final deletedAtMillis = existingLog[itemId] ?? 0;
      if (createdAtMillis > deletedAtMillis) {
        resurrectedIds.add(itemId!);
        return true;
      }
      return false;
    }).toList();

    for (final id in resurrectedIds) {
      existingLog.remove(id);
    }

    final encrypted = await Crypto.encryptAes(jsonEncode(filteredItems));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, encrypted);

    await prefs.setString(deletionLogKey, jsonEncode(existingLog));
  }
}
