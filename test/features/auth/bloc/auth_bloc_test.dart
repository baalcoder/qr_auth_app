import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:qr_auth_app/core/pigeon/auth_qr_api.g.dart';
import 'package:qr_auth_app/features/auth/presentation/bloc/auth_bloc.dart';

@GenerateNiceMocks([MockSpec<BiometricApi>()])
import 'auth_bloc_test.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockBiometricApi mockBiometricApi;

  setUp(() {
    mockBiometricApi = MockBiometricApi();
    authBloc = AuthBloc(mockBiometricApi);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('AuthenticateWithPIN', () {
    test('emits [AuthLoading, AuthSuccess] when PIN is correct', () async {
      // Assert
      expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ]),
      );

      // Act
      authBloc.add(AuthenticateWithPIN('1234'));
    });

    test('emits [AuthLoading, AuthFailure] when PIN is incorrect', () async {
      // Assert
      expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ]),
      );

      // Act
      authBloc.add(AuthenticateWithPIN('0000'));
    });
  });
}