import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

class SecureMnemonicService {
  static const _encryptedMnemonicKey = 'encrypted_mnemonic';
  static const _saltKey = 'mnemonic_salt';
  static const _ivKey = 'mnemonic_iv';
  static const _pbkdf2Iterations = 100000; // recommended >=100k for mobile

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // PBKDF2 (HMAC-SHA256) implementation to derive key (32 bytes)
  Uint8List _pbkdf2(Uint8List password, Uint8List salt, int iterations, int dkLen) {
    final hmac = Hmac(sha256, password);
    int hashLen = 32;
    int blocks = (dkLen / hashLen).ceil();
    final out = Uint8List(dkLen);
    var offset = 0;

    for (var block = 1; block <= blocks; block++) {
      // U1 = HMAC(password, salt || block)
      final blockBytes = Uint8List.fromList(salt + _int32BE(block));
      var u = hmac.convert(blockBytes).bytes;
      var t = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) t[j] ^= u[j];
      }

      final len = min(hashLen, dkLen - offset);
      out.setRange(offset, offset + len, t);
      offset += len;
    }

    return out;
  }

  List<int> _int32BE(int i) {
    return [
      (i >> 24) & 0xff,
      (i >> 16) & 0xff,
      (i >> 8) & 0xff,
      i & 0xff,
    ];
  }

  // Derive AES key (32 bytes) from password + stored salt (or provided salt)
  Future<Uint8List> _deriveKeyFromPassword(String password, Uint8List salt) async {
    final passBytes = utf8.encode(password) as Uint8List;
    return _pbkdf2(passBytes, salt, _pbkdf2Iterations, 32);
  }

  // Public: encrypt mnemonic and store (salt & iv stored too)
  Future<void> encryptAndStoreMnemonic(String mnemonic, String password) async {
    // generate salt & iv
    final salt = _randomBytes(16);
    final iv = _randomBytes(16);

    final keyBytes = _deriveKeyFromPassword(password, salt);
    final key = Key(await keyBytes); // Key expects Uint8List
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(mnemonic, iv: IV(iv));

    await _secureStorage.write(key: _encryptedMnemonicKey, value: encrypted.base64);
    await _secureStorage.write(key: _saltKey, value: base64Encode(salt));
    await _secureStorage.write(key: _ivKey, value: base64Encode(iv));
  }

  // Public: decrypt mnemonic using password
  Future<String?> decryptMnemonic(String password) async {
    final encBase64 = await _secureStorage.read(key: _encryptedMnemonicKey);
    final saltBase64 = await _secureStorage.read(key: _saltKey);
    final ivBase64 = await _secureStorage.read(key: _ivKey);

    if (encBase64 == null || saltBase64 == null || ivBase64 == null) return null;

    final salt = base64Decode(saltBase64);
    final iv = base64Decode(ivBase64);

    final keyBytes = await _deriveKeyFromPassword(password, Uint8List.fromList(salt));
    final key = Key(keyBytes);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    try {
      final decrypted = encrypter.decrypt64(encBase64, iv: IV(iv));
      return decrypted;
    } catch (e) {
      // bad password or corrupted data
      return null;
    }
  }

  Future<void> clearAll() async {
    await _secureStorage.delete(key: _encryptedMnemonicKey);
    await _secureStorage.delete(key: _saltKey);
    await _secureStorage.delete(key: _ivKey);
  }

  Uint8List _randomBytes(int len) {
    final r = Random.secure();
    final bytes = List<int>.generate(len, (_) => r.nextInt(256));
    return Uint8List.fromList(bytes);
  }
}


