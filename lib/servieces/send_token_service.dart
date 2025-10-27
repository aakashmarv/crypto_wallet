import 'dart:math';
import 'package:cryptovault_pro/servieces/secure_mnemonic_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import '../constants/api_constants.dart';
import '../utils/helper_util.dart';
import 'multi_wallet_service.dart';


class SendTokenService {
  final MultiWalletService _walletService;
  final SecureMnemonicService _secureService;
  final Web3Client _client;

  SendTokenService(this._walletService, this._secureService)
      : _client = Web3Client(ApiConstants.rpcUrl, Client());

  /// ✅ Send ERC20 Token
  Future<String> sendToken({
    required String password,
    required String tokenAddress,
    required String recipient,
    required double amount,
    int decimals = 18,
    int index = 0,
  }) async {
    try {
      // Normalize addresses (handle r... → 0x...)
      final normalizedToken = HelperUtil.toEthereumAddress(tokenAddress);
      final normalizedRecipient = HelperUtil.toEthereumAddress(recipient);

      // 1️⃣ Decrypt wallet
      final mnemonic = await _secureService.getDecryptedMnemonic(password);
      if (mnemonic == null) throw Exception('Invalid password or wallet not found');
      final wallet = await _walletService.deriveWalletFromMnemonic(mnemonic, index);
      final credentials = EthPrivateKey.fromHex(wallet.privateKeyHex);
      final sender = await credentials.extractAddress();

      // 2️⃣ Check native balance (for gas)
      final balance = await _client.getBalance(sender);
      if (balance.getInWei <= BigInt.zero) {
        throw Exception("Insufficient native token balance to pay gas fees.");
      }

      // 3️⃣ Build ERC20 contract
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, "ERC20"),
        EthereumAddress.fromHex(normalizedToken),
      );

      final transferFn = contract.function('transfer');
      final BigInt value = BigInt.from(amount * pow(10, decimals));

      // 4️⃣ Send transaction
      final txHash = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: transferFn,
          parameters: [EthereumAddress.fromHex(normalizedRecipient), value],
          maxGas: 150000,
        ),
        chainId: ApiConstants.chainId,
      );

      return txHash;
    } catch (e) {
      throw Exception("Failed to send token: $e");
    }
  }

  /// ✅ Send Native Token (ETH, MATIC, RUBY, etc.)
  Future<String> sendNative({
    required String password,
    required String recipient,
    required double amount,
    int index = 0,
  }) async {
    try {
      final normalizedRecipient = HelperUtil.toEthereumAddress(recipient);

      final mnemonic = await _secureService.getDecryptedMnemonic(password);
      if (mnemonic == null) throw Exception('Invalid password or wallet not found');

      final wallet = await _walletService.deriveWalletFromMnemonic(mnemonic, index);
      final credentials = EthPrivateKey.fromHex(wallet.privateKeyHex);
      final sender = await credentials.extractAddress();

      // 1️⃣ Check native balance
      final balance = await _client.getBalance(sender);
      final weiAmount = EtherAmount.fromUnitAndValue(EtherUnit.ether, amount);
      if (balance.getInWei < weiAmount.getInWei) {
        throw Exception("Insufficient balance to send this amount.");
      }

      // 2️⃣ Send native transfer
      final txHash = await _client.sendTransaction(
        credentials,
        Transaction(
          to: EthereumAddress.fromHex(normalizedRecipient),
          value: weiAmount,
          maxGas: 21000,
        ),
        chainId: ApiConstants.chainId,
      );

      return txHash;
    } catch (e) {
      throw Exception("Failed to send native token: $e");
    }
  }

  /// ERC20 ABI (only transfer function)
  static const String _erc20Abi = '''
  [
    {
      "constant": false,
      "inputs": [
        { "name": "_to", "type": "address" },
        { "name": "_value", "type": "uint256" }
      ],
      "name": "transfer",
      "outputs": [{ "name": "", "type": "bool" }],
      "type": "function"
    }
  ]
  ''';
}
