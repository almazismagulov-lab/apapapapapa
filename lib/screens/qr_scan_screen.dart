import 'package:astana_explorer/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  // Контроллер для управления камерой
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR'),
        actions: [
          // Кнопка вспышки (Torch)
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller, // Слушаем сам контроллер
              builder: (context, state, child) {
                // Получаем состояние из state.torchState
                return Icon(
                  state.torchState == TorchState.off
                      ? Icons.flash_off
                      : Icons.flash_on,
                  color: Colors.grey,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          // Кнопка переключения камеры (Front/Back)
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller, // Слушаем сам контроллер
              builder: (context, state, child) {
                // Используем state.cameraDirection вместо cameraFacingState
                return Icon(
                  state.cameraDirection == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                  color: Colors.grey,
                );
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) {
          if (_isProcessing) return;
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String code = barcode.rawValue!;
              _handleQrCode(code);
              break; 
            }
          }
        },
      ),
    );
  }

  void _handleQrCode(String code) {
    setState(() {
      _isProcessing = true;
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final message = gameProvider.processQrCode(code);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Результат"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}