import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'runtime_key.dart';

class Crypto {
  static Future<String> encryptAes(String plaintext) async {
    final key = sha256.convert(utf8.encode(RuntimeKey.rawPassword!)).bytes;
    final nonce = _randomBytes(12);
    final aes = AesGcm.with256bits();
    final secretKey = SecretKey(key);

    final box = await aes.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    return base64UrlEncode(nonce + box.cipherText + box.mac.bytes);
  }

  static Future<String> decryptAes(String ciphertext) async {
    final data = base64Url.decode(ciphertext);
    final nonce = data.sublist(0, 12);
    final mac = Mac(data.sublist(data.length - 16));
    final cipherText = data.sublist(12, data.length - 16);

    final key = sha256.convert(utf8.encode(RuntimeKey.rawPassword!)).bytes;
    final aes = AesGcm.with256bits();
    final secretKey = SecretKey(key);

    final clear = await aes.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: secretKey,
    );

    return utf8.decode(clear);
  }

  static Uint8List _randomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(
        List.generate(length, (_) => rnd.nextInt(256)));
  }
}
