import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_keys.dart';
import '../../core/app_export.dart';
import '../../servieces/sharedpreferences_service.dart';
import './widgets/onboarding_navigation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  final int _totalPages = 3;

  // Mock data for onboarding pages
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Secure Wallet Storage",
      "description":
          "Your cryptocurrency is protected with enterprise-grade security and encrypted storage.",
      "features": [
        "Military-grade encryption",
        "Biometric authentication",
        "Secure backup & recovery"
      ],
      "iconName": "security",
      "iconColor": AppTheme.accentTeal,
      "backgroundGradient": LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryLight,
          AppTheme.secondaryLight.withValues(alpha: 0.3),
        ],
      ),
    },
    {
      "title": "DApp Browser",
      "description":
          "Access decentralized applications directly from your wallet with seamless Web3 integration.",
      "features": [
        "Built-in Web3 browser",
        "DeFi protocol support",
        "Smart contract interaction"
      ],
      "iconName": "web",
      "iconColor": AppTheme.successGreen,
      "backgroundGradient": LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryLight,
          AppTheme.successGreen.withValues(alpha: 0.2),
        ],
      ),
    },
    {
      "title": "Easy Transactions",
      "description":
          "Send and receive cryptocurrency with QR codes, address book, and real-time portfolio tracking.",
      "features": [
        "QR code scanning",
        "Portfolio tracking",
        "Transaction history"
      ],
      "iconName": "account_balance_wallet",
      "iconColor": AppTheme.warningOrange,
      "backgroundGradient": LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryLight,
          AppTheme.warningOrange.withValues(alpha: 0.2),
        ],
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animation
    _animationController.forward().then((_) {
      _animationController.reset();
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToWalletSetup();
    }
  }

  void _skipOnboarding() {
    _navigateToWalletSetup();
  }

  Future<void> _navigateToWalletSetup() async {
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.setBool(AppKeys.onboardingComplete, true);
    Get.offAllNamed(AppRoutes.createNewWallet);
    // Get.offAllNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient =
        _onboardingData[_currentPage]["backgroundGradient"] as LinearGradient;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: currentGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    final pageData = _onboardingData[index];
                    return OnboardingPageWidget(
                      title: pageData["title"] as String,
                      description: pageData["description"] as String,
                      features: (pageData["features"] as List).cast<String>(),
                      iconName: pageData["iconName"] as String,
                      iconColor: pageData["iconColor"] as Color,
                      // backgroundGradient: pageData["backgroundGradient"] as LinearGradient,
                    );
                  },
                ),
              ),

              // Page Indicator
              Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: PageIndicatorWidget(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                ),
              ),

              // Navigation Buttons
              OnboardingNavigationWidget(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onSkip: _skipOnboarding,
                onNext: _nextPage,
                isLastPage: _currentPage == _totalPages - 1,
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
