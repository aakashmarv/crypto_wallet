import 'dart:async';
import 'package:cryptovault_pro/servieces/secure_mnemonic_service.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../constants/api_constants.dart';
import 'multi_wallet_service.dart';

class SendService {
  final MultiWalletService walletService;
  final SecureMnemonicService secureService;

  SendService(this.walletService, this.secureService);

  /// Send ETH (or native token) to recipient
  /// Send native ETH (or compatible coin) transaction
  Future<String> sendTransaction({
    required String to,
    required String amount, // expects amount in WEI string from UI
    required String password,
    int chainId = 1, // default Ethereum mainnet
  }) async {
    // 1️⃣ Get wallet credentials
    final wallets = await walletService.listAccounts(password);
    if (wallets.isEmpty) throw Exception('No wallet found');

    final walletInfo = wallets.first;
    final credentials = EthPrivateKey.fromHex(walletInfo.privateKeyHex);
    final client = Web3Client(ApiConstants.rpcUrl, Client());

    try {
      // 2️⃣ Prepare sender info
      final sender = await credentials.extractAddress();
      final nonce = await client.getTransactionCount(sender);
      final gasPrice = await client.getGasPrice();

      // ✅ Convert the amount (Wei string → BigInt)
      final valueInWei = BigInt.parse(amount);

      // 🧱 Build transaction
      final tx = Transaction(
        from: sender,
        to: EthereumAddress.fromHex(to),
        gasPrice: gasPrice,
        maxGas: 21000,
        value: EtherAmount.inWei(valueInWei), // ✅ Correct way
        nonce: nonce,
      );

      // 3️⃣ Send signed transaction
      final txHash = await client.sendTransaction(
        credentials,
        tx,
        chainId: chainId,
      );

      return txHash;
    } catch (e) {
      // Handle gracefully
      throw Exception("Transaction failed: $e");
    } finally {
      await client.dispose();
    }
  }

}
