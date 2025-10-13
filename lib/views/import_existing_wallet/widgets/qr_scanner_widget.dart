import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class QrScannerWidget {
  final BuildContext context;
  final Function(String) onScanComplete;

  QrScannerWidget({required this.context, required this.onScanComplete}) {
    _startScanner();
  }

  Future<void> _startScanner() async {
    // Check and request camera permission
    var status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan QR codes.'),
          ),
        );
        return;
      }
    }

    // Navigate to scanner screen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _QrScannerScreen(),
      ),
    );

    if (result != null && result is String && result.isNotEmpty) {
      onScanComplete(result);
    }
  }
}

class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _isScanned = false; // Prevent multiple scans quickly

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isScanned) return; // ignore duplicates
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null) {
                  _isScanned = true;
                  Navigator.of(context).pop(code);
                }
              }
            },
          ),
          // Scanner overlay
          Center(
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.accentTeal,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 5.h,
            left: 0,
            right: 0,
            child: Text(
              'Position the QR code within the frame',
              textAlign: TextAlign.center,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
