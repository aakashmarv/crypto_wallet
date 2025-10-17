import 'dart:convert';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:web3dart/web3dart.dart';
import 'secure_mnemonic_service.dart';

class WalletInfo {
  final String address;
  final String privateKeyHex;
  final int index;
  final String path;

  WalletInfo({
    required this.address,
    required this.privateKeyHex,
    required this.index,
    required this.path,
  });
}

class MultiWalletService {
  static const _bip44Prefix = "m/44'/60'/0'/0/"; // ethereum

  final SecureMnemonicService _secureService;
  List<WalletInfo> _cached = [];

  MultiWalletService(this._secureService);

  // Import mnemonic (user-provided) -> encrypt & reset indexes to [0]
  Future<WalletInfo> importMnemonic(String mnemonic, String password, {int index = 0}) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }
    await _secureService.encryptAndStoreMnemonic(mnemonic, password);
    await saveIndexes([index]);
    final wallet = await deriveWalletFromMnemonic(mnemonic, index);
    _cached = [wallet];
    return wallet;
  }

// 🔹 Import wallet using Private Key (non-HD) — single account only
  Future<WalletInfo> importPrivateKey(String privateKeyHex, String password) async {
    // 1️⃣ Validate private key format
    try {
      EthPrivateKey.fromHex(privateKeyHex);
    } catch (_) {
      throw Exception(
        'Invalid private key format. It must be a valid 64-character hex string (with or without 0x).',
      );
    }

    // 2️⃣ Normalize (ensure 0x prefix)
    if (!privateKeyHex.startsWith('0x')) {
      privateKeyHex = '0x$privateKeyHex';
    }

    // 3️⃣ Encrypt and store securely
    await _secureService.encryptAndStoreMnemonic(privateKeyHex, password);

    // 4️⃣ Use index -1 to indicate non-HD wallet (single imported key)
    const index = -1;
    await saveIndexes([index]);

    // 5️⃣ Derive address and create WalletInfo object
    final ethKey = EthPrivateKey.fromHex(privateKeyHex);
    final addr = (await ethKey.extractAddress()).hexEip55;

    final wallet = WalletInfo(
      address: addr,
      privateKeyHex: privateKeyHex,
      index: index,
      path: 'non-hd',
    );

    _cached = [wallet];
    return wallet;
  }


  // Add new account derived from stored mnemonic (increment index)
  Future<WalletInfo> addAccount(String password) async {
    final mnemonic = await _secureService.getDecryptedMnemonic(password);
    if (mnemonic == null) throw Exception('Bad password or no mnemonic');

    final indexes = await getIndexes();
    final nextIndex = (indexes.isEmpty) ? 0 : (indexes.reduce((a,b) => a>b?a:b) + 1);
    final wallet = await deriveWalletFromMnemonic(mnemonic, nextIndex);

    indexes.add(nextIndex);
    await saveIndexes(indexes);

    _cached.add(wallet);
    return wallet;
  }

  // List accounts (derive from mnemonic using stored indexes)
  Future<List<WalletInfo>> listAccounts(String password) async {
    if (_cached.isNotEmpty) return _cached;

    final storedValue = await _secureService.getDecryptedMnemonic(password);
    if (storedValue == null) return [];

    final indexes = await getIndexes();

    // 🧩 Detect if stored value is a mnemonic or private key
    final isPrivateKey = RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(storedValue);

    final wallets = <WalletInfo>[];

    if (isPrivateKey) {
      // 🔹 Handle private key wallet
      var privateKeyHex = storedValue;
      if (!privateKeyHex.startsWith('0x')) {
        privateKeyHex = '0x$privateKeyHex';
      }

      final ethKey = EthPrivateKey.fromHex(privateKeyHex);
      final address = (await ethKey.extractAddress()).hexEip55;

      wallets.add(WalletInfo(
        address: address,
        privateKeyHex: privateKeyHex,
        index: -1,
        path: 'non-hd',
      ));
    } else {
      // 🔹 Handle HD wallet (mnemonic)
      for (final idx in indexes) {
        wallets.add(await deriveWalletFromMnemonic(storedValue, idx));
      }
    }

    _cached = wallets;
    return wallets;
  }


  // Derive wallet info (path + private key -> address)
  Future<WalletInfo> deriveWalletFromMnemonic(String mnemonic, int index) async {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final path = '$_bip44Prefix$index';
    final child = root.derivePath(path);

    if (child.privateKey == null) throw Exception('Failed derive key');
    final privateHex = '0x${child.privateKey!.map((b) => b.toRadixString(16).padLeft(2,'0')).join()}';
    final ethKey = EthPrivateKey.fromHex(privateHex);
    final addr = (await ethKey.extractAddress()).hexEip55;

    return WalletInfo(address: addr, privateKeyHex: privateHex, index: index, path: path);
  }

  // Remove cached decrypted data on logout
  Future<void> clearAll() async {
    await _secureService.clearAll();
    _cached.clear();
  }

  // Helpers: store indexes (SharedPreferences)
  Future<void> saveIndexes(List<int> indexes) async {
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.setString(AppKeys.walletIndexesKey, jsonEncode(indexes));
  }

  Future<List<int>> getIndexes() async {
    final prefs = await SharedPreferencesService.getInstance();
    final jsonString = prefs.getString(AppKeys.walletIndexesKey);
    if (jsonString == null) return [];
    final list = (jsonDecode(jsonString) as List<dynamic>).cast<int>();
    return list;
  }
}
