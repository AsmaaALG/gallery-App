import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key); // إضافة const للمنشئ

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController =
      MobileScannerController(); // اجعلها final
  String? qrCodeResult;

  @override
  void dispose() {
    cameraController.dispose(); // تخلص من وحدة التحكم عند إزالة الـwidget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'), // إضافة const
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off,
                        color: Colors.grey); // إضافة const
                  case TorchState.on:
                    return const Icon(Icons.flash_on,
                        color: Colors.yellow); // إضافة const
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front); // إضافة const
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear); // إضافة const
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (capture.barcodes.isNotEmpty) {
            final String? code =
                capture.barcodes.first.rawValue; // استخدم rawValue
            if (code != null && qrCodeResult != code) {
              setState(() {
                qrCodeResult = code;
              });
              print('QR Code found! $code');
              Navigator.pop(context, code); // إرجاع النتيجة إلى الشاشة السابقة
            }
          }
        },
      ),
    );
  }
}
