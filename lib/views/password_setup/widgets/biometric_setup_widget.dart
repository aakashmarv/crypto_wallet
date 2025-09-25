import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricSetupWidget extends StatefulWidget {
  final bool isBiometricEnabled;
  final ValueChanged<bool> onBiometricToggle;

  const BiometricSetupWidget({
    Key? key,
    required this.isBiometricEnabled,
    required this.onBiometricToggle,
  }) : super(key: key);

  @override
  State<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends State<BiometricSetupWidget> {
  bool _isBiometricAvailable = false;
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      // Simulate biometric availability check
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock biometric availability based on platform
      setState(() {
        _isBiometricAvailable = true;
        _biometricType = Theme.of(context).platform == TargetPlatform.iOS
            ? 'Face ID / Touch ID'
            : 'Fingerprint';
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value && _isBiometricAvailable) {
      try {
        // Provide haptic feedback
        HapticFeedback.lightImpact();

        // Show biometric prompt simulation
        await _showBiometricPrompt();

        widget.onBiometricToggle(true);
      } catch (e) {
        // Handle biometric setup failure
        _showBiometricError();
      }
    } else {
      widget.onBiometricToggle(false);
    }
  }

  Future<void> _showBiometricPrompt() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: Theme.of(context).platform == TargetPlatform.iOS
                    ? 'face'
                    : 'fingerprint',
                color: AppTheme.accentTeal,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Enable $_biometricType',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Use your $_biometricType to quickly and securely access your wallet.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                throw Exception('Biometric setup cancelled');
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Simulate biometric authentication
                await Future.delayed(const Duration(milliseconds: 1000));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.primaryDark,
              ),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  void _showBiometricError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to setup $_biometricType. Please try again.',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: Theme.of(context).platform == TargetPlatform.iOS
                    ? 'face'
                    : 'fingerprint',
                color: _isBiometricAvailable
                    ? AppTheme.accentTeal
                    : AppTheme.textSecondary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable $_biometricType',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _isBiometricAvailable
                          ? 'Quick and secure access to your wallet'
                          : '$_biometricType not available on this device',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.isBiometricEnabled && _isBiometricAvailable,
                onChanged:
                    _isBiometricAvailable ? _handleBiometricToggle : null,
                activeColor: AppTheme.accentTeal,
                inactiveThumbColor: AppTheme.textSecondary,
                inactiveTrackColor: AppTheme.borderSubtle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
