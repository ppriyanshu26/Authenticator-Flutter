import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => QrScanScreenState();
}

class QrScanScreenState extends State<QrScanScreen> {
  late final MobileScannerController controller;
  bool scanned = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
      );
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      controller.dispose();
    }
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) async {
    if (scanned) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value == null || !value.startsWith('otpauth://')) return;

    scanned = true;

    if (Platform.isAndroid || Platform.isIOS) {
      await controller.stop();
    }

    if (!mounted) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan QR')),
        body: const Center(
          child: Text('QR scanning is not available on this platform'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: MobileScanner(controller: controller, onDetect: onDetect),
    );
  }
}
