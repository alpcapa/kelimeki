# Doküman boyutu — bölme günlüğü

> Kök `CLAUDE.md` → "Doküman Boyutu Bütçesi" bölümünden ayrıldı (7 Eylül
> 2026): kural orada kaldı, hangi dosyanın ne zaman/nasıl bölündüğünü
> anlatan tarihli örnekler buraya taşındı. Bu dosyanın kendisi bir
> `reference` — grep'lenir, baştan sona okunmaz.

Her kesme noktası boyut değil **içeriğin türü**: kural ↔ anlatı, tek oturum
↔ iki oturum, normal kullanıcı ↔ admin, her sürümde koşulan liste ↔ tarihli
tur. Hiçbir satır değiştirilmez, bölüm numaraları korunur — atıflar
kırılmasın diye.

**26 Ağustos 2026 — uyarı bandı TAMAMEN boşaltıldı** (kullanıcı: *"md
bölünme işini hallet"*). Beş dosya da kendi kuralına göre bölündü ve
`npm run check-doc-size` artık tek uyarı vermiyor:

| Dosya | Önce → Sonra | Nasıl |
|---|---|---|
| `CLAUDE.md` (auto) | 82 → **59 KB** | `## Supabase`'in tarihli anlatıları → `docs/decisions/supabase-ops.md`; kural/tablo burada kaldı |
| `docs/decisions/components.md` | 183 → **62 KB** | üç cilt: `-account` (59) · `-score` (64) · kendisi (62) |
| `mobile/docs/parca-log.md` | 151 → **12 KB** | Parça 110-138 donduruldu (`parca-log-110-138.md`, FROZEN listesinde) |
| `mobile/TESTING.md` | 141 → **109 KB** | Arkadaşlar + Canlı oyun → `mobile/docs/testing-arkadaslar-canli.md` |
| `TESTING.md` | 124 → **83 KB** | Admin kontrolleri (9.7-9.15) → `docs/testing-admin.md` |

**3 Eylül 2026 — `mobile/TESTING.md` yeniden uyarı bandına girdi** (121 KB)
ve aynı kuralla ikinci kez bölündü: tarihli etkileşim/görünüm turları (bölüm
14-25, sürükleme eşiği · dokunma hedefleri · yazı boyutu · akıcılık · zoom)
→ `mobile/docs/testing-ux-turlari.md`, dosya **93 KB**'a indi. Kesme noktası
yine içeriğin türü: her sürüm baştan koşulan ÖZELLİK listesi ↔ belirli bir
Parça'nın gerilemediğini doğrulayan TARİHLİ tur. Dosyanın bölüm
numaralarının 14'ten yeniden başlaması bu ayrımın zaten var olduğunun
kanıtıydı.

**4 Eylül 2026 — `mobile/CLAUDE.md` uyarı bandındaydı (80 KB), aynı
kuralla bölündü.** Dosyanın en büyük tek bloğu "Klasör Yapısı" ağacıydı:
**24,5 KB, dosyanın %30'u**, ve içeriğinin çoğu dosya başına tarihli
gerekçe/uyarı — yani her turda değil, O DOSYAYA dokunurken gereken bilgi.
Açıklamalı ağaç `mobile/docs/klasor-yapisi.md`'ye taşındı (satırlar
değiştirilmeden), yerine yalnızca KLASÖR düzeyinde bir özet + ağaçtan çıkan
iki kural (üretilmiş dosyalar listesi, elle senkron web↔port çiftleri)
kaldı; dosya **60 KB**'a indi. `auto` sınıfının kesme noktası bir kez daha
"kural ↔ dosya başına ayrıntı" oldu — kök `CLAUDE.md`'nin kendi 26 Ağustos
bölmesindeki ayrımın aynısı.

**7 Eylül 2026 — `TESTING.md` (120 KB) bölündü.** Kesme noktası mobil
tarafın 3 Eylül'deki ayrımının aynısı: her sürümde baştan koşulan ÖZELLİK
listesi (1-13) ↔ belirli bir düzeltmenin gerilemediğini doğrulayan TARİHLİ
turlar (14+). Turlar `docs/testing-turlari.md`'ye taşındı, dosya **88 KB**'a
indi. Aynı turda kök `CLAUDE.md` de 81 KB ile uyarı bandına girmişti; bu
dosya (bölme günlüğü) o yüzden ayrıldı.

