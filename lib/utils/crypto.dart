import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart';
import 'runtime_key.dart';

class Crypto {
  static final aes = AesGcm.with256bits();

  static Future<String> encryptAes(String plaintext) async {
    final encrypted = await encryptBytes(utf8.encode(plaintext));
    return base64UrlEncode(encrypted);
  }

  static Future<String> decryptAes(String ciphertext) async {
    final data = base64Url.decode(ciphertext);
    final decrypted = await decryptBytes(data);
    return utf8.decode(decrypted);
  }

  static Future<List<int>> encryptBytes(List<int> data) async {
    final raw = RuntimeKey.rawPassword;
    if (raw == null) {
      throw Exception('Master key not in memory');
    }

    final keyBytes = sha256.convert(utf8.encode(raw)).bytes;
    final secretKey = SecretKey(keyBytes);

    final nonce =
    List<int>.generate(12, (_) => Random.secure().nextInt(256));

    final box = await aes.encrypt(
      data,
      secretKey: secretKey,
      nonce: nonce,
    );

    return [
      ...nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ];
  }

  static Future<List<int>> decryptBytes(List<int> data) async {
    final raw = RuntimeKey.rawPassword;
    if (raw == null) {
      throw Exception('Master key not in memory');
    }

    final keyBytes = sha256.convert(utf8.encode(raw)).bytes;
    final secretKey = SecretKey(keyBytes);

    final nonce = data.sublist(0, 12);
    final cipherText = data.sublist(12, data.length - 16);
    final tag = data.sublist(data.length - 16);

    final box = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(tag),
    );

    return await aes.decrypt(box, secretKey: secretKey);
  }
}
