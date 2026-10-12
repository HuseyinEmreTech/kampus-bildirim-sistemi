# Güvenlik Politikası

Bu depo, **ders kapsamında geliştirilen bir demo sistemdir**; üretim sistemi değildir. Yalnızca `main` dalı desteklenir.

## Güvenlik açığı bildirimi

Bir güvenlik açığı bulduysan **herkese açık issue açma**. Bunun yerine:

1. GitHub'da **özel güvenlik bildirimi** kullan: depoda **Security → Report a vulnerability**, veya
2. E-posta: `huseyinemre.tech@gmail.com`

Bildirimde bulunması faydalı olanlar:

- Etkilenen bölüm (endpoint, dosya, ekran)
- Adım adım yeniden üretme
- Olası etki ve önerilen düzeltme

Bildirimleri gizli tutarız; düzeltme için bir zaman çizelgesi vermeye çalışırız.

## Kapsam ve kurallar

- **Sırlar repoya girmez.** Şifre, token, `.env` ve gerçek kişi verisi commit edilmez; `.env` `.gitignore`'dadır.
- Bir sır sızdığında ilgili token/anahtar **derhal iptal edilir** ve yenisi yalnızca GitHub Secrets'ta tutulur.
- Kod kalitesi ve güvenlik taraması PR'larda **SonarQube Cloud** ile yapılır; sır taraması GitHub'ın yerleşik taramasıyla izlenir.

Daha geniş güvenlik ve gizlilik notları: [proje-bilgileri/06-security-and-privacy.md](proje-bilgileri/06-security-and-privacy.md).