## 7 Eylül 2026 (akşam) — `CLAUDE.md` uyarı bandından çıkarıldı

Onboarding Faz 4'ün port notu ("İlk Oyun: Tanıtım Ekranı" bölümü) dosyayı
81 KB'a, yani `auto` sınıfının 80 KB'lık uyarı bandına soktu. Kural "bir
sonraki dokunuşta böl" — aynı dokunuşta iki tarihli vaka anlatısı kendi
konusunun karar dosyasına taşındı, yerlerinde tek satırlık kural + işaretçi
kaldı: Space Mono 700 yanlış teşhis dersi → `components.md`; teslim sonrası
izleme dalının silinmesi → `roadmap-arsiv.md`. Kesme noktası içeriğin
TÜRÜ (vaka anlatısı ↔ her yerde geçerli kural), satırlar değişmedi.

## 7 Eylül 2026 (gece) — `mobile/docs/parca-log.md`: cilt donduruldu (139-174)

Tanıtımın tarayıcı turu (Parça 195) yazılınca aktif cilt 200 KB'a çıkıp
`reference` uyarı bandına girdi. `reference` sınıfının kuralı **bölmek
değil**: (1) bayat anlatıyı buda, (2) hâlâ büyükse bir CİLT dondur. Anlatı
buda­nabilir değildi (her giriş bir ölçümün kaydı), o yüzden ikinci adım:
Parça 139-174 `parca-log-139-174.md`ye dondu, aktif cilt 200 → 79 KB.
Kesim parça sınırından; hiçbir satır değişmedi. `check-doc-size.mjs`in
`FROZEN` listesine tavanıyla (135 KB) eklendi — arşive yanlışlıkla yazmanın
tek yakalayıcısı o. Cilt haritası `mobile/CLAUDE.md`de dört → beş oldu.


## Kuralın kendi tarihçesi — kök `CLAUDE.md`'den taşınan gerekçeler (8 Eylül 2026)

Aşağıdaki üç anlatı 8 Eylül 2026'da kök `CLAUDE.md`'den buraya alındı: dosya
79.939 bayttı (uyarı eşiği 80.000) ve tek satırlık bir kural eklemek onu
banda soktu — yani kuralın kendi tarihçesi, kuralın konusu olan dosyayı
sınıra dayamıştı. Kurallar orada kaldı, gerekçeler burada.

**`reference` sınıfı neden eklendi (29 Ağustos 2026).** Kullanıcı sordu:
*"Büyüyen md dosyalarını bölme işini tüm md'lerde yapıyor muyuz? Gerek var
mı?"* Ölçüldü: repoda 43 `.md`, 2.3 MB. Eski `active` bütçesi ÖDENMEYEN bir
maliyeti vekaleten ölçüyordu — o dosyalar isteğe bağlı ve çoğunlukla grep'le
okunuyor. **Bölmenin ise gerçek bedeli var ve bu repo onu ödedi:**
`docs/decisions/` 22 dosyaya çıktı ve doğru dosyayı bulmak için kök
`CLAUDE.md`'de bir indeks tablosu gerekli hâle geldi (koddaki eski atıflar
bölünmeyle kırıldı). Kural kaldırılmadı, **daraltıldı**: bölme refleksi
artık yalnızca baştan sona okunan dosyalar için.

**Alt sınırın vakası (7 Eylül 2026).** `ROADMAP.md` bir düzenleme betiğinin
`open(p, 'w')` satırıyla sıfırlandı, "bütçe içinde" sayıldı ve BOŞ hâliyle
`main`'e girdi (PR #475; #476 geri aldı). Betiğe alt sınır bu yüzden eklendi.

**25 Ağustos 2026 — `docs/decisions/live-game-and-friends.md`** tam "ilk
dokunuşta böl" kuralı gereği bölündü: 156 KB'lık dosya `friends.md` /
`live-game.md` / `online-game-screen.md` olarak üçe ayrıldı, üçü de 64 KB'ın
altında. Dosya "bir gün" değil, ilk dokunuşta bölündü.

