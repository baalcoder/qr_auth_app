import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_auth_app/core/theme/app_theme.dart';
import 'package:qr_auth_app/core/widgets/custom_tooltip.dart';
import 'package:qr_auth_app/features/qr_scanner/domain/models/qr_code.dart';
import 'package:qr_auth_app/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  final MobileScannerController scannerController = MobileScannerController();

  bool isScanning = false; // 🔹 Controla si el escáner está activo

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _requestCameraPermission();
    _startScanning();
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
    });
    context.read<QRScannerBloc>().add(StartScanning());
  }

  void _stopScanning() {
    setState(() {
      isScanning = false;
    });
    context.read<QRScannerBloc>().add(StopScanning());
  }

  @override
  void dispose() {
    _stopScanning();
    scannerController.dispose();
    _scanLineController.dispose();
    context.read<QRScannerBloc>().add(StopScanning());
    super.dispose();
  }

  void _initAnimations() {
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scanLineController);
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) {
        context.read<QRScannerBloc>().add(StartScanning());
      }
    } else {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de Cámara Requerido'),
        content: const Text(
          'Para escanear códigos QR, necesitamos acceder a la cámara. '
          'Por favor, concede el permiso en la configuración de tu dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            child: const Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<QRScannerBloc, QRScannerState>(
        listener: (context, state) {
          if (state is QRCodeFound) {
            _stopScanning(); // 🔹 Detener escáner al detectar QR

            _showQRFoundOverlay(state.data);
          } else if (state is QRScannerError) {
            _showErrorSnackbar(state.error);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Fondo con gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.3),
                      Colors.blueAccent.withOpacity(0.9),
                    ],
                  ),
                ),
              ),

              // Contenido principal
              Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _buildScannerArea(state),
                  ),
                  _buildBottomPanel(state),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Escáner QR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomTooltip(
            message: 'Ayuda',
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerArea(QRScannerState state) {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Vista previa de la cámara
          MobileScanner(
            fit: BoxFit.cover,
            controller: scannerController,
            onDetect: (barcode) {
              if (barcode.raw != null) {
                context
                    .read<QRScannerBloc>()
                    .add(QRCodeDetected(barcode.raw.toString()));
              }
            },
          ),

          /// 🔄 **Botón para reactivar el escáner**
          if (!isScanning)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: _startScanning,
                        icon: const Icon(Icons.qr_code),
                        label: const Text("Scan Again"),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Línea de escaneo animada
          if (state is QRScannerStarted)
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanLineAnimation.value *
                      MediaQuery.of(context).size.height *
                      0.5,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0),
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Esquinas decorativas
          ...List.generate(4, (index) {
            final isTop = index < 2;
            final isLeft = index.isEven;
            return Positioned(
              top: isTop ? 0 : null,
              bottom: !isTop ? 0 : null,
              left: isLeft ? 0 : null,
              right: !isLeft ? 0 : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: isTop
                        ? const BorderSide(
                            color: AppTheme.primaryColor, width: 4)
                        : BorderSide.none,
                    bottom: !isTop
                        ? const BorderSide(
                            color: AppTheme.primaryColor, width: 4)
                        : BorderSide.none,
                    left: isLeft
                        ? const BorderSide(
                            color: AppTheme.primaryColor, width: 4)
                        : BorderSide.none,
                    right: !isLeft
                        ? const BorderSide(
                            color: AppTheme.primaryColor, width: 4)
                        : BorderSide.none,
                  ),
                ),
              ),
            );
          }),

          // Mensaje de guía
          if (isScanning)
            if (state is QRScannerStarted)
              FadeIn(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Apunta al código QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(QRScannerState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Último código escaneado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildScannedCodesList(state),
                SizedBox(
                  height: 48,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQRFoundOverlay(String data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código QR detectado',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(error),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    // Implementar la copia al portapapeles
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado al portapapeles'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showHelpDialog() {
    _stopScanning();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo escanear'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.qr_code,
              text: 'Asegúrate de que el código QR esté bien iluminado',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.center_focus_strong,
              text: 'Centra el código QR en el área de escaneo',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.height,
              text: 'Mantén una distancia de 15-30 cm del código',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }

  /// 🔍 **Lista de códigos QR escaneados**
  Widget _buildScannedCodesList(QRScannerState state) {
    final List<QRCode> codes = _getCodesFromState(state);

    if (codes.isEmpty) {
      return const Center(
        child: Text(
          'No QR codes scanned yet',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      height: 200,
      child: ListView.builder(
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
              title: Text(
                code.data,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              subtitle: Text(
                _formatDateTime(code.timestamp),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.white60),
              ),
              trailing: const Icon(Icons.qr_code, color: Colors.white),
            ),
          );
        },
      ),
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
