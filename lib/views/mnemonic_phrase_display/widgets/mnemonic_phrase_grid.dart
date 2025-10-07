import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MnemonicPhraseGrid extends StatefulWidget {
  final List<String> mnemonicWords;
  final bool isRevealed;
  final VoidCallback onRevealToggle;

  const MnemonicPhraseGrid({
    Key? key,
    required this.mnemonicWords,
    required this.isRevealed,
    required this.onRevealToggle,
  }) : super(key: key);

  @override
  State<MnemonicPhraseGrid> createState() => _MnemonicPhraseGridState();
}

class _MnemonicPhraseGridState extends State<MnemonicPhraseGrid> {
  int? _selectedWordIndex;

  void _showMnemonicQrCode() {
    final phrase = widget.mnemonicWords.join(' ');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width:double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentTeal.withOpacity(0.1),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mnemonic QR Code',
                style: TextStyle(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp
                ),
              ),
              const SizedBox(height: 8),
              // QR Code with container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: phrase,
                  version: QrVersions.auto,
                  size: 150,
                  gapless: false,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal.withOpacity(0.15),
                    foregroundColor: AppTheme.accentTeal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.accentTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyPhraseToClipboard() {
    final phrase = widget.mnemonicWords.join(' ');
    Clipboard.setData(ClipboardData(text: phrase));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.warningOrange,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Security Warning',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.warningOrange,
              ),
            ),
          ],
        ),
        content: Text(
          'Your recovery phrase has been copied to clipboard. It will be automatically cleared in 60 seconds for security.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: TextStyle(color: AppTheme.accentTeal),
            ),
          ),
        ],
      ),
    );

    // Auto-clear clipboard after 60 seconds
    Future.delayed(const Duration(seconds: 60), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Reveal/Hide Button
          if (!widget.isRevealed)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.visibility_off,
                    color: AppTheme.textSecondary,
                    size: 12.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Your recovery phrase is hidden for security',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Tap below to reveal your 12-word recovery phrase',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: widget.onRevealToggle,
                    icon: Icon(
                      Icons.visibility,
                      color: AppTheme.primaryDark,
                      size: 5.w,
                    ),
                    label: Text('Reveal Recovery Phrase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentTeal,
                      foregroundColor: AppTheme.primaryDark,
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),
            ),

          // Mnemonic Grid
          if (widget.isRevealed) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Recovery Phrase',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onRevealToggle,
                      icon: Icon(
                        Icons.visibility_off,
                        color: AppTheme.textSecondary,
                        size: 5.w,
                      ),
                    ),
                    IconButton(
                      onPressed: _showMnemonicQrCode,
                      icon: Icon(
                        Icons.qr_code,
                        color: AppTheme.textSecondary,
                        size: 5.w,
                      ),
                    ),
                    IconButton(
                      onPressed: _copyPhraseToClipboard,
                      icon: Icon(
                        Icons.copy_all,
                        color: AppTheme.accentTeal,
                        size: 5.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.w,
                childAspectRatio: 2.5,
              ),
              itemCount: widget.mnemonicWords.length,
              itemBuilder: (context, index) {
                final word = widget.mnemonicWords[index];
                final isSelected = _selectedWordIndex == index;

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedWordIndex = isSelected ? null : index;
                  }),
                  // onLongPress: () => _showWordDefinition(index, word),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentTeal.withValues(alpha: 0.1)
                          : AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.accentTeal
                            : AppTheme.textSecondary,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 8.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          word,
                          style: AppTheme.monoTextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.accentTeal
                                : AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
