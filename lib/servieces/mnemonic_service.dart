import 'package:bip39/bip39.dart' as bip39;

class MnemonicService {
  /// Generate a new valid 12-word mnemonic phrase
  static String generateMnemonic({int strength = 128}) {
    return bip39.generateMnemonic(strength: strength);
  }

  /// Validate mnemonic
  static bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// Convert mnemonic to seed bytes
  static List<int> mnemonicToSeed(String mnemonic) {
    return bip39.mnemonicToSeed(mnemonic);
  }
}
