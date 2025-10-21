import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'logger.dart';


class HelperUtil {
  /// ✅ Converts an Ethereum-style address (0x...) to Ruby-chain format (r...)
  static String toRubyAddress(String address) {
    if (address.isEmpty) return '';
    // If already starts with 'r' (already converted)
    if (address.startsWith('r')) return address;
    // Ensure lowercase before replacing for consistency
    final cleanAddress = address.trim();
    if (cleanAddress.startsWith('0x')) {
      return 'r${cleanAddress.substring(2)}';
    }
    return 'r$cleanAddress';
  }


  /// ✅ Converts a Ruby-chain address (r...) back to Ethereum-style (0x...)
  static String toEthereumAddress(String address) {
    if (address.isEmpty) return '';
    if (address.startsWith('0x')) return address;
    if (address.startsWith('r')) return '0x${address.substring(1)}';
    return '0x$address';
  }

  /// ✅ Close the keyboard if it’s open
  static void closeKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
      appLog('🧹 [HelperUtil] Keyboard closed.');
    }
  }
  /// ✅ Shortens long wallet addresses for UI display (safe for all lengths)
  static String shortAddress(String? addr) {
    if (addr == null || addr.isEmpty) return "—"; // handle null/empty safely

    final clean = addr.trim();
    if (clean.length <= 16) return clean;

    final start = clean.substring(0, math.min(15, clean.length));
    final end = clean.substring(math.max(clean.length - 8, 0));
    return "$start...$end";
  }

  /// ✅ Copy text to clipboard with optional toast message
  static Future<void> copyToClipboard(String text, {bool showToast = true}) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    appLog('📋 [HelperUtil] Copied to clipboard: $text');

    if (showToast) {
      Fluttertoast.showToast(msg: 'Copied to clipboard');
    }
  }

}
