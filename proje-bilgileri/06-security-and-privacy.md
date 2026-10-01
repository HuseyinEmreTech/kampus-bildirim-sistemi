---
title: Güvenlik ve Gizlilik
durum: Taslak
son-guncelleme: 2026-09-30
---

# Güvenlik ve Gizlilik

← [İndeks](00-index.md)

## Kapsam

Uygulama kampüs sorunlarını (arıza, temizlik, güvenlik) bildirmek içindir; kişileri bildirme aracı değildir. Kategoriler bunu yansıtır: `Ariza`, `Temizlik`, `Guvenlik`, `Diger`.

## Riskler ve kararlar

| Risk | Karar |
| --- | --- |
| Fotoğrafta kişi görünebilir | Bildirim ekranında "fotoğrafta kişi olmamasına dikkat edin" uyarısı |
| Fotoğraf dosyasında konum (EXIF) olabilir | Yüklemede EXIF temizlenir; konum yalnızca formdan alınır |
| Konum kişisel veridir | Yalnızca bildirim anında ve kampüs içindeyse alınır; sürekli takip yok |
| Yetkisiz erişim | Rol tabanlı yetki; öğrenci yalnızca kendi bildirimlerini, görevli tüm bildirimleri görür; her endpoint'te sunucu tarafında kontrol |
| Sahte veya spam bildirim | İstek hız sınırı (rate limit); açıklama ve fotoğraf zorunlu |
| Zararlı dosya yükleme | Yalnızca jpeg ve png, en fazla 5 MB; dosya adını sunucu üretir; çalıştırılabilir dosya kabul edilmez |
| Gizli bilgi sızması | `.env` ve `.env.*` ignore, `.env.example` takip edilir; şifre ve anahtar koda girmez |
| Parola saklama | Düz metin değil; güvenli hash (bcrypt veya argon2) |
| Aktarım | Canlıda HTTPS |
| SQL Injection | Yalnızca parametreli sorgu |
| Yapay zeka üretimi kod | Çıktı okunur, statik analizle taranır; anlaşılmayan kod projeye alınmaz |
| Saklama süresi | Çözülen bildirimlerin fotoğrafı belirli süre sonra silinir (süre belirlenecek) |

## Kişisel veri

Fotoğraf, konum, ad ve e-posta kişisel veri olabilir. Hangi verinin neden toplandığı, ne kadar saklandığı ve kimin gördüğü README'de yazılır. Bu bir ders projesidir; hukuki görüş yerine geçmez.

## Demo verisi

Sunumda ve testte yalnızca sahte kullanıcı ve sahte fotoğraf kullanılır; gerçek öğrenci verisi konmaz. Örnek veri `data/` altında sahte değerlerle tutulur.

## Doğrulanacak testler

- Yanlış rol, başkasının bildirimi, geçersiz dosya türü ve boyutu
- Rate limit
- EXIF temizleme
