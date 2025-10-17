import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_keys.dart';
import '../../../servieces/multi_wallet_service.dart';
import '../../../servieces/secure_mnemonic_service.dart';
import '../../../servieces/sharedpreferences_service.dart';
import '../../../utils/logger.dart';

class HomeController extends GetxController {
  var walletName = 'My Wallet'.obs;
  var walletAddress = ''.obs;
  var  walletBalance = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    await _loadWalletInfo();
    await loadBalance();
  }

  Future<void> _loadWalletInfo() async {
    final prefs = await SharedPreferencesService.getInstance();
    final name = prefs.getString(AppKeys.currentWalletName) ?? 'My Wallet';
    final address = prefs.getString(AppKeys.walletAddress) ?? '';

    walletName.value = name;
    walletAddress.value = address;

    appLog('[DEBUG] Wallet Loaded: $name | $address');
  }

  Future<void> loadBalance() async {
    try {
      final balance = await getCurrentBalance();
      if (walletBalance.value != balance) {
        walletBalance.value = balance;
      } else {
        walletBalance.refresh(); // ✅ forces Obx to rebuild if value unchanged
      }
      appLog('[DEBUG] UI Balance Updated → $balance');
    } catch (e, st) {
      appLog('[ERROR] Balance load failed: $e');
      print(st);
    }
  }


  Future<String> getCurrentBalance() async {
    final secureService = SecureMnemonicService();
    final storage = FlutterSecureStorage();
    final storedPassword = await storage.read(key: AppKeys.userPassword);
    if (storedPassword == null) throw Exception("No password found");

    final decryptedValue = await secureService.getDecryptedMnemonic(storedPassword);
    if (decryptedValue == null) throw Exception("No mnemonic/private key found");

    final walletService = MultiWalletService(secureService);

    // ✅ Detect if stored value is mnemonic or private key
    final isPrivateKey = RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(decryptedValue);

    WalletInfo wallet;
    if (isPrivateKey) {
      // Private key wallet
      var pk = decryptedValue;
      if (!pk.startsWith('0x')) pk = '0x$pk';
      final ethKey = EthPrivateKey.fromHex(pk);
      final addr = (await ethKey.extractAddress()).hexEip55;
      wallet = WalletInfo(address: addr, privateKeyHex: pk, index: -1, path: 'non-hd');
    } else {
      // HD wallet (mnemonic)
      wallet = await walletService.deriveWalletFromMnemonic(decryptedValue, 0);
    }

    final web3client = Web3Client(ApiConstants.rpcUrl, Client());
    final address = EthereumAddress.fromHex(wallet.address);
    appLog('[DEBUG] Fetching balance for: ${wallet.address}');

    final balance = await web3client.getBalance(address);
    await web3client.dispose();
    appLog('[DEBUG] Raw balance (wei): $balance');

    final ether = balance.getValueInUnit(EtherUnit.ether);
    appLog('[DEBUG] Parsed balance (ether): $ether');

    // ✅ Return string formatted safely
    return ether.toStringAsFixed(6);
  }

}

