import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_auth_app/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  @override
  void initState() {
    super.initState();
    context.read<QRScannerBloc>().add(StartScanning());
  }

  @override
  void dispose() {
    context.read<QRScannerBloc>().add(StopScanning());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: BlocConsumer<QRScannerBloc, QRScannerState>(
        listener: (context, state) {
          if (state is QRCodeFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('QR Code found: ${state.data}'),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is QRScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Camera Preview',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (state is QRScannerStarted)
                const Center(
                  child: Text(
                    'Point camera at QR Code',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (state is QRCodeFound)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Last scanned: ${state.data}'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}