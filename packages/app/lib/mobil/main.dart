import 'package:flutter/material.dart';

import 'app/mobil_app.dart';
import 'demo/demo_backend.dart';
import 'demo/memory_session_store.dart';
import 'features/auth/state/auth_controller.dart';

/// Mobil uygulamanın giriş noktası: `flutter run -t lib/mobil/main.dart`.
///
/// Sunucu hazır olana kadar demo verisiyle çalışır; giriş için e-posta
/// "gorevli" ile başlıyorsa görevli, değilse öğrenci (şifre en az 6 karakter).
void main() {
  runApp(
    MobilApp(
      auth: AuthController(MemorySessionStore()),
      sources: MobilSources.demo(DemoBackend()),
    ),
  );
}
