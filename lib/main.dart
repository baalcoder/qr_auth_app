import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_auth_app/core/pigeon/auth_qr_api.g.dart';
import 'package:qr_auth_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qr_auth_app/features/auth/presentation/pages/auth_page.dart';
import 'package:qr_auth_app/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(BiometricApi()),
        ),
        BlocProvider(
          create: (context) => QRScannerBloc(QRScannerApi()),
        ),
      ],
      child: MaterialApp(
        title: 'QR Scanner App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthPage(),
      ),
    );
  }
}
