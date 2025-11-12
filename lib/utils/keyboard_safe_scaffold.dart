import 'package:flutter/material.dart';

/// 🧱 Universal Scaffold wrapper to prevent layout jumps
/// when keyboard opens or closes.
///
/// ✅ Fixes:
/// - White screen issue when IntrinsicHeight used
/// - Screen jumping / extra gap on keyboard open
/// - Keeps scroll smooth for all input forms
///
/// 🧩 Usage:
/// ```dart
/// return KeyboardSafeScaffold(
///   child: YourScreenBody(),
/// );
/// ```
class KeyboardSafeScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool showAppBar;
  final PreferredSizeWidget? appBar;

  const KeyboardSafeScaffold({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.showAppBar = false,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false, // ✅ Prevent layout resize
      appBar: showAppBar ? appBar : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true, // ✅ Smooth scroll when keyboard opens
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
