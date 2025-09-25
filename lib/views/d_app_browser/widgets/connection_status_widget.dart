import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final String walletAddress;
  final String selectedNetwork;
  final Function(String) onNetworkChanged;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    required this.walletAddress,
    required this.selectedNetwork,
    required this.onNetworkChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection Status Indicator
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          // Wallet Address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color:
                        isConnected ? AppTheme.successGreen : AppTheme.errorRed,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isConnected) ...[
                  SizedBox(height: 0.2.h),
                  Text(
                    '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Network Selector
          GestureDetector(
            onTap: () => _showNetworkSelector(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getNetworkIcon(selectedNetwork),
                  SizedBox(width: 1.w),
                  Text(
                    selectedNetwork,
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    size: 4.w,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getNetworkIcon(String network) {
    Color iconColor;
    switch (network.toLowerCase()) {
      case 'ethereum':
        iconColor = const Color(0xFF627EEA);
        break;
      case 'bsc':
        iconColor = const Color(0xFFF3BA2F);
        break;
      case 'polygon':
        iconColor = const Color(0xFF8247E5);
        break;
      default:
        iconColor = AppTheme.textSecondary;
    }

    return Container(
      width: 4.w,
      height: 4.w,
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: 'account_balance_wallet',
        size: 2.5.w,
        color: Colors.white,
      ),
    );
  }

  void _showNetworkSelector(BuildContext context) {
    final networks = ['Ethereum', 'BSC', 'Polygon'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Network',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...networks.map((network) => ListTile(
                  leading: _getNetworkIcon(network),
                  title: Text(
                    network,
                    style: AppTheme.darkTheme.textTheme.bodyMedium,
                  ),
                  trailing: selectedNetwork == network
                      ? CustomIconWidget(
                          iconName: 'check',
                          size: 5.w,
                          color: AppTheme.accentTeal,
                        )
                      : null,
                  onTap: () {
                    onNetworkChanged(network);
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
