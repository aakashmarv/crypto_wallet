import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DAppBookmarkBar extends StatelessWidget {
  final Function(String) onDAppSelected;

  const DAppBookmarkBar({
    Key? key,
    required this.onDAppSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> popularDApps = [
      {
        'name': 'Uniswap',
        'url': 'https://app.uniswap.org',
        'icon': 'swap_horiz',
        'color': const Color(0xFFFF007A),
        'category': 'DEX',
      },
      {
        'name': 'OpenSea',
        'url': 'https://opensea.io',
        'icon': 'collections',
        'color': const Color(0xFF2081E2),
        'category': 'NFT',
      },
      {
        'name': 'Compound',
        'url': 'https://app.compound.finance',
        'icon': 'trending_up',
        'color': const Color(0xFF00D395),
        'category': 'DeFi',
      },
      {
        'name': 'Aave',
        'url': 'https://app.aave.com',
        'icon': 'account_balance',
        'color': const Color(0xFFB6509E),
        'category': 'Lending',
      },
      {
        'name': 'PancakeSwap',
        'url': 'https://pancakeswap.finance',
        'icon': 'restaurant',
        'color': const Color(0xFF1FC7D4),
        'category': 'DEX',
      },
    ];

    return Container(
      height: 12.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Popular DApps',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: popularDApps.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final dapp = popularDApps[index];
                return GestureDetector(
                  onTap: () => onDAppSelected(dapp['url'] as String),
                  child: Container(
                    width: 16.w,
                    child: Column(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color:
                                (dapp['color'] as Color).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.borderSubtle,
                              width: 0.5,
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: dapp['icon'] as String,
                            size: 6.w,
                            color: dapp['color'] as Color,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          dapp['name'] as String,
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dapp['category'] as String,
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            fontSize: 8.sp,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
