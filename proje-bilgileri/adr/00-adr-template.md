---
title: ADR Şablonu
durum: Şablon
son-guncelleme: 2026-09-30
---

# ADR Şablonu

← [İndeks](../00-index.md)

Ne zaman ADR yazılır: **geri dönülmesi zor kararlarda** (veritabanı, ana çatı, mimari yaklaşım). Kolayca değiştirilebilen kararlar (ör. log kütüphanesi) ADR gerektirmez.

Dosya adı: `NN-kebab-case.md`. Başlık: `ADR-NN: Karar Adı`. Yapay zekanın yazdığı ADR taslaktır; doğrulanmadan kabul edilmez. ADR silinmez: karar değişirse eski kaydın durumu "Yerini ADR-NN aldı" olur.

```markdown
---
title: "ADR-NN: Karar Adı"
durum: Önerildi | Kabul edildi | Yerini ADR-NN aldı
son-guncelleme: YYYY-AA-GG
---

# ADR-NN: Karar Adı

## Durum
## Bağlam
## Seçenekler
## Karar
## Sonuçlar
### Avantajlar
### Değiş tokuşlar
## Açık sorular
## Değişiklik geçmişi
```
