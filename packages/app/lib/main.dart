import 'package:flutter/material.dart';

void main() {
  runApp(const CampusApp());
}

/// Geçici kök uygulama.
///
/// Mobil ekranlar `lib/mobil/` altında geliştiriliyor; bu dosya yalnızca
/// varsayılan Flutter sayaç şablonunu kaldırmak ve analiz/testlerin
/// düzgün çalışmasını sağlamak için var. Gerçek giriş noktası
/// `lib/mobil/main.dart` (mobil) veya `lib/web/main.dart` (web) olacak.
class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Report',
      home: Scaffold(
        appBar: AppBar(title: const Text('Campus Report')),
        body: const Center(child: Text('Uygulama giriş noktası hazırlanıyor')),
      ),
    );
  }
}
