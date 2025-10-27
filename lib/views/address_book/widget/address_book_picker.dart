import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/address_entry.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helper_util.dart';
import '../../../viewmodels/address_book_controller.dart';

/// 📘 Reusable bottom sheet for selecting an address from Address Book
class AddressBookPicker extends StatelessWidget {
  final AddressBookController controller = Get.put(AddressBookController());
  final void Function(AddressEntry selected)? onSelect;

  AddressBookPicker({super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 🔹 Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // 🔍 Header
              Text(
                "Select Address",
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // 🧠 List of addresses
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.tealAccent));
                  }

                  final addresses = controller.addresses;
                  if (addresses.isEmpty) {
                    return Center(
                      child: Text(
                        "No saved addresses found.",
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => Divider(
                      color: AppTheme.borderSubtle,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final entry = addresses[index];
                      return _AddressTile(
                        entry: entry,
                        onSelect: (entry) {
                          onSelect?.call(entry);
                          Navigator.pop(context, entry);
                        },
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

/// 📍 Address Item Tile used inside Picker
class _AddressTile extends StatelessWidget {
  final AddressEntry entry;
  final void Function(AddressEntry entry)? onSelect;

  const _AddressTile({required this.entry, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppTheme.accentTeal.withOpacity(0.15),
        child: Text(
          entry.name.isNotEmpty ? entry.name[0].toUpperCase() : "?",
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        entry.name,
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        HelperUtil.shortAddress(entry.address),
        style: GoogleFonts.jetBrainsMono(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      onTap: () => onSelect?.call(entry),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
