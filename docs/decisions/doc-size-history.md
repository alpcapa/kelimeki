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

