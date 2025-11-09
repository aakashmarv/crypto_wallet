import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../constants/bip39_wordlist.dart';
import '../../../core/app_export.dart';

class BackupVerificationDialog extends StatefulWidget {
  final List<String> mnemonicWords;
  final VoidCallback onVerificationComplete;

  const BackupVerificationDialog({
    Key? key,
    required this.mnemonicWords,
    required this.onVerificationComplete,
  }) : super(key: key);

  @override
  State<BackupVerificationDialog> createState() =>
      _BackupVerificationDialogState();
}

class _BackupVerificationDialogState extends State<BackupVerificationDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<int> _verificationIndices = [];
  List<String?> _userAnswers = [];
  int _currentStep = 0;
  bool _isVerificationComplete = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _generateVerificationQuestions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateVerificationQuestions() {
    final rand = Random.secure();

    final allIndices =
        List<int>.generate(widget.mnemonicWords.length, (i) => i);
    allIndices.shuffle(rand);

    _verificationIndices = allIndices.take(3).toList(); // keep order as-is
    _userAnswers = List<String?>.filled(3, null);
  }

  void _submitAnswer(String answer) {
    setState(() {
      _userAnswers[_currentStep] = answer;
      _hasError = false;

      if (_currentStep < 2) {
        _currentStep++;
      } else {
        _verifyAnswers();
      }
    });
  }

  void _verifyAnswers() {
    bool allCorrect = true;
    for (int i = 0; i < _verificationIndices.length; i++) {
      final correctWord = widget.mnemonicWords[_verificationIndices[i]];
      if (_userAnswers[i]?.toLowerCase() != correctWord.toLowerCase()) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() => _isVerificationComplete = true);
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        widget.onVerificationComplete();
      });
    } else {
      setState(() {
        _hasError = true;
        _currentStep = 0;
        _userAnswers = List.filled(3, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 90.w,
            maxHeight: 70.h,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.floatingShadow,
          ),
          child: _isVerificationComplete
              ? _buildSuccessView()
              : _buildVerificationView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.successGreen,
                size: 12.w,
              )),
          SizedBox(height: 3.h),
          Text(
            'Backup Verified!',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.successGreen,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'Your recovery phrase has been successfully verified. Your wallet is now secure!',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationView() {
    final currentWordIndex = _verificationIndices[_currentStep];
    final wordOptions = _generateWordOptions(currentWordIndex);

    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verify Backup',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textSecondary,
                  size: 6.w,
                ),
              ),
            ],
          ),

          // Progress indicator
          SizedBox(height: 2.h),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? AppTheme.accentTeal
                        : AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 4.h),

          // Error message
          if (_hasError) ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorRed.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error,
                    color: AppTheme.errorRed,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Incorrect words selected. Please try again.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Question
          Text(
            'Select word #${currentWordIndex + 1}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          // SizedBox(height: 3.h),

          // Word options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 3,
            ),
            itemCount: wordOptions.length,
            itemBuilder: (context, index) {
              final word = wordOptions[index];
              return ElevatedButton(
                onPressed: () => _submitAnswer(word),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: AppTheme.secondaryLight,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  side: BorderSide(
                    color: AppTheme.borderSubtle,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  word,
                  style: AppTheme.monoTextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          Text(
            'Step ${_currentStep + 1} of 3',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateWordOptions(int correctIndex) {
    // 1. Sahi shabd (Correct Word)
    final correctWord = widget.mnemonicWords[correctIndex];

    // 2. BIP-39 ki poori list (2048 words)
    // 💡 Ab sirf reference kiya ja raha hai, list baar-baar nahi banegi
    final allWords = BIP39_WORDLIST_ENGLISH;

    final options = <String>[correctWord];
    final rand = Random.secure(); // Secure random generator

    // 3. 3 galat shabdon ko chunna (Add 3 random incorrect words)
    while (options.length < 4) {
      // Random index generate karna (0 se list ki length tak)
      final randomIndex = rand.nextInt(allWords.length);
      final randomWord = allWords[randomIndex];

      // Double check karna ki chuna hua shabd:
      // a) Pehle se options mein na ho
      // b) User ki original seed phrase (mnemonicWords) mein na ho
      if (!options.contains(randomWord) &&
          !widget.mnemonicWords.contains(randomWord)) {
        options.add(randomWord);
      }
    }

    // 4. Options ko shuffle karna (Shuffle the options)
    options.shuffle(rand);

    return options;
  }
}
