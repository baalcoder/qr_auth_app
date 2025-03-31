import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_auth_app/core/theme/app_theme.dart';
import 'package:qr_auth_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qr_auth_app/features/auth/presentation/widgets/pin_dialog.dart';
import 'package:qr_auth_app/features/qr_scanner/presentation/pages/qr_scanner_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Authentication',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const QRScannerPage(),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white.withOpacity(0.9),Colors.white.withOpacity(0.3), AppTheme.primaryColor.withOpacity(0.9),],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (state is AuthLoading)
                      const CircularProgressIndicator()
                    else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          elevation: 5,
                        ),
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(AuthenticateWithBiometric());
                        },
                        label: const Text(
                          'Authenticate with Biometrics',
                          style: TextStyle(
                            color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          final pin = await showDialog<String>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const PinDialog(),
                          );
                          if (pin != null && context.mounted) {
                            context
                                .read<AuthBloc>()
                                .add(AuthenticateWithPIN(pin));
                          }
                        },
                        child: const Text(
                          'Use PIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
