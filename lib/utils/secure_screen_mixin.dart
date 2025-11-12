import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {

  @override
  void initState() {
    super.initState();
    _enableSecureScreen();
  }

  @override
  void dispose() {
    _disableSecureScreen();
    super.dispose();
  }

  Future<void> _enableSecureScreen() async {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageOn();
  }

  Future<void> _disableSecureScreen() async {
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageOff();
  }
}
