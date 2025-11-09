import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/app_keys.dart';
import '../../core/app_export.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../utils/logger.dart';
import './widgets/browser_address_bar.dart';
import './widgets/browser_navigation_controls.dart';
import './widgets/connection_status_widget.dart';
import './widgets/dapp_bookmark_bar.dart';
import './widgets/transaction_approval_dialog.dart';

class DAppBrowser extends StatefulWidget {
  const DAppBrowser({Key? key}) : super(key: key);

  @override
  State<DAppBrowser> createState() => _DAppBrowserState();
}

class _DAppBrowserState extends State<DAppBrowser>
    with TickerProviderStateMixin {
  late WebViewController _webViewController;
  late TabController _tabController;

  // String _currentUrl = 'https://app.uniswap.org';
  String _currentUrl = 'https://www.google.com/';
  bool _isLoading = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isConnected = true;
  bool _isBookmarked = false;
  String _selectedNetwork = 'Ruby';
  final RxString _walletAddress = ''.obs;

  final List<String> _bookmarkedUrls = [
    'https://app.uniswap.org',
    'https://opensea.io',
    'https://app.compound.finance',
  ];

  final List<Map<String, dynamic>> _mockTransactionHistory = [
    {
      'hash': '0x1a2b3c4d5e6f7890abcdef1234567890abcdef12',
      'type': 'Swap',
      'amount': '0.5 ETH',
      'status': 'Confirmed',
      'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
      'dapp': 'Uniswap',
    },
    {
      'hash': '0x9876543210fedcba0987654321fedcba09876543',
      'type': 'NFT Purchase',
      'amount': '0.08 ETH',
      'status': 'Confirmed',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'dapp': 'OpenSea',
    },
    {
      'hash': '0xabcdef1234567890abcdef1234567890abcdef12',
      'type': 'Lending',
      'amount': '1.2 ETH',
      'status': 'Pending',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
      'dapp': 'Compound',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _getWalletAddress();
    _initializeWebView();

    /// blackscreen ke liy
    // _webViewController = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onPageStarted: (String url) {
    //         setState(() {
    //           _isLoading = true;
    //           _currentUrl = url;
    //           _isBookmarked = _bookmarkedUrls.contains(url);
    //         });
    //       },
    //       onPageFinished: (String url) async {
    //         setState(() {
    //           _isLoading = false;
    //         });
    //         await _updateNavigationState();
    //         await _injectWeb3();
    //       },
    //     ),
    //   );
  }

  Future<void> _getWalletAddress() async {
    final prefs = await SharedPreferencesService.getInstance();
    _walletAddress.value = prefs.getString(AppKeys.walletAddress) ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _isBookmarked = _bookmarkedUrls.contains(url);
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            await _updateNavigationState();
            await _injectWeb3();
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _webViewController.canGoBack();
    final canGoForward = await _webViewController.canGoForward();
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  Future<void> _injectWeb3() async {
    final web3Script = '''
      window.ethereum = {
        isMetaMask: true,
        isConnected: () => true,
        request: async (args) => {
          if (args.method === 'eth_requestAccounts') {
            return ['$_walletAddress'];
          }
          if (args.method === 'eth_accounts') {
            return ['$_walletAddress'];
          }
          if (args.method === 'eth_chainId') {
            return '0x1';
          }
          if (args.method === 'eth_sendTransaction') {
            window.flutter_inappwebview.callHandler('showTransactionDialog', args.params[0]);
            return '0x' + Math.random().toString(16).substr(2, 64);
          }
          return null;
        },
        selectedAddress: '$_walletAddress',
        chainId: '0x1',
        networkVersion: '1'
      };
      
      window.dispatchEvent(new Event('ethereum#initialized'));
    ''';

    try {
      await _webViewController.runJavaScript(web3Script);
    } catch (e) {
      if (kDebugMode) {
        appLog('Web3 injection error: $e');
      }
    }
  }

  void _handleUrlSubmitted(String url) {
    setState(() {
      _currentUrl = url;
      _isBookmarked = _bookmarkedUrls.contains(url);
    });
    _webViewController.loadRequest(Uri.parse(url));
  }

  void _refreshPage() {
    _webViewController.reload();
  }

  void _goBack() {
    if (_canGoBack) {
      _webViewController.goBack();
    }
  }

  void _goForward() {
    if (_canGoForward) {
      _webViewController.goForward();
    }
  }

  void _goHome() {
    // _handleUrlSubmitted('https://app.uniswap.org');
    _handleUrlSubmitted('https://www.google.com/');
  }

  void _toggleBookmark() {
    setState(() {
      if (_isBookmarked) {
        _bookmarkedUrls.remove(_currentUrl);
        _isBookmarked = false;
      } else {
        _bookmarkedUrls.add(_currentUrl);
        _isBookmarked = true;
      }
    });
  }

  void _handleNetworkChanged(String network) {
    setState(() {
      _selectedNetwork = network;
    });
    _injectWeb3();
  }

  void _showTransactionApproval(Map<String, dynamic> transactionData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransactionApprovalDialog(
        transactionData: transactionData,
        onApprove: () {
          Navigator.pop(context);
          _showTransactionSuccess();
        },
        onReject: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTransactionSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction submitted successfully'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      body: SafeArea(
        child: Column(
          children: [
            // Connection Status
            Obx(() => ConnectionStatusWidget(
                  isConnected: _isConnected,
                  walletAddress: _walletAddress.value,
                  selectedNetwork: _selectedNetwork,
                  // onNetworkChanged: _handleNetworkChanged,
                  onNetworkChanged: null,
                )),
            // Address Bar
            BrowserAddressBar(
              currentUrl: _currentUrl,
              onUrlSubmitted: _handleUrlSubmitted,
              onRefresh: _refreshPage,
              isLoading: _isLoading,
            ),
            // Bookmark Bar
            // DAppBookmarkBar(
            //   onDAppSelected: _handleUrlSubmitted,
            // ),
            // WebView
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppTheme.borderSubtle,
                    width: 0.5,
                  ),
                ),
                child: WebViewWidget(
                  controller: _webViewController,
                ),
              ),
            ),
            // Navigation Controls
            BrowserNavigationControls(
              canGoBack: _canGoBack,
              canGoForward: _canGoForward,
              onBack: _goBack,
              onForward: _goForward,
              onHome: _goHome,
              onBookmark: _toggleBookmark,
              isBookmarked: _isBookmarked,
              isSecure: _currentUrl.startsWith('https://'),
            ),
          ],
        ),
      ),
    );
  }
}
