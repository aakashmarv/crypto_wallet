import 'package:cryptovault_pro/views/import_existing_wallet/widgets/qr_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sizer/sizer.dart';
import '../../../constants/bip39_wordlist.dart';
import '../../../core/app_export.dart';

class MnemonicInputWidget extends StatefulWidget {
  final Function(String) onMnemonicChanged;
  final Function(bool) onValidationChanged;
  final String? initialValue;

  const MnemonicInputWidget({
    Key? key,
    required this.onMnemonicChanged,
    required this.onValidationChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<MnemonicInputWidget> createState() => _MnemonicInputWidgetState();
}

class _MnemonicInputWidgetState extends State<MnemonicInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RxList<String> _words = <String>[].obs;
  final RxBool _isValid = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _validateMnemonic(widget.initialValue!);
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    _validateMnemonic(text);
    widget.onMnemonicChanged(text);
  }

  void _validateMnemonic(String text) {
    final trimmed = text.trim();

    // 🔹 Detect Private Key Format (64 hex characters, optional 0x)
    final isPrivateKey = RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(trimmed);

    if (isPrivateKey) {
      _isValid.value = true;
      widget.onValidationChanged(true);
      return;
    }

    // 🔹 Otherwise, validate mnemonic as before
    final words = trimmed.toLowerCase().split(RegExp(r'\s+'));
    final validWordCount = words.length == 12 || words.length == 24;
    final Set<String> _bip39Set = BIP39_WORDLIST_ENGLISH.toSet();
    final allWordsValid = words.every((w) => w.isNotEmpty && _bip39Set.contains(w));

    _words.value = words;
    _isValid.value = validWordCount && allWordsValid && trimmed.isNotEmpty;

    widget.onValidationChanged(_isValid.value);
  }

  void _insertWord(String word) {
    final text = _controller.text;
    final selection = _controller.selection;
    // Find last space before cursor (to detect last word boundary)
    int lastSpaceIndex = text.lastIndexOf(' ', selection.baseOffset - 1);
    // Keep everything before that space
    String prefix =
        lastSpaceIndex == -1 ? '' : text.substring(0, lastSpaceIndex + 1);
    // Replace last typed part (prefix) with selected word
    String newText = '$prefix$word ';
    // Update text field
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    // Trigger validation + callback
    _validateMnemonic(newText);
    widget.onMnemonicChanged(newText);
  }

  List<String> _getSuggestions() {
    final currentText = _controller.text.toLowerCase();
    final words = currentText.split(RegExp(r'\s+'));
    final lastWord = words.isNotEmpty ? words.last : '';

    if (lastWord.isEmpty) return [];

    return BIP39_WORDLIST_ENGLISH
        .where((word) => word.startsWith(lastWord) && word != lastWord)
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestions = _getSuggestions();

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark      //change
            ? AppTheme.surfaceElevatedDark                          //change
            : AppTheme.accentTherd.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isValid.value
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recovery Phrase',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  QrScannerWidget(
                    context: context,
                    onScanComplete: (scannedData) {
                      setState(() {
                        _controller.text = scannedData.trim();
                      });
                      _validateMnemonic(scannedData.trim());
                      widget.onMnemonicChanged(scannedData.trim());
                    },
                  );
                },
                child: Icon(
                  LucideIcons.scanLine,
                  color: AppTheme.accentTeal,
                  size: 22,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            style: AppTheme.monoTextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your mnemonic, private key or Scan',
              hintStyle: AppTheme.monoTextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: isDark
                  ? AppTheme.shadowColorDark
                  : Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(horizontal:4.w, vertical: 8.w),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_words.length} words',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _isValid.value
                      ? AppTheme.successGreen
                      : AppTheme.textSecondary,
                ),
              ),
              Row(
                children: [
                  if (_isValid.value) ...[
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successGreen,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Valid',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(width: 5.w),
                  GestureDetector(
                    onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null && data!.text!.isNotEmpty) {
                        _controller.text = data.text!.trim();
                        _validateMnemonic(data.text!.trim());
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentTeal.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        'Paste',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (suggestions.isNotEmpty) ...[
            // SizedBox(height: 2.h),
            Text(
              'Suggestions',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: suggestions
                  .map((word) => GestureDetector(
                        onTap: () => _insertWord(word),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accentTeal.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            word,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
