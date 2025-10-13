import 'package:get/get.dart';

class WalletSetupController extends GetxController {
  final walletName = ''.obs;
  final isNameValid = false.obs;
  final nameError = RxnString();
}
