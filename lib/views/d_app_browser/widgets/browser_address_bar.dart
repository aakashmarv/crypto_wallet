import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BrowserAddressBar extends StatefulWidget {
  final String currentUrl;
  final Function(String) onUrlSubmitted;
  final VoidCallback onRefresh;
  final bool isLoading;

  const BrowserAddressBar({
    Key? key,
    required this.currentUrl,
    required this.onUrlSubmitted,
    required this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<BrowserAddressBar> createState() => _BrowserAddressBarState();
}

class _BrowserAddressBarState extends State<BrowserAddressBar> {
  late TextEditingController _urlController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentUrl);
  }

  @override
  void didUpdateWidget(BrowserAddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.currentUrl != oldWidget.currentUrl) {
      _urlController.text = widget.currentUrl;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    String url = _urlController.text.trim();
    if (url.isNotEmpty) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      widget.onUrlSubmitted(url);
      _isEditing = false;
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // URL Input Field
          Expanded(
            child: Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      _isEditing ? AppTheme.accentTeal : AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _urlController,
                onTap: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                onSubmitted: (_) => _handleSubmit(),
                onEditingComplete: _handleSubmit,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter URL or search DApps...',
                  hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.h,
                  ),
                  prefixIcon: Container(
                    width: 6.w,
                    height: 6.w,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.lock,
                      size: 4.w,
                      color: widget.currentUrl.startsWith('https://')
                          ? AppTheme.successGreen
                          : AppTheme.textSecondary,
                    ),
                  ),
                  suffixIcon: _isEditing && _urlController.text.isNotEmpty
                      ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _urlController.clear();
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 4.w,
                      color: AppTheme.textSecondary,
                    ),
                  )
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          // Refresh Button
          // GestureDetector(
          //   onTap: widget.onRefresh,
          //   child: Container(
          //     width: 10.w,
          //     height: 5.h,
          //     decoration: BoxDecoration(
          //       color: AppTheme.secondaryDark,
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(
          //         color: AppTheme.borderSubtle,
          //         width: 1,
          //       ),
          //     ),
          //     child: widget.isLoading
          //         ? Center(
          //             child: SizedBox(
          //               width: 4.w,
          //               height: 4.w,
          //               child: CircularProgressIndicator(
          //                 strokeWidth: 2,
          //                 valueColor: AlwaysStoppedAnimation<Color>(
          //                   AppTheme.accentTeal,
          //                 ),
          //               ),
          //             ),
          //           )
          //         : Icon(
          //             Icons.refresh,
          //             size: 5.w,
          //             color: AppTheme.textSecondary,
          //           ),
          //   ),
          // ),
          GestureDetector(
            onTap: _handleSubmit, // ✅ now search triggers load
            child: Container(
              width: 10.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: widget.isLoading
                  ? Center(
                child: SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentTeal,
                    ),
                  ),
                ),
              )
                  : Icon(
                Icons.search, // ✅ changed icon
                size: 5.w,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
