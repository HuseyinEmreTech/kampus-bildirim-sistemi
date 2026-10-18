import 'package:flutter/material.dart';

/// Formun altındaki hata mesajı: tema hata renginde; ekran okuyucu mesaj
/// çıkar çıkmaz okur (live region), kullanıcının ekranı gezmesi gerekmez.
class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
