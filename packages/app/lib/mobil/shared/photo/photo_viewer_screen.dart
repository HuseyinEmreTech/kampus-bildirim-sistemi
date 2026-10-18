import 'package:flutter/material.dart';

/// En fazla bu kadar yakınlaştırılır.
const _maxZoom = 4.0;

/// Fotoğrafı tam ekranda gösterir; iki parmakla yakınlaştırılır ve
/// kaydırılır. [url] aynı zamanda Hero etiketidir: küçük fotoğraf bu ekrana
/// büyüyerek geçer.
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key, required this.url, required this.title});

  final String url;

  /// Üstte ve ekran okuyucuda fotoğrafın adı (ör. "Sonuç fotoğrafı").
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: url,
          child: InteractiveViewer(
            maxScale: _maxZoom,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              semanticLabel: title,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
