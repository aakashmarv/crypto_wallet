import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecurityInfoCardWidget extends StatefulWidget {
  const SecurityInfoCardWidget({Key? key}) : super(key: key);

  @override
  State<SecurityInfoCardWidget> createState() => _SecurityInfoCardWidgetState();
}

class _SecurityInfoCardWidgetState extends State<SecurityInfoCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<Map<String, dynamic>> _securityFeatures = [
    {
      'icon': 'security',
      'title': 'Secure Generation',
      'description': 'Uses device secure enclave for entropy generation',
    },
    {
      'icon': 'key',
      'title': 'Mnemonic Phrase',
      'description': '12-word recovery phrase following BIP39 standard',
    },
    {
      'icon': 'lock',
      'title': 'Private Key Protection',
      'description': 'Keys never leave your device and are encrypted',
    },
    {
      'icon': 'backup',
      'title': 'Recovery Options',
      'description': 'Multiple backup methods for wallet recovery',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentTeal.withValues(alpha: 0.1),
            AppTheme.successGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentTeal.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shield,
                      color: AppTheme.accentTeal,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Information',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Learn how we protect your wallet',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.accentTeal,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppTheme.borderSubtle.withValues(alpha: 0.5),
                    margin: EdgeInsets.only(bottom: 3.h),
                  ),
                  ..._securityFeatures
                      .map((feature) => _buildSecurityFeature(
                            feature['icon'] as String,
                            feature['title'] as String,
                            feature['description'] as String,
                          ))
                      .toList(),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warningOrange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: AppTheme.warningOrange,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Important: Write down your recovery phrase and store it safely. We cannot recover your wallet without it.',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.warningOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(
      String iconName, String title, String description) {
    // Map string names to IconData
    final Map<String, IconData> iconMap = {
      'encrypted': Icons.enhanced_encryption_rounded,
      'verified_user': Icons.verified_user,
      'lock': Icons.lock,
      // add more if needed
    };
    IconData iconData = iconMap[iconName] ?? Icons.help_outline;
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: AppTheme.successGreen,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
