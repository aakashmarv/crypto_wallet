import 'dart:convert';
import 'package:cryptovault_pro/core/app_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../constants/app_keys.dart';
import '../models/address_entry.dart';
import '../servieces/sharedpreferences_service.dart';

class AddressBookController extends GetxController {
  final RxList<AddressEntry> addresses = <AddressEntry>[].obs;
  final RxBool isLoading = false.obs;

  static const _storageKey = AppKeys.addressBookKey;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferencesService.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null || jsonStr.isEmpty) {
        addresses.assignAll([]);
      } else {
        final List parsed = jsonDecode(jsonStr) as List;
        final list = parsed.map((e) => AddressEntry.fromJson(e as Map<String, dynamic>)).toList();
        addresses.assignAll(list);
      }
    } catch (e, st) {
      debugPrint('AddressBook load error: $e\n$st');
      addresses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveAddresses() async {
    final prefs = await SharedPreferencesService.getInstance();
    final jsonStr = jsonEncode(addresses.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<void> addAddress(AddressEntry entry) async {
    addresses.insert(0, entry);
    await saveAddresses();
    Fluttertoast.showToast(
      msg: 'Address "${entry.name}" added.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

  }

  Future<void> updateAddress(AddressEntry entry) async {
    final idx = addresses.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      addresses[idx] = entry;
      addresses.refresh();
      await saveAddresses();
      Fluttertoast.showToast(
        msg: 'Address "${entry.name}" updated.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> deleteAddress(String id) async {
    final idx = addresses.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = addresses.removeAt(idx);
      await saveAddresses();
      Fluttertoast.showToast(
        msg: 'Address "${removed.name}" removed.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> copyToClipboard(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
  }
}