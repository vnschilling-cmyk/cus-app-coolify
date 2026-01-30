import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/guest_provider.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  const QRScannerPage({super.key});

  @override
  ConsumerState<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHECK-IN SCANNER',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!_isScanning) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _onQRCodeScanned(code);
                  break;
                }
              }
            },
          ),
          _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Corner markers
                  _buildCorner(0, 0, 32, 0),
                  _buildCorner(null, 0, 0, 32),
                  _buildCorner(0, null, 32, 0),
                  _buildCorner(null, null, 0, 32),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'SCANNE GÄSTE CODE',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w200,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(
    double? top,
    double? left,
    double? bottom,
    double? right,
  ) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top == 0
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
            left: left == 0
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
            bottom: bottom == 0
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
            right: right == 0
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft:
                top == 0 && left == 0 ? const Radius.circular(12) : Radius.zero,
            topRight: top == 0 && right == 0
                ? const Radius.circular(12)
                : Radius.zero,
            bottomLeft: bottom == 0 && left == 0
                ? const Radius.circular(12)
                : Radius.zero,
            bottomRight: bottom == 0 && right == 0
                ? const Radius.circular(12)
                : Radius.zero,
          ),
        ),
      ),
    );
  }

  void _onQRCodeScanned(String code) async {
    setState(() => _isScanning = false);

    try {
      await ref.read(guestListProvider.notifier).checkIn(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in erfolgreich!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
        setState(() => _isScanning = true);
      }
    }
  }
}
