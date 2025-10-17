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

  Future<String> sendTransaction({
    required String to,
    required String amount, // in Wei string
    required String password,
    int chainId = 18359, // ✅ fixed default
  }) async {
    final wallets = await walletService.listAccounts(password);
    if (wallets.isEmpty) throw Exception('No wallet found');

    final walletInfo = wallets.first;
    final credentials = EthPrivateKey.fromHex(walletInfo.privateKeyHex);
    final client = Web3Client(ApiConstants.rpcUrl, Client());

    try {
      final sender = await credentials.extractAddress();
      final nonce = await client.getTransactionCount(sender);
      final gasPrice = await client.getGasPrice();
      final valueInWei = BigInt.parse(amount);

      final tx = Transaction(
        from: sender,
        to: EthereumAddress.fromHex(to),
        gasPrice: gasPrice,
        maxGas: 21000,
        value: EtherAmount.inWei(valueInWei),
        nonce: nonce,
      );

      final txHash = await client.sendTransaction(
        credentials,
        tx,
        chainId: chainId,
      );
      return txHash;
    } catch (e) {
      rethrow; // ✅ preserve original exception
    } finally {
      await client.dispose();
    }
  }
}

