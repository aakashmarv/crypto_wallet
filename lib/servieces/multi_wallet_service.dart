import 'dart:convert';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
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
  static const _prefsWalletIndexesKey = 'wallet_indexes'; // stored in SharedPreferences (non-sensitive)
  static const _bip44Prefix = "m/44'/60'/0'/0/"; // ethereum

  final SecureMnemonicService _secureService;
  List<WalletInfo> _cached = [];

  MultiWalletService(this._secureService);

  // Create first wallet (generate mnemonic, store encrypted, init indexes)
  Future<WalletInfo> createFirstWallet(String password, {int index = 0}) async {
    final mnemonic = bip39.generateMnemonic(); // 12 words default
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Generated mnemonic invalid');
    }

    await _secureService.encryptAndStoreMnemonic(mnemonic, password);
    // initialize index list with the first index used (0)
    await _saveIndexes([index]);

    final wallet = await deriveWalletFromMnemonic(mnemonic, index);
    _cached = [wallet];
    return wallet;
  }

  // Import mnemonic (user-provided) -> encrypt & reset indexes to [0]
  Future<WalletInfo> importMnemonic(String mnemonic, String password, {int index = 0}) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }
    await _secureService.encryptAndStoreMnemonic(mnemonic, password);
    await _saveIndexes([index]);
    final wallet = await deriveWalletFromMnemonic(mnemonic, index);
    _cached = [wallet];
    return wallet;
  }

  // MultiWalletService Class Mein Add Karein

// Import single Private Key (non-HD) -> encrypt & reset indexes to [-1]
  Future<WalletInfo> importPrivateKey(String privateKeyHex, String password) async {
    // 1. Private Key ki validity check karein
    try {
      EthPrivateKey.fromHex(privateKeyHex);
    } catch (e) {
      throw Exception('Invalid private key format. Must be 64 hex characters with or without 0x prefix.');
    }

    // 2. Private Key ko encrypt karke store karein.
    // Hum Mnemonic encryption function ko Private Key store karne ke liye use kar rahe hain,
    // kyunki app sirf ek hi secret store karegi.
    await _secureService.encryptAndStoreMnemonic(privateKeyHex, password);

    // 3. Indexes ko reset karein. Non-HD key ke liye index -1 set karna ek achhi practice hai.
    final index = -1;
    await _saveIndexes([index]);

    // 4. Address nikalna aur WalletInfo banana
    final ethKey = EthPrivateKey.fromHex(privateKeyHex);
    final addr = (await ethKey.extractAddress()).hexEip55;

    // path ko 'non-hd' set karein
    final wallet = WalletInfo(address: addr, privateKeyHex: privateKeyHex, index: index, path: 'non-hd');
    _cached = [wallet];
    return wallet;
  }

  // Add new account derived from stored mnemonic (increment index)
  Future<WalletInfo> addAccount(String password) async {
    final mnemonic = await _secureService.decryptMnemonic(password);
    if (mnemonic == null) throw Exception('Bad password or no mnemonic');

    final indexes = await _getIndexes();
    final nextIndex = (indexes.isEmpty) ? 0 : (indexes.reduce((a,b) => a>b?a:b) + 1);
    final wallet = await deriveWalletFromMnemonic(mnemonic, nextIndex);

    indexes.add(nextIndex);
    await _saveIndexes(indexes);

    _cached.add(wallet);
    return wallet;
  }

  // List accounts (derive from mnemonic using stored indexes)
  Future<List<WalletInfo>> listAccounts(String password) async {
    if (_cached.isNotEmpty) return _cached;

    final mnemonic = await _secureService.decryptMnemonic(password);
    if (mnemonic == null) return [];

    final indexes = await _getIndexes();
    final wallets = <WalletInfo>[];
    for (final idx in indexes) {
      wallets.add(await deriveWalletFromMnemonic(mnemonic, idx));
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
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.remove(_prefsWalletIndexesKey);
    _cached.clear();
  }

  // Helpers: store indexes (SharedPreferences)
  Future<void> _saveIndexes(List<int> indexes) async {
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.setString(_prefsWalletIndexesKey, jsonEncode(indexes));
  }

  Future<List<int>> _getIndexes() async {
    final prefs = await SharedPreferencesService.getInstance();
    final jsonString = prefs.getString(_prefsWalletIndexesKey);
    if (jsonString == null) return [];
    final list = (jsonDecode(jsonString) as List<dynamic>).cast<int>();
    return list;
  }
}
