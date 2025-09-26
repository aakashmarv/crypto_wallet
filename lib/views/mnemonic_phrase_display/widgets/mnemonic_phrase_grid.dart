import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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

  void _showWordDefinition(int index, String word) {
    final definitions = {
      'abandon': 'To give up completely',
      'ability': 'The capacity to do something',
      'able': 'Having the power or skill to do something',
      'about': 'Concerning or regarding',
      'above': 'In a higher position than',
      'absent': 'Not present or available',
      'absorb': 'To take in or soak up',
      'abstract': 'Existing in thought but not physical',
      'absurd': 'Wildly unreasonable or illogical',
      'abuse': 'To use wrongly or improperly',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Word #${index + 1}: $word',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.accentTeal,
          ),
        ),
        content: Text(
          definitions[word.toLowerCase()] ?? 'A word in your recovery phrase',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: AppTheme.accentTeal),
            ),
          ),
        ],
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
                  onLongPress: () => _showWordDefinition(index, word),
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
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentTeal.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppTheme.accentTeal,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Long press any word to see its definition',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentTeal,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
