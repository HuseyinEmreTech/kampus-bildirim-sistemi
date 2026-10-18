import 'package:flutter/material.dart';

import '../../../shared/error_text.dart';
import '../data/auth_source.dart';
import '../data/session.dart';

/// Form alanları arasındaki boşluk.
const _fieldGap = 12.0;

/// E-posta biçimi için basit kontrol: `ad@alan.uzanti`.
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// E-posta ve şifreyle giriş ekranı (USR 07).
///
/// Başarılı girişte oturumu [onLoggedIn] ile verir; role göre hangi ekrana
/// gidileceğine çağıran karar verir.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.source,
    required this.onLoggedIn,
  });

  final AuthSource source;
  final ValueChanged<Session> onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await widget.source.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);
    switch (result) {
      case LoginSucceeded(:final session):
        widget.onLoggedIn(session);
      case LoginRejected():
        setState(() => _errorMessage = 'Geçersiz e-posta veya şifre');
      case LoginFailed():
        setState(() => _errorMessage = 'Sunucu hatası, tekrar deneyin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: _fieldGap),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            if (_errorMessage case final message?) ErrorText(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _login,
              child: Text(_isLoading ? 'Giriş yapılıyor…' : 'Giriş yap'),
            ),
          ],
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  if (_emailPattern.hasMatch(value?.trim() ?? '')) return null;
  return 'Geçerli bir e-posta girin';
}

String? _validatePassword(String? value) {
  if ((value ?? '').length >= passwordMinLength) return null;
  return 'Şifre en az $passwordMinLength karakter olmalı';
}
