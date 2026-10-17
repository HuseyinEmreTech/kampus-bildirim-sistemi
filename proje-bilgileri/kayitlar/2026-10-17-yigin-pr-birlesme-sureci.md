---
title: Yığın PR Birleşme Süreci
durum: Güncel
son-guncelleme: 2026-10-17
---

# Yığın PR Birleşme Süreci

← [İndeks](../00-index.md)

## Bu kayıt neden var

17 Ekim 2026'da 17 açık PR tek tek incelenip `main`'e birleştirildi: Ertuğrul'un hafta 5 veri katmanı işleri (#52-#66), Çağdaş'ın JWT servisi (#67) ve günlük rapor (#68). Bu işlerin bir kısmı **yığın** (stacked) PR'lardı; yani her biri bir öncekinin dalına base'liydi. Yığın PR'lar küçük ve okunur PR'lar üretir ama `main` koruması **squash** birleşme zorunlu kıldığı için sessiz tuzaklar doğurur. Bu kayıt, o gün çıkan sorunları, nedenlerini ve izlenen yolu bir sonraki hafta aynı yere düşmemek için yazar. Koruma ayrıntıları: [Kod mimarisi ve korumalar](../11-kod-mimarisi-ve-korumalar.md#3-koruma-katmanları).

## Ortam kısıtları (yolun nedeni)

`main` koruması (GitHub ayarlarından doğrulandı):

- **Yalnızca squash birleşme açık.** `mergeCommitAllowed=false`, `rebaseMergeAllowed=false`, `squashMergeAllowed=true`. Linear history zorunlu.
- **1 onay + CODEOWNER onayı.** Her alanda yedek sahip `@HuseyinEmreTech`.
- **Yeni commit gelince onay düşer** (`dismiss_stale_reviews`).
- **Açık konuşma çözülmeden birleşmez** (`required_conversation_resolution`). Bu yüzden inceleme notları inline yorum yerine **inceleme gövdesine** yazıldı; inline yorum çözülmemiş konuşma açar ve birleşmeyi bloklar.
- **Zorunlu kontrol `SonarCloud Code Analysis`.**
- **Yazar kendi PR'ını onaylayamaz.**
- Birleşince dal silinir (`deleteBranchOnMerge=true`).

Squash ile yığın PR'ın birleşimi: alt PR squash'lanınca üst PR'ın taşıdığı commit'ler `main`'e **farklı SHA** ile girer. Üst dal hâlâ eski commit'leri taşıdığı için PR diff'i alt PR'ın değişikliklerini **tekrar** gösterir; üst halka `main`'e göre güncellenmeden doğru birleşemez.

## Zincir

`#52 (resolve) → #60 (create) → #61 (findById) → #62 (findHistory) → #63 (list)`. Her PR'ın base'i bir önceki PR'ın dalıydı; yalnızca #52 `main`'e base'liydi.

## İzlenen yol (adım adım)

1. **En alttan başla** (#52), sonra üste doğru ilerle.
2. **Çocukları önce `main`'e retarget et.** Base dalı silinince GitHub çocuk PR'ı otomatik kapatır (PR zaman çizelgesinde `base_ref_deleted` → `closed`). Çocuğun base'ini önceden `main` yapınca bu olmaz.
3. **Alt PR'ı squash ile birleştir.**
4. **Üst dalı `main`'in üzerine getir.** Yığın PR'da `git rebase --onto origin/main <eski-base-tip>`. Çakışma çoksa tek adımda `git checkout -B <dal> origin/main && git merge --squash origin/<dal>` daha az konflik üretir.
5. **`--force-with-lease` ile push.** Onay düşer → **yeniden onayla**.
6. **Zorunlu kontrol (`SonarCloud Code Analysis`) yeşil olana dek bekle**, sonra birleştir.
7. Sonraki halka için tekrarla.

## Karşılaşılan sorunlar ve çözümler

### 1. Üst PR, base dalı silinince otomatik kapandı (#60)

- **Ne oldu:** #52 `--delete-branch` ile birleşince base dalı (`...-report-resolve`) silindi. GitHub #60'ı `main`'e retarget etti **ve kapattı**.
- **Neden yeniden açılamadı:** Dal, PR kapalıyken force-push edildiği için GitHub "the branch was force-pushed or recreated" dedi ve `reopen` reddetti.
- **Çözüm:** Dalı PR'ın kayıtlı head'ine geri al, PR'ı yeniden aç, sonra rebase'li hali push et.
- **Yan ders:** Bu sırada yerine açılan yedek PR (#69) **kapalı** bırakıldı; çünkü onu lead'in kendisi açmıştı ve **kendi PR'ını onaylayamadığı** için birleşemezdi.
- **Önlem:** Çocukları alt PR'ı birleştirmeden önce `main`'e retarget et.

### 2. Squash yığınında diff tekrarı

- **Ne oldu:** Üst PR'lar `main`'e göre güncellenmeyince diff'leri alt PR'ın değişikliklerini de gösteriyordu.
- **Çözüm:** Her halkayı squash birleşmeden sonra `main`'in üzerine getir; bir sonrakinin diff'i o halka birleşince yalnızca kendi değişikliğine iner.
- **Not:** Yazar (Ertuğrul) zinciri kendisi de rebase/merge ile güncelliyordu; iki tarafın güncellemesi karışınca dallarda çift commit ve merge commit'leri oluştu. Böyle durumda dalın **net** değişikliği `git diff origin/main...<dal>` (üç nokta) ile okunur; iki noktalı diff yanıltır.

### 3. Çakışmalar: bağımsız iki özellik aynı dosyada

- **#65 ↔ #59/#64:** `database.dart` (hem `isReachable` hem bağlantı zaman aşımları) ve `.env.example` (hem `APP_DB_*` hem timeout'lu `DATABASE_URL`). Çözüm: **iki tarafı da koru.**
- **#53 ↔ #54:** `local_file_storage.dart`. #54 `openRead/delete` ekler, #53 kaydetmeyi yeniden kodlamaya çevirir (`_cleanAndStore`/`_reencode`). Çözüm: **iki yöntem kümesi de kalsın**; test dosyasında hem EXIF hem okuma/silme testleri birlikte.
- **Kural:** Aynı dosyaya dokunan iki **bağımsız** özellik çakıştığında birini diğerine feda etme; ikisini birleştir. Çakışma çözümünü inceleme gövdesine yaz.

### 4. Kendi PR'ını onaylayamama

- **Ne oldu:** Lead, base dalı silinen create PR'ının yerine yeni PR (#69) açtı; GitHub "Can not approve your own pull request" verdi.
- **Çözüm:** Yedek PR'ı kapat, asıl PR'ı (yazarı başkası olan) kurtar.
- **Önlem:** Değiştirme/yedek PR'ları **başka bir üye** açsın; ya da asıl PR kurtarılsın.

## Kontrol listesi (sonraki yığın PR'lar için)

- [ ] Her PR küçük ve tek konu mu (300 satır kuralı)?
- [ ] Yığın PR'da base, hedef (parent) dal mı; birleşme sırası yazılı mı?
- [ ] Alt PR birleşmeden **önce** çocukları `main`'e retarget ettim mi?
- [ ] Alt PR squash'landıktan sonra üst dalı `--onto main` ile güncelledim mi?
- [ ] Force-push sonrası onayı yeniledim mi; zorunlu kontrolü bekledim mi?
- [ ] Çakışmada iki bağımsız özelliği de korudum mu?
- [ ] İnceleme notlarını inline yorum yerine inceleme gövdesine yazdım mı?

## Doğrulanmayanlar

- Squash + yığın PR akışının Podman/GitHub dışı ortamlarda aynı davrandığı denenmedi; buradaki adımlar GitHub üzerinde gözlendi.
- Yazarın eşzamanlı rebase'leri ile buradaki adımların çakışması bir kez yaşandı; tekrarında hangi tarafın önce davranacağına dair yazılı bir kural yok. Öneri: yığın PR'ı yalnızca **bir kişi** güncellesin.
