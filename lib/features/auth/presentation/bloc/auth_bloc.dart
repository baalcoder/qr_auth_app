import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_auth_app/core/pigeon/auth_qr_api.g.dart';

// Events
abstract class AuthEvent {}

class AuthenticateWithBiometric extends AuthEvent {}

class AuthenticateWithPIN extends AuthEvent {
  final String pin;
  AuthenticateWithPIN(this.pin);
}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final BiometricApi _biometricApi;

  AuthBloc(this._biometricApi) : super(AuthInitial()) {
    on<AuthenticateWithBiometric>(_onAuthenticateWithBiometric);
    on<AuthenticateWithPIN>(_onAuthenticateWithPIN);
  }

  Future<void> _onAuthenticateWithBiometric(
    AuthenticateWithBiometric event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAvailable = await _biometricApi.isBiometricAvailable();
      if (!isAvailable) {
        emit(AuthFailure('Biometric authentication not available'));
        return;
      }

      final config = AuthConfig()
        ..title = 'Biometric Authentication'
        ..subtitle = 'Please authenticate to continue'
        ..negativeButtonText = 'Cancel';

      try {
        final result = await _biometricApi.authenticate(config);
        if (result.success == true) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure(result.error ?? 'Authentication failed'));
        }
      } catch (e) {
        emit(AuthFailure('Authentication failed: ${e.toString()}'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthenticateWithPIN(
    AuthenticateWithPIN event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // En un caso real, deberías validar contra un PIN almacenado de forma segura
      // Por ahora, usaremos un PIN de ejemplo: "1234"
      if (event.pin == "1234") {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure('PIN incorrecto'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}