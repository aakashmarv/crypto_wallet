import 'package:cryptovault_pro/utils/helper_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../models/address_entry.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/address_book_controller.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Collapse FAB when scrolling down, expand when at top or scrolling up
    if (_scrollController.offset > 50 && _isExpanded) {
      setState(() => _isExpanded = false);
    } else if (_scrollController.offset <= 50 && !_isExpanded) {
      setState(() => _isExpanded = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddressBookController ctrl = Get.put(AddressBookController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Address Book",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // optional header / explanation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                'Save frequently used wallet addresses for quick access. Tap an item to copy, or use edit/delete.',
                style: GoogleFonts.inter(
                    fontSize: 10.sp, color: Theme.of(context).colorScheme.onSurfaceVariant,),
              ),
            ),

            // list
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return _buildShimmer();
                }

                if (ctrl.addresses.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(3.w, 2.h, 3.w,
                      12.h), // Bottom padding to prevent FAB overlap
                  itemCount: ctrl.addresses.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final entry = ctrl.addresses[index];
                    return _AddressCard(
                      entry: entry,
                      onCopy: () => ctrl.copyToClipboard(entry.address),
                      onEdit: () async {
                        final updated = await showDialog<AddressEntry>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AddEditAddressDialog(entry: entry),
                        );
                        if (updated != null) await ctrl.updateAddress(updated);
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            title:  Text(
                              'Delete Address',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${entry.name}"?',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(c).pop(false),
                                  child:  Text(
                                    'Cancel',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  )),
                              TextButton(
                                  onPressed: () => Navigator.of(c).pop(true),
                                  child:  Text(
                                    'Delete',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  )),
                            ],
                          ),
                        );
                        if (confirm == true) await ctrl.deleteAddress(entry.id);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      // Animated Floating Add Button
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FloatingActionButton.extended(
          backgroundColor: AppTheme.accentTeal,
          icon: const Icon(Icons.add),
          label: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Text(
                    'Add Address',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary),
                  )
                : const SizedBox.shrink(),
          ),
          onPressed: () async {
            HapticFeedback.lightImpact();
            final newEntry = await showDialog<AddressEntry>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const AddEditAddressDialog(),
            );
            if (newEntry != null) {
              await Get.find<AddressBookController>().addAddress(newEntry);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmarks_outlined,
                size: 12.w, color: Theme.of(context).colorScheme.onSurfaceVariant),
            SizedBox(height: 2.h),
            Text('No saved addresses',
                style: GoogleFonts.inter(
                    fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface, )),
            SizedBox(height: 1.h),
            Text(
              'Tap the button below to add a new wallet address to your address book.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 10.sp, color: Theme.of(context).colorScheme.onSurfaceVariant,),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      itemCount: 4,
      itemBuilder: (_, i) => Container(
        margin: EdgeInsets.only(bottom: 2.h),
        height: 9.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntry entry;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.entry,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🟢 Avatar
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : 'A',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            )),
          ),
          SizedBox(width: 3.w),
          // 🟡 Expanded Name + Address Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Edit icon
                Row(
                  children: [
                    Text(
                      entry.name.isNotEmpty ? entry.name : "Unnamed",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 3.w),
                    GestureDetector(
                      onTap: onEdit,
                      child: Icon(
                        Icons.edit,
                        size: 11.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 0.8.h),

                // Address + Copy icon
                Row(
                  children: [
                    Text(
                      HelperUtil.shortAddress(entry.address),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: onCopy,
                      child: Icon(
                        Icons.copy,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 2.w,
          ),
          // 🔴 Delete icon (far right)
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Icon(
                Icons.delete_outline,
                size: 12.sp,
                color: AppTheme.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditAddressDialog extends StatefulWidget {
  final AddressEntry? entry;
  const AddEditAddressDialog({super.key, this.entry});

  @override
  State<AddEditAddressDialog> createState() => _AddEditAddressDialogState();
}

class _AddEditAddressDialogState extends State<AddEditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtr;
  late final TextEditingController _addressCtr;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.entry?.name ?? '');
    _addressCtr = TextEditingController(text: widget.entry?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _addressCtr.dispose();
    super.dispose();
  }

  bool _isValidAddress(String a) {
    final r = RegExp(r'^(0x|r)?[a-fA-F0-9]{40}$');
    return r.hasMatch(a.trim());
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final id =
        widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final label = _nameCtr.text.trim();
    final address = _addressCtr.text.trim();

    final entry = AddressEntry(id: id, name: label, address: address);
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(isEdit ? 'Edit Address' : 'Add Address',
          style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtr,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a label' : null,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _addressCtr,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter address';
                  if (!_isValidAddress(v)) return 'Invalid address format';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal),
          onPressed: _onSave,
          child: Text(
            isEdit ? 'Update' : 'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
