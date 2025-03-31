import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_auth_app/features/qr_scanner/domain/models/qr_code.dart';
import 'package:qr_auth_app/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    context.read<QRScannerBloc>().add(StartScanning());
  }

  @override
  void dispose() {
    context.read<QRScannerBloc>().add(StopScanning());
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
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
          return Column(
            children: [
              /// 📸 **Vista previa de la cámara**
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: scannerController,
                      onDetect: (barcode) {
                        if (barcode.raw != null) {
                          context
                              .read<QRScannerBloc>()
                              .add(QRCodeDetected(barcode.raw.toString()));
                        }
                      },
                    ),

                    /// 📍 **Indicador para guiar al usuario**
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner,
                              size: 100, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Point camera at QR Code',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// 📜 **Lista de códigos escaneados**
              Expanded(
                flex: 1,
                child: _buildScannedCodesList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔍 **Lista de códigos QR escaneados**
  Widget _buildScannedCodesList(QRScannerState state) {
    final List<QRCode> codes = _getCodesFromState(state);

    if (codes.isEmpty) {
      return const Center(
        child: Text('No QR codes scanned yet'),
      );
    }

    return ListView.builder(
      itemCount: codes.length,
      itemBuilder: (context, index) {
        final code = codes[index];
        return Dismissible(
          key: Key(code.id.toString()),
          onDismissed: (direction) {
            if (code.id != null) {
              context.read<QRScannerBloc>().add(DeleteQRCode(code.id!));
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(code.data),
            subtitle: Text(
              _formatDateTime(code.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.qr_code),
          ),
        );
      },
    );
  }

  /// 📦 **Obtener lista de códigos desde el estado del Bloc**
  List<QRCode> _getCodesFromState(QRScannerState state) {
    if (state is QRScannerStarted) return state.codes;
    if (state is QRScannerStopped) return state.codes;
    if (state is QRCodeFound) return state.codes;
    if (state is QRScannerError) return state.codes;
    return [];
  }

  /// 🕒 **Formato de fecha para mostrar timestamps**
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
