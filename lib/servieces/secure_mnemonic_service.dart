import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class SecureMnemonicService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Derive AES key from user PIN/password (or static app secret for now)
  Key _deriveKey(String password) {
    final hash = sha256.convert(utf8.encode(password));
    return Key(Uint8List.fromList(hash.bytes));
  }

  Future<void> encryptAndStoreMnemonic(String mnemonic, String password) async {
    final key = _deriveKey(password);
    final iv = IV.fromLength(16); // static IV (okay since key is unique)
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(mnemonic, iv: iv);
    await _secureStorage.write(key: AppKeys.encryptedMnemonic, value: encrypted.base64);
  }

  Future<String?> decryptMnemonic(String password) async {
    final key = _deriveKey(password);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = await _secureStorage.read(key: AppKeys.encryptedMnemonic);
    if (encrypted == null) return null;
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(encrypted), iv: iv);
    return decrypted;
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}



