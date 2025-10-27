import 'dart:convert';
import 'package:cryptovault_pro/utils/helper_util.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:cryptovault_pro/constants/api_constants.dart';
import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/secure_mnemonic_service.dart';
import 'package:cryptovault_pro/servieces/multi_wallet_service.dart';
import 'package:cryptovault_pro/utils/logger.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';

class SendTokenService {
  final MultiWalletService _walletService;
  final SecureMnemonicService _secureService;

  SendTokenService(this._walletService, this._secureService);

  /// 🔹 Send native RUBY or token
  ///
  /// - [toAddress] : destination address (0x... or r...)
  /// - [amount] : token amount as string (e.g., "0.5")
  /// - [tokenAddress] : if null => send native RUBY, otherwise ERC20 token
  /// - [password] : user’s encryption password
  Future<String> sendToken({
    required String toAddress,
    required String amount,
    required String password,
    String? tokenAddress,
  }) async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final walletAddress = prefs.getString(AppKeys.walletAddress);

      if (walletAddress == null || walletAddress.isEmpty) {
        throw Exception("Wallet address not found.");
      }

      // 🔹 Convert r... address to Ethereum-compatible 0x...
      final senderEthAddressHex = HelperUtil.toEthereumAddress(walletAddress);
      final senderAddress = EthereumAddress.fromHex(senderEthAddressHex);
      final receiverAddress = EthereumAddress.fromHex(HelperUtil.toEthereumAddress(toAddress));

      // 🔹 Load sender’s credentials (private key)
      final privateKey =
      await _secureService.getPrivateKeyForAddress(walletAddress, password);
      if (privateKey == null || privateKey.isEmpty) {
        throw Exception("Private key not found or password invalid.");
      }

      final credentials = EthPrivateKey.fromHex(privateKey);

      // 🔹 Setup client
      final client = Web3Client(ApiConstants.rpcUrl, Client());

      // 🔹 Convert amount to Wei
      final ethValue = EtherAmount.fromUnitAndValue(
        EtherUnit.ether,
        BigInt.parse((double.parse(amount) * 1e18).toStringAsFixed(0)),
      );

      String txHash;

      if (tokenAddress == null || tokenAddress.isEmpty) {
        // ✅ Native RUBY coin transfer
        final tx = Transaction(
          from: senderAddress,
          to: receiverAddress,
          value: ethValue,
          gasPrice: EtherAmount.inWei(BigInt.one * BigInt.from(1000000000)), // 1 Gwei
          maxGas: 21000,
        );

        final hash = await client.sendTransaction(
          credentials,
          tx,
          chainId: null,
          fetchChainIdFromNetworkId: true,
        );

        txHash = hash;
      } else {
        // ✅ ERC20 Token Transfer
        final token = DeployedContract(
          ContractAbi.fromJson(_erc20Abi, "ERC20"),
          EthereumAddress.fromHex(tokenAddress),
        );

        final transfer = token.function("transfer");

        final txHash = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: token,
            function: transfer,
            parameters: [receiverAddress, ethValue.getInWei],
          ),
          chainId: null,
          fetchChainIdFromNetworkId: true,
        );

        return txHash;
      }

      await client.dispose();
      appLog("✅ Transaction sent successfully → Hash: $txHash");
      return txHash;
    } catch (e, st) {
      appLog("❌ Send Token Error: $e\n$st");
      rethrow;
    }
  }

  // 🔸 Minimal ERC20 ABI
  static const String _erc20Abi = '''
  [
    {"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"},
    {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
    {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
    {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"}
  ]
  ''';
}