**Kural yazılırken kök `CLAUDE.md`'nin kendisi 111 KB'a çıkmıştı** — kuralı
yazmak, kuralın konusu olan dosyayı büyüttü. Öngörülen çare hemen uygulandı:
en büyük tek konu bloğu (yerel oyun kalıcılığı, 35 KB)
`docs/decisions/local-game-persistence.md`'ye taşındı, dosya 76 KB'a indi.

---

## 11 Eylül 2026 — `CLAUDE.md` (80.049 → 74.7 KB), `auto` uyarı bandı

**Tetikleyen:** admin cihaz tabloları PR'ı (#520) dosyaya iki satır ekledi
(komut listesi + utils ağacı) ve dosya **79.910 → 80.049 bayta** çıkarak
`auto` sınıfının uyarı eşiğini (80.000) 49 baytla aştı. Kuralın kendisi:
*"Uyarı bandındaki dosyayı bir sonraki dokunuşunda böl."*

**Kesme ölçütü BOYUT DEĞİL TÜR.** `auto` sınıfının betikte yazılı öğüdü
zaten bunu söylüyor: *"tarihli 'neden böyle' anlatılarını ilgili
docs/decisions/*.md'ye taşı; burada yalnızca her yerde geçerli kural/
değişmez kalsın."* Ölçüm bunu doğruladı: "Oyun Mekaniği Özeti" tek başına
dosyanın **%31'iydi** (25.163 bayt) ve içindeki en büyük maddeler kuralın
kendisiyle vaka anlatısını bir arada taşıyordu.

**Taşınanlar (anlatı) ↔ kalanlar (kural):**

| Anlatı | Nereye | Kökte kalan |
|---|---|---|
| "İletken hücre" vakası: kullanıcının yakaladığı tutarsızlık, "üye olmaz" kararının gerekçesi, iki geçişli uygulama, `territory.json`ın duyarlılık kanıtı | `game-rules.md` (YENİ) | kuralın kendisi + istisnanın sınırı |
| Zor motorunun ölçümü (%70/%72), elenen dokuz sezgisel, düşünme süresi, Faz 3/4 ürün yüzeyi, seçici altı açıklama gerekçesi | `ai-levels.md` | sözleşmeler: Normal yazılmaz, üç kopya, parite kapıları, `leaguePoints` aritesi, terminoloji |
| Vergi terminolojisi tarihçesi (uydurulan üçüncü terim, üç ölü varyantın temizliği) | `game-rules.md` | iki terimin AYRIMI + "üçüncüsünü üretme" kuralı |
| Logo'nun "Çık" modalının kaldırılması, hotseat dalının neden hiç tetiklenmediği | `game-rules.md` | logo artık teslim etmez + tek tetikleyici 7 günlük kural |
| Vercel'in atladığı commit: #447 vakası, kurtarma ölçümü, ajanın gözlem sınırı | `supabase-ops.md` | "merge ≠ canlıda, tek kanıt sha" + kurtarma adımı ve bedeli |

**Sonuç:** 80.049 → **74.659 bayt** (−%6,7), uyarı bandının ~5 KB altında.

⚠ **Bu bölmede "hiçbir satır değişmez" kuralı UYGULANAMAZ ve bu bilinçli.**
O kural bölüm SINIRINDAN kesilen dosyalar için (`TESTING.md` →
`testing-admin.md` gibi); burada kesme bir maddenin İÇİNDEN geçiyor, yani
kalan kural cümlesi yeniden yazılmak zorunda. Taşınan anlatı birebir
korundu, kalan kural kısaltıldı ve her birine karar kaydına atıf konuldu.

⚠ **Denenmedi ve bilerek denenmedi:** "Komutlar" (7,5 KB) ve "Çalışma
İlkesi" (7,6 KB) bölümleri büyük ama TAMAMI kural/indeks — taşınacak anlatı
yok, bölmek yalnızca atıfları kırardı.

