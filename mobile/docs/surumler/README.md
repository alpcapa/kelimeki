# Sürüm kütüğü — CSV (Android + iOS)

Bu klasör `mobile/docs/surumler.md`'nin **tablo hâli**: aynı gerçekler,
grep'lenebilir/açılabilir biçimde ve **iki mağaza için ayrı ayrı**.
Anlatı (neden böyle oldu, tuzaklar, post-mortem'ler) `surumler.md`'de kalır;
burada yalnızca satırlar var.

⚠ **Kanonik kayıt hâlâ `mobile/docs/surumler.md`.** Bir çelişki görürsen
o dosya doğrudur; CSV'yi ona uydur. (Kullanıcı isteği, 11 Eylül 2026:
*"Bu formatı hem android, hem de iOS için yap ve güncel tut. excel şart
değil, cvs de olabilir"* — Excel istendiğinde bu CSV'lerden üretilir.)

| Dosya | Ne tutar |
|---|---|
| `surumler-android.csv` | Play'e yüklenen HER paket (sürüm · versionCode · sha · gönderim · inceleme süresi · durum) |
| `gonderimler-android.csv` | Play Console → Publishing overview → **Submission activity** kaydı |
| `surumler-ios.csv` | TestFlight'a çıkan HER build (sürüm · build · sha · koşu · dağıtım · cihaz doğrulaması) |
| `gonderimler-ios.csv` | Apple'a yapılan yükleme/gönderim olayları — **reddedilenler dahil** |
| `degisiklikler.csv` | Commit dökümü; her satır hangi Android paketine ve hangi iOS build'ine girdi |

## İki mağazanın sayaçları AYRI — karıştırma

- **Android:** `versionCode` = GitHub Actions **koşu numarası**
  (`mobile-build.yml` → `--build-number=github.run_number`). Play'e yükleme
  ELLE yapılır, yani her koşu bir paket değildir.
- **iOS:** `CFBundleVersion` da aynı koşu numarası, ama **`mobile-build.yml`
  `main`'e HER push'ta TestFlight'a yüklüyor** — yani TestFlight'ta Play'de
  hiç görünmemiş build'ler durur (616, 618). "Build" ile "sürüm" aynı şey
  değil.
- **Aynı sürüm ADI iki mağazada farklı İÇERİK taşıyabilir.** Örnek: Android
  `1.0.9 (581)` = `1abde38`; iOS `1.0.9 (620)` = `46664f6` — arada altı
  commit var. `degisiklikler.csv`'nin iki ayrı paket sütunu tam bu yüzden
  var.

## Sütun sözlüğü

**Güven düzeyi** (`surumler.md` ile aynı sözcükler):
`ölçüldü` = doğrudan bir kaynaktan okundu (git, Actions, Console/ASC,
kullanıcının ekran görüntüsü) · `ÇIKARIM` = tarih/pencere yakınlığından
türetildi · `ölçülmedi` = bakılabilir ama bakılmadı.

- **İnceleme (dk)** — Play'de (gönderim → Published). `≤ N` yazıyorsa yayın
  ANI Console'dan okunmadı, yalnızca "şu saatten önce Published görüldü"
  ölçüldü: değer bir **üst sınır**, ölçüm değil.
- **Android paketi / iOS paketi** (`degisiklikler.csv`) — commit'in İLK
  girdiği paket. `girmedi` = o mağazanın paketine giren bir dosyaya hiç
  dokunmadı (yalnız `ios/`, yalnız CI/fastlane, yalnız `test/`…).
  ⚠ `1 (#614)` iOS'un İLK paketi: 9 Eylül'den önce merge edilmiş her şey
  oradan çıktı.
- **Kapsam** — `web + port` = commit `src/` altında da dosya değiştirdi.

## Bir paket mağazaya gittiğinde ne güncellenir

`surumler.md`'nin "Bir sürüm yüklendiğinde ne yapılır" listesi geçerli,
**üstüne şu iki satır**:

1. **Play'e yükleme →** `surumler-android.csv` + `gonderimler-android.csv`
   (yeni satır · bir öncekini "pasif"e çek · gönderim saati · inceleme süresi).
2. **TestFlight'a yükleme →** `surumler-ios.csv` + `gonderimler-ios.csv`.
   Bu, `main`'e her push'ta OLUYOR; kayda giren satır **gruba dağıtılan**
   build'dir, ama aradaki build'ler de bir satır hak eder (yoksa "616 mı
   620 mi" sorusu her turda yeniden sorulur).
3. **Her iki durumda →** `degisiklikler.csv`'ye o pencerenin commit'leri.

Commit dökümünü ELLE yazma, süzgeci koş:

```bash
# pencere = önceki paketin sha'sı → bu paketin sha'sı
git log --first-parent <önceki>..<bu> --date=format:'%d.%m.%Y' \
  --format='%h|%ad|%s' -- mobile/app mobile/kelimeki_core

# paket üyeliği commit BAŞINA ölçülür (--stat grep'leme, YANILTIR):
git show --name-only --format='' <sha>
#   Android paketi: mobile/app/lib · mobile/app/android · mobile/app/assets ·
#                   mobile/app/pubspec.yaml · mobile/kelimeki_core/lib
#   iOS paketi    : aynılar, `android` yerine `ios`
```

Koşu numarası ↔ sha eşlemesi (bir build'in hangi commit'ten çıktığı)
Actions'tan okunur: `mobile-build.yml` koşuları, `run_number` + `head_sha`.

## Excel isteyen olursa

CSV'ler kaynaktır; Excel bunlardan üretilir (üç sayfa: Sürümler ·
Gönderimler · Değişiklikler). Depoda `.xlsx` TUTULMUYOR — ikili dosya
diff'lenemez ve iki kaynak arasında sessizce ayrışır.
