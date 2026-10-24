import 'package:campus_app/mobil/features/auth/data/auth_source.dart';
import 'package:campus_app/mobil/features/auth/data/session.dart';
import 'package:campus_app/mobil/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verilen sonucu döndüren ve kaç kez çağrıldığını sayan sahte kaynak.
class FakeAuthSource implements AuthSource {
  FakeAuthSource(this.result);

  final LoginResult result;
  int calls = 0;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    calls++;
    return result;
  }
}

const session = Session(
  accessToken: 'sahte-erisim',
  refreshToken: 'sahte-yenileme',
  userId: '5c98741b-64c8-49de-9e68-3d7a2f44802b',
  fullName: 'Ayşe Yılmaz',
  role: UserRole.student,
);

Future<void> pumpScreen(
  WidgetTester tester,
  AuthSource source, {
  ValueChanged<Session>? onLoggedIn,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoginScreen(source: source, onLoggedIn: onLoggedIn ?? (_) {}),
    ),
  );
}

Future<void> login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-posta'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Şifre'), password);
  await tester.tap(find.text('Giriş yap'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsValidationError_whenEmailInvalid', (tester) async {
    final source = FakeAuthSource(const LoginSucceeded(session));
    await pumpScreen(tester, source);

    await login(tester, 'ayse', 'parola1');

    expect(find.text('Geçerli bir e-posta girin'), findsOneWidget);
    expect(source.calls, 0);
  });

  testWidgets('showsValidationError_whenPasswordTooShort', (tester) async {
    final source = FakeAuthSource(const LoginSucceeded(session));
    await pumpScreen(tester, source);

    await login(tester, 'ayse@ornek.edu', '123');

    expect(find.text('Şifre en az 6 karakter olmalı'), findsOneWidget);
    expect(source.calls, 0);
  });

  testWidgets('showsError_whenCredentialsRejected', (tester) async {
    await pumpScreen(tester, FakeAuthSource(const LoginRejected()));

    await login(tester, 'ayse@ornek.edu', 'yanlis1');

    expect(find.text('Geçersiz e-posta veya şifre'), findsOneWidget);
  });

  testWidgets('showsServerError_whenLoginFails', (tester) async {
    await pumpScreen(tester, FakeAuthSource(const LoginFailed()));

    await login(tester, 'ayse@ornek.edu', 'parola1');

    expect(find.text('Sunucu hatası, tekrar deneyin'), findsOneWidget);
  });

  testWidgets('callsOnLoggedIn_onSuccess', (tester) async {
    Session? received;
    await pumpScreen(
      tester,
      FakeAuthSource(const LoginSucceeded(session)),
      onLoggedIn: (value) => received = value,
    );

    await login(tester, 'ayse@ornek.edu', 'parola1');

    expect(received?.role, UserRole.student);
    expect(received?.fullName, 'Ayşe Yılmaz');
  });

  testWidgets('fields_haveGapBetweenThem', (tester) async {
    await pumpScreen(tester, FakeAuthSource(const LoginFailed()));

    final emailBottom = tester.getBottomLeft(
      find.widgetWithText(TextFormField, 'E-posta'),
    );
    final passwordTop = tester.getTopLeft(
      find.widgetWithText(TextFormField, 'Şifre'),
    );

    expect(passwordTop.dy - emailBottom.dy, greaterThanOrEqualTo(12));
  });
}
