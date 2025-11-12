import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoadingAnimationWidget extends StatefulWidget {
  final String message;
  final double progress;

  const LoadingAnimationWidget({
    Key? key,
    required this.message,
    required this.progress,
  }) : super(key: key);

  @override
  State<LoadingAnimationWidget> createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  final List<String> _securitySteps = [
    'Initializing secure environment...',
    'Generating entropy from device...',
    'Creating cryptographic keys...',
    'Securing with hardware encryption...',
    'Finalizing wallet creation...',
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(LoadingAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceElevatedDark
            : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentTeal.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentTeal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Security Icon
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentTeal.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.security,
                        color: AppTheme.primaryLight,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Progress Bar
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Progress Percentage
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Main Message
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 2.h),

          // Current Security Step
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final stepIndex =
                  (_progressAnimation.value * (_securitySteps.length - 1))
                      .round();
              return Text(
                _securitySteps[stepIndex],
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Security Features
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSecurityFeature(
                  Icons.enhanced_encryption_rounded, 'Encrypted'),
              _buildSecurityFeature(Icons.verified_user, 'Verified'),
              _buildSecurityFeature(Icons.lock, 'Secured'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(IconData iconData, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: AppTheme.successGreen,
            size: 20,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.successGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
