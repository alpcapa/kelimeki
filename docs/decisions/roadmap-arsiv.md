# ROADMAP Arşivi — kapanmış maddeler ve sürüm turları

> **Bu dosya `ROADMAP.md`'nin geçmişi.** Orası yalnızca AÇIK maddeleri tutar;
> bir madde kapandığında (✅ / YAPILDI / KAPANDI / CANLIDA / SAHADA) **aynı
> PR'da** buraya taşınır. Kural kök `CLAUDE.md` → "İŞ BİTTİĞİNDE" tablosunda.
>
> **Sınıfı `reference`:** baştan sona okunmaz, GREP'lenir. Bir bölümü ararken
> başlığıyla ara — başlıklar taşınırken hiç değiştirilmedi, madde numaraları
> korundu, tek bir satır bile yeniden yazılmadı. Böylece koddaki ve öteki
> dokümanlardaki "ROADMAP → Faz 6", "madde 10" gibi atıflar bu dosyada
> karşılığını bulur.
>
> **İlk taşıma: 2 Eylül 2026.** Kullanıcı isteği: *"Kapanmışları arşive taşı,
> bundan sonra da kapanmışları düzenli kontrol edip taşı. ROADMAP'te sadece
> açık maddeler kalsın."* O gün ölçüldü: `ROADMAP.md`'nin **%45'i** kapanmış
> işti (109.329 → 58.054 karakter). Dosya 118 KB'a "eşik düşük olduğu için"
> değil, kendi 8. satırındaki kuralı (*"bir madde bitince buradan SİLİNİR"*)
> uygulamadığı için gelmişti.
>
> **İkinci taşıma: 15 Eylül 2026.** `ROADMAP.md` yeniden `active` uyarı
> bandına girmişti (122 KB / 120 KB). Taşınanlar: **madde 24 (FAZ C — App
> Store yayını)**, uygulama 15 Eylül 06:02'de yayına alındığı için; ve
> **güvenlik geçişinin #19-#20**'si, ikisi de "ölçüldü, kabul edildi" diye
> kapandığı için. Sonuç: ROADMAP 122 → **94 KB**, bu dosya 210 → **241 KB**.
> ⚠ Bu dosya artık kendi uyarı bandında (200 KB / 300 KB): bir sonraki
> dokunuşta ya bayat anlatı budanmalı ya da bir CİLT dondurulmalı (aday
> kesme noktası: sürüm turları ↔ kapanmış maddeler).
>
> **Üçüncü taşıma: 20 Eylül 2026.** Taşınanlar: **madde 31 (davet linki
> `use_count`'u)**, sunucu 18 · istemci 19 Eylül'de kapandığı için; ve
> **madde 24'ün ROADMAP'te kalan kapanış özeti** — gövdesi 15 Eylül'de
> buraya gelmişti ama başlık hâlâ *"YÜRÜYOR"* diyordu, yani arşivin kendisi
> bayattı. ⚠ Ders: bir maddeyi taşırken ARŞİVDEKİ başlığın durumunu da
> güncelle; yoksa iki yerde iki farklı gerçek kalır (aynı hata Play özet
> tablosunda yaşanmıştı). Sınıf bandı bu arada 200/300'den **260/400
> KB**'a çıktı (bkz. kök `CLAUDE.md` → "Doküman Boyutu Bütçesi"), yani
> yukarıdaki ⚠ artık geçerli değil. Bu taşımadan sonra: ROADMAP 113 →
> **104 KB**, bu dosya 244 → **254 KB** — uyarıya (260 KB) **6 KB** kaldı,
> yani BİR SONRAKİ taşımada önce bayat anlatı budanmalı ya da bir cilt
> dondurulmalı (aday kesme noktası değişmedi: sürüm turları ↔ kapanmış
> maddeler).
>
> **Dördüncü taşıma: 24 Eylül 2026.** `ROADMAP.md` yine uyarı bandındaydı
> (120,5 KB). Taşınan: **"Sayaç — nerede okunur, 14. gün ne zaman"** (Faz B'nin
> 14 günlük sayacı, 10 Eylül'de kapandı). Bilerek KÜÇÜK tutuldu: bu dosyanın
> uyarıya ~5 KB payı vardı. ⚠ Artık pay ~2 KB — bir sonraki taşımadan ÖNCE
> bayat anlatı budanmalı ya da bir cilt dondurulmalı (aday kesme noktası
> değişmedi: sürüm turları ↔ kapanmış maddeler).
>
> **Cilt 1 donduruldu: 25 Eylül 2026.** Bu dosya 258 KB'tı (uyarıya ~2 KB).
> Aşağıdaki **İçindekiler tablosunun ALTINDA kalan her şey** — 2 Eylül'deki
> ilk taşımanın gövdesi, 1.0.3-1.1.0 sürüm turları, madde 23'ün fazları,
> incelemenin geçişleri — satırı değişmeden
> **`docs/decisions/roadmap-arsiv-cilt-1.md`**'ye taşındı ve dondu
> (`check-doc-size` → `FROZEN`). Bu dosya 258 → **~56 KB**. İçindekiler
> tablosu burada kaldı: tablodaki bir satırın gövdesi bu dosyada yoksa
> cilt 1'dedir. ⚠ **Yeni kapanan maddeler YALNIZCA bu dosyaya** — cilt 1
> büyürse CI düşer. Bir atıfı ararken: `grep -n "X" docs/decisions/roadmap-arsiv*.md`.

### Sayaç — nerede okunur, 14. gün ne zaman

✅ **KAPANDI 10 Eylül 2026** — sayaç doldu, başvuru gönderildi (15:26).
Aşağısı bir sonraki uygulama/hesap için işletim bilgisi olarak duruyor.
⚠ Tahmin TUTTU: bu bölüm *"14. gün ~10 Eylül"* diyordu ve kart tam o gün
açıldı.

⚠ Bu bir MADDE değil, açık pencerenin işletim bilgisi. *"Davetlilere
hatırlatma"* maddesi 2 Eylül 2026'da KAPANDI (kullanıcı: *"Hep ben
hatırlatıyorum zaten, burada madde olarak durmasına gerek yok"*) — arşivde:
`docs/decisions/roadmap-arsiv.md` → *"3. Davetlilere hatırlatma"*. Aşağısı
o maddeyle birlikte kaybolmasın diye burada kaldı.

**Sayacın yeri:** Dashboard → (aşağı kaydır) Production → `Apply for access
to production` kartı. Test menüsünde DEĞİL; track sayfasında da yok
(ölçüldü). **14. gün ~10 Eylül 2026** (sayaç 27/28 Ağustos'ta başladı;
Console'un günü nasıl saydığı ölçülmedi, ±1 gün kabul et ve tarihi kartın
kendi metninden takip et).

**Katılan/indiren sayısı:** Test → Closed testing → (track) → **Testers**
sekmesi — ⚠ oradaki sayı opt-in DEĞİL, **izin listesi**; indirme adedi için
**Statistics**.

**14 gün dolmadan yapılabilecek iki iş** (ikisi de hâlâ açık): karttaki
**`Preview questions`**'dan başvuru sorularını okuyup cevapları hazırlamak,
ve tester'lardan **yazılı geri bildirim** toplamak (başvuru "testi nasıl
yürüttün" diye soruyor).

#### ✅ "12" TAVAN — kapandı (6 Eylül 2026, kullanıcı tespiti)

Kullanıcı, Console'a bakarak kapattı: *"12 kişi Tavan, google daha fazla
olsa bile gerçek sayıyı göstermiyor."* Yani kart `min(gerçek, 12)`
gösteriyor; 2 Eylül'deki sezgisi (*"12'den fazla katılım olduğunu
düşünüyorum"*) doğruymuş.

Eski kayıt iki tezi yan yana tutuyordu ve ayırt edici gözlem olarak
*"sayının 12'nin ÜSTÜNE çıktığının bir kez görülmesi"*ni işaret ediyordu.
**O gözlem hiçbir zaman gerçekleşemezdi** — tavan tam da onu engelliyor.
Ayırt etme yöntemi olarak yanlış seçilmişti; doğru kaynak baştan beri
Console'un kendisiydi ve ona yalnızca kullanıcı bakabiliyor (bu oturumların
Play Console erişimi YOK).

**Pratik sonucu — kartın sayısı bir kapasite ölçüsü DEĞİL:**

| Soru | Kart cevaplıyor mu |
|---|---|
| Şart sağlanıyor mu (≥12)? | ✅ evet, 12 yazıyorsa sağlanıyor |
| Kaç kişi var, payımız ne kadar? | ❌ hayır, 12'de sabitleniyor |
| Biri düşerse eşiğin altına iner miyiz? | ❌ karttan ANLAŞILMAZ |

Son satır önemli: *"biri düşerse sayaç sıfırlanır"* endişesi kartla
yanıtlanamaz, çünkü kart payı gizliyor. Gerçek katılım için **Test →
Closed testing → (track) → Testers** (izin listesi) ve **Statistics**
(indirme) sekmelerine bakılmalı — ikisi de yukarıda tarif edildi.

Kaynak kayıt: `marketing/play-store/console-formlari.md` §7.


## 31. Davet linki `use_count`'u gerçeğin ~12 katı — ✅ **YAPILDI** (sunucu 18 Eylül · istemci 19 Eylül 2026)

Kullanıcı yeni bir üyenin (Serbay → nadidesultan) linkten gelip gelmediğini
sordu. Arkadaşlık doğruydu (`friend_requests` = `accepted`, `invited_by`
dolu), ama satırın iki zaman damgası uyuşmuyordu: `created_at` 15:17:51,
`responded_at` 15:17:56. `accept_friend_invite` tek çağrıda ikisini de
`now()` yazar — beş saniyelik fark, fonksiyonun **iki kez** çağrıldığını
söylüyor (ilki `insert`, ikincisi `exists` dalına düşüp `responded_at`'i
tazeledi). Her çağrı `use_count`'u bir artırdığı için sayaç tek davetliye
**2** yazdı.

**Canlıdan ölçüldü — sapma tek vakaya özgü DEĞİL, beş linkin beşinde de var:**

| Link sahibi | `use_count` | `invited_by` ile atfedilen kişi | Link tarihi |
|---|---|---|---|
| Asnmzr | **84** | 2 | 3 Eyl 2026 |
| Zesiner | **32** | 4 | 27 Tem 2026 |
| Ironman | 9 | 4 | 26 Tem 2026 |
| Serbay | 2 | 1 | 18 Eyl 2026 |
| Minka | 1 | 0 | 28 Tem 2026 |
| **Toplam** | **128** | **11** | — |

Yani sayaç bugünkü hâliyle "bu linkle kaç kişi geldi" DEĞİL, **"oturumu açık
biri bu linke kaç kez tıkladı"** ölçüyor: zaten arkadaş olmuş biri linki her
açtığında `exists` dalı çalışıyor ve sayaç bir daha artıyor. 84/2 oranı bunu
tek başına gösteriyor.

⚠ **Bugün hiçbir şeyi bozmuyor** — `use_count` repoda hiçbir yerde OKUNMUYOR
(`grep use_count` → yalnızca migration'daki yazma + iki yorum satırı).
Arkadaşlığın kendisi doğru kuruluyor, fonksiyon idempotent. Bu madde bir
hata raporu değil, **metrik kurulmadan önce ödenecek bir borç**: admin
Büyüme panelinde "arkadaş daveti ile gelen kayıt" kartı `use_count`'a
bakarak yazılırsa rakam ilk günden ~12 kat şişik doğar.

✅ **SUNUCU YARISI AYNI GÜN KAPANDI — migration `20260918154109` + `20260918155030`, ikisi de canlıda.**
`accept_friend_invite` idempotent: taraflar zaten `accepted` ise çağrı **tam
no-op** (sayaç artmaz, `responded_at` tazelenmez, `invited_by`'a dokunulmaz).
Ayrıca yarış sertleştirmesi var (var olan satır `for update` ile kilitleniyor,
ekleme `on conflict do nothing` + `found` kontrolüyle yapılıyor), yani iki
EŞZAMANLI çağrıdan da yalnızca biri sayar. Dönen `inviter_name` ve üç `P0001`
reddi AYNEN korundu — iki istemci de yalnızca bu ikisine baktığından davranış
değişmedi.

⚠ **İKİNCİ TUR GEREKTİ — ilk migration bir BELİRSİZLİK soktu.** İlk sürüm
tek satır okuyordu (`select fr.status into v_status`), oysa `friend_requests`'te
aynı ikili için İKİ YÖNLÜ satır olabiliyor (`sendFriendRequest` düz `insert`,
PK `(user_id, friend_id)` ters yönü engellemez) ve canlıda bir örneği var.
Karışık durumda (biri `accepted`, biri `pending`) hangi satırın okunacağı
belirsizdi; eski kod bu yönden deterministikti. `20260918155030` kararı
`bool_or(status = 'accepted')`e bağladı — satırların tamamı kilitlenir, soru
tek ve kesin cevaplanır; kalıntı `pending` satırı da eski davranıştaki gibi
normalize edilir (sayaç yine artmadan). **Canlıdaki tek çift yönlü ikili
`accepted`/`accepted` olduğu için hiçbir kullanıcı etkilenmedi.**

**Canlıda ölçülen YEDİ yol** (hepsi ikinci migration'dan SONRA, gerçek veriyle;
yazanlar geri sarılan alt-işlemlerde):

| Yol | Sonuç |
|---|---|
| A) `pending` ileri yön (davet eden → çağıran) | kabul + sayaç **+1** |
| B) `pending` ters yön (çağıran → davet eden) | kabul + sayaç **+1** |
| C) karışık çift yön (`accepted` + `pending`) | sayaç **SABİT**, kalıntı normalize, `accepted` satırın damgası korundu |
| D) zaten arkadaş — **gerçek çağrı, geri sarmasız** | `use_count` **2 → 2**, damga sabit, dönen ad `Serbay` (öncesinde 3 olurdu) |
| E) mutlu yol (hiç satır yok) | sayaç **+1**, satır `accepted` |
| F) üst üste **İKİ** çağrı (asıl vaka) | ikisi de no-op, sayaç sabit |
| G) üç ret (oturum yok · kendi linki · geçersiz token) | üçü de `P0001`, **metinler birebir** |

Ayrıca `insert … on conflict do nothing` sonrası `found` semantiği geçici
tabloyla ölçüldü (ekleme `true`, çakışma `false`) — yanlış olsaydı gerçek
kabuller SESSİZCE sayılmaz olurdu.

Test sonrası çevre sağlaması: 49 ilişki · `use_count` toplam 128 · atfedilen 11
· çift yönlü ikili 1 (dokunulmadı) · yetkiler değişmedi (`anon` yok) · kaçak
JWT ayarı yok.

⚠ **Geçmiş değerler DÜZELTİLMEDİ** ve düzeltilemez (tıklama başına iz yok):
canlıdaki 128 olduğu gibi duruyor, kolon yorumu kesim tarihini yazıyor.
Büyüme kartı yazılırsa sayı `profiles.invited_by`'dan okunmalı.

✅ **İSTEMCİ YARISI DA KAPANDI (19 Eylül 2026).** Çift çağrının penceresi
SIRA hatasıydı: `/davet/:token` sayfası kuyruğu `.then()` içinde
temizliyordu, yani token RPC uçarken kuyrukta DURUYORDU. O pencerede
uygulamanın köküne düşen biri (doğrulama linki, yeni sekme, sayfayı kapatıp
dönme) `App.tsx`'in fallback'ini tetikliyor ve aynı token ikinci kez
gidiyordu. Temizlik çağrının ÖNÜNE alındı.

⚠ **Çift yol KALDIRILMADI** (ROADMAP'in kendi uyarısı) — varlık sebebi
gerçek. Ve erken temizlik kurtarma yolunu kesmesin diye: **geçici** arızada
token kuyruğa GERİ konuyor (`storePendingInviteToken` catch içinde), kalıcı
rette (P0001) konmuyor — ikinci deneme aynı reddi alır ve kuyruk sonsuza dek
dolu kalırdı. Sayfadaki "Tekrar Dene" zaten bellekteki `token` ile çalışıyor,
ondan etkilenmiyor.

**Kapı: `npm run verify-invite-queue`** (CI'da) — sıra kuralını, kurtarma
yolunu ve çift yolun DURDUĞUNU kaynaktan sınar. Duyarlılığı düzeltme geri
alınarak kanıtlandı (düzeltmesiz DÜŞÜYOR).

⚠ Port ETKİLENMEDİ: portta `/davet` sayfası yok, token `friend_invite_inbox.dart`
üzerinden tek yoldan giriyor.

**İki ayrı iş, karıştırma:**

1. ~~**Sayacın anlamı**~~ → ✅ **YAPILDI** (yukarı). Seçilen yol: sayaç
   "bu linkle KURULAN arkadaşlık" anlamına sabitlendi; ikinci ve sonraki
   çağrılar sayılmıyor. Eski metin referans için bırakıldı:
   **Sayacın anlamı** (asıl iş). Ya `use_count` artışı yalnızca `invited_by`
   o çağrıda İLK KEZ dolduğunda yapılsın (sayaç "benzersiz davetli"ye
   dönüşür — metriğin istediği sayı budur), ya da sayaç olduğu gibi bırakılıp
   metrik doğrudan `profiles.invited_by`'dan okunsun ve `use_count` "tıklama"
   olarak yeniden adlandırılsın. ⚠ Geriye dönük düzeltme: mevcut 128 sayısı
   kurtarılamaz, çünkü tıklama başına iz tutulmuyor — `invited_by` sayımı (11)
   tek güvenilir taban.
2. **Çift çağrının kendisi.** `/davet/:token` sayfasının kendi otomatik kabulü
   ile `App.tsx`'teki `localStorage` kuyruğu fallback'i (ikisi de
   `docs/decisions/friends.md`'de tarifli, e-posta doğrulaması yüzünden
   oturumun geç açılma riskine karşı BİLEREK çift yol) aynı token'ı arka
   arkaya işliyor olabilir. Kuyruk `read-then-clear` desenli, yani çağrı ile
   temizleme arasındaki pencere dar ama sıfır değil. ⚠ Çift yolu KALDIRMA —
   varlık sebebi gerçek; yapılacaksa token çağrıdan ÖNCE temizlenmeli.

⚠ **Yan etki, atlanmasın:** ikinci çağrı `responded_at`'i de tazeliyor ve
`fetchFriends` (`list_friends`) listeyi `responded_at desc` ile döndürüyor —
yani linke tekrar tıklayan eski bir arkadaş, listede yeniden "en yeni"ye
çıkıyor. İstemci zaten `trCompare` ile yeniden sıralıyor (bkz. kök
`CLAUDE.md`, "Türkçe Dil Notu"), o yüzden kullanıcıya YANSIMIYOR — ama
sunucunun sırasına güvenen yeni bir yüzey yazılırsa yansır.

⚠ **Kapsam: yalnızca SUNUCU** (`accept_friend_invite`). Düzeltme bir
migration ise `mobile/` DEĞİŞMEZ, yani mobil derleme tetiklenmez ve sürüm
dondurmasını beklemek gerekmez. İkinci iş (çift çağrı) web istemcisinde;
portta `/davet` sayfası yok, token `friend_invite_inbox.dart` üzerinden tek
yoldan giriyor — port ETKİLENMİYOR, ama düzeltilirse orada da ölçülmeli.

---

## 24. FAZ C — App Store yayını — ✅ **KAPANDI: UYGULAMA YAYINDA** (15 Eylül 2026)

✅ **Altı fazın altısı da kapandı ve `1.1.0 (665)` 15 Eylül 2026 06:02'de App
Store'da yayına alındı** (vitrin ~06:39'da kullanıcı tarafından görüldü ve
indirildi). Başlık AYNEN korundu, yani koddaki ve dokümanlardaki
`ROADMAP.md → #24 FAZ C` atıfları (ör. `mobile/app/lib/src/data/push_init.dart`,
`mobile/docs/test-ortamlari.md`) karşılığını BURADA bulur; `ROADMAP.md`'de
yalnızca "tek bakışta" tablosunun indeks satırı kaldı.

**Cevap kâğıdı taşınmadı, yerinde:** `marketing/app-store/console-formlari.md`
(§ durum tablosu) — Console'da neyin yapıldığını yazan tek kaynak orası.

⚠ **Kapanan şey FAZ C, App Store işi DEĞİL.** Yayındaki sürümün bakımı,
sonraki gönderimler ve inceleme yazışmaları `console-formlari.md`'den
yürür; §26'nın Apple yarısı da bu yayınla açıldı ve YAPILDI (§26 ROADMAP'te
AÇIK kaldı: Android yarısı bekliyor).

**Bu bölüm bir İNDEKS. Kaynak: `marketing/app-store/console-formlari.md`** —
Console cevapları, kararlar, ölçümler ve tuzaklar orada; burada yalnızca
hangi fazın nerede olduğu duruyor. (Play tarafında bunun tersi bir kez
yaşandı ve özet tablo altı gün bayat kaldı.)

| Faz | Durum |
|---|---|
| **24.1** Hesap & kimlik | ✅ üyelik aktif · Team ID `8277D85FY9` · App ID + capability'ler · APNs anahtarı `RL4JLXL389` · uygulama kaydı · Free Apps Agreement · **DSA trader: beyan ✅, doğrulama `In Review`** (9 Eyl) · ✅ **API anahtarı `.p8` ALINDI** (9 Eyl akşamı, bir Mac'ten — §3) |
| **24.2** Mac'siz imzalama + TestFlight | ✅ **UÇTAN UCA DOĞRULANDI** (9 Eyl, koşu #614): zincir baştan sona koştu ve paket App Store Connect → TestFlight'ta **"Ready to Submit"** olarak GÖRÜLDÜ. Altı koşu, sekiz ayrı arıza; teşhis zinciri `console-formlari.md` §3'te. ⚠ Dokuzuncu arıza yeşil koşudan SONRA bulundu: paket **1.0.9 (1)** olarak yüklendi, 614 olarak değil — araya giren bayraksız `flutter build ios` `Generated.xcconfig`i eziyordu. Düzeltildi (bayrak + fastlane öncesi doğrulama) ve **koşu #616 ile kanıtlandı: TestFlight'ta `1.0.9 (616)` · Complete**; post-mortem `console-formlari.md` §3 |
| **24.3** APNs / push | ✅ Firebase (prod+dev) · `GoogleService-Info.plist` · `Runner.entitlements` · `AppDelegate` bildirim kanalı. ⚠ `aps-environment` değeri CI'da doğrulanamaz — **kapı: TestFlight iç test grubu** (aşağı, madde 0) |
| **24.4** Universal Links | ✅ web yarısı **CANLIDA ölçüldü** (`200` + `application/json`) · ✅ iOS yarısı yazıldı · ⚠ doğrulama TestFlight ister — **kapı: iç test grubu** (aşağı, madde 0) |
| **24.5** Mağaza vitrini | ✅ cevap kâğıdı · metinler (ölçülü) · App Privacy eşlemesi · yaş derecesi · demo hesap `T2` · ✅ **ekran görüntüsü boru hattı ÇALIŞIYOR** — 9 Eyl, run #1 ile CI'da DOĞRULANDI: iPhone 6.9" karesi **tam 1320×2868**, artefakt 1,6 MB. iPad yarısı da run #2'de DOĞRULANDI (`2064×2752`) · ✅ **6/6 kare, iki cihazda da CI'da DOĞRULANDI** (9 Eyl, run #4: on iki PNG'nin on ikisi tam ölçüde) · ✅ **KOMPOZİSYON KARARI VERİLDİ** (11 Eyl, kullanıcı): kareler **başlıklı** + **7. kare** (k-lig) eklendi — şerit `MaterialApp.builder` ile Flutter ağacının içinde, son işlem YOK, piksel ölçüsü değişmiyor; eksik kare artık koşuyu düşürüyor (`KARE_SAYISI`). ⚠ **Aynı turda bir yükleme blokeri bulundu ve kapatıldı:** kareler ALFA kanalı taşıyordu (ölçüldü: 7/7 `hasAlpha: yes`) ve ASC saydamlık kabul etmiyor — arıza ancak Console'da görünecekti; düzeltme `test_driver/png_flatten.dart`, kapı hem Linux birim testi hem iş akışı. ⚠ **İKİNCİ yükleme blokeri, kullanıcı yakaladı (11 Eyl):** karelerin sağ üst köşesinde Flutter'ın kırmızı **DEBUG bandı** vardı — `flutter drive` debug modda derliyor ve bayrak hiç kapatılmamıştı; bugüne kadarki BÜTÜN setler bu yüzden çöp. Düzeltildi (`debugShowCheckedModeBanner: false` × 6) ve kapı kondu (`_kareCek` her karede bandın yokluğunu iddia ediyor, duyarlılığı ölçüldü). ⚠ **Ders:** sayım/piksel/alfa kapılarının üçü de dosyanın ŞEKLİNE bakıyor, İÇERİĞİNE değil — ajan artefaktı indiremediğinden **kareye bakan bir insan olmadan set onaylanamaz.** ⚠ Kalan: yeni koşunun artefaktını indirip **bir kareyi GÖZLE kontrol etmek**, sonra Console'a yüklemek |
| **24.6** Gönderim | ⬜ DSA doğrulaması ✅ (10 Eyl) · paket ✅ (24.2) · kareler ✅ (24.5, 11 Eyl) · **sürüm kaydı `1.1.0` + derleme iliştirme ✅** (11 Eyl, kullanıcı — teşhis ve ders `console-formlari.md` §15: belirti "ikon çıkmıyor"du, sebep sürüm dizesi uyuşmazlığıydı). ⚠ **Kalan TEK adım:** koşu `7d6361e`nin artefaktlarını indirip kareleri 6.9" + iPad 13" slotlarına yüklemek — sonra gönderimin önünde kapı yok |

⏳ **TRADER: beyan ✅, doğrulama SÜRÜYOR (9 Eylül 2026).** Console'un
Compliance tablosu `Digital Services Act · 27 ülke · In Review` diyor —
yani gönderim kapısı HÂLÂ AÇIK. ⚠ Bu satır bir kez *"kapandı"* diye
yazıldı ve aynı gün düzeltildi: sözlü bildirim değil, **Console'un kendi
STATUS alanı** kanıttır (gerekçe `console-formlari.md` §2).

**Sırayı tıkayan şeyler (10 Eylül 2026 GECE tazelendi — ÜÇ maddenin ÜÇÜ de
düştü; bu listede artık tıkayan bir şey YOK):**
0. ✅ **TestFlight iç test grubu KURULDU ve uygulama iPad'de ÇALIŞTI**
   (10 Eylül 2026 akşamı). `İç Test` grubu · 2 testçi · dağıtılan derleme
   **`1.0.9 (620)`**; cihazda Setup teşhis satırı `Derleme 46664f6`
   gösterdi. Cihaz turu koşuldu ve **temiz geçti** (manzara/düzen/taşma
   yok); tek bulgu hiç oynanmamış YZ oyununun bulut kaydıydı → düzeltildi
   (aşağıdaki sürüm tablosuna bak). Böylece 24.3 (`aps-environment`), 24.4
   (Universal Links iOS yarısı) ve `mobile/TESTING.md` §26 artık
   koşulabilir durumda. ⚠ *"Ready to Submit"* bir engel DEĞİLDİ: o durum
   DIŞ dağıtımı anlatır, iç testçi için Beta App Review yok — ölçüldü.
   Kurulumun tuzakları (ekip daveti ≠ testçi daveti, "Redeem" ekranı bir
   kod istemiyor, tester statüsü teşhis aracı değil):
   `console-formlari.md` §14.
1. ✅ **API anahtarı ALINDI (9 Eylül 2026 akşamı)** — bir **Mac'ten**, ilk
   denemede. iPadOS'ta (özel sekme dahil) defalarca başarısız olmuştu;
   ölçüm arızanın istemci/platform tarafında olduğunu gösteriyor, Apple'ın
   sunucusunda değil. Support hiç yanıt vermeden çözüldü. ✅ **Ardından
   secret'lar girildi ve 24.2 uçtan uca doğrulandı** (#614 zinciri
   bitirdi, #616 doğru build numarasını kanıtladı) — yani bu madde artık
   hiçbir şeyi tıkamıyor. ⚠ Ama anahtar **imzalama için zorunlu değil, OTOMASYON için
   zorunlu** — `openssl` CSR + elle sertifika/profil + uygulamaya özel şifre
   ile anahtarsız bir zincir kurulabilir (kayıt `console-formlari.md` §3).
   Arıza uzarsa gönderim buna çevrilir.
2. ✅ **DSA doğrulaması BİTTİ (10 Eylül 2026, 22:21).** Apple'ın
   e-postası: *"We successfully verified your trader contact information…
   Your information is now live on the App Store in the European Union."*
   Beyan 9 Eylül → doğrulama 10 Eylül, yani **~1 gün** (ölçüldü, tek
   ölçüm). Gönderim kapısı DÜŞTÜ — kayıt `console-formlari.md` §2.

✅ **Bizde kod işi KALMADI** (11 Eylül 2026): 24.5'in kompozisyon kararı
verildi ve uygulandı (başlıklı set + 7. kare). Sıradaki adım **sende ve
Console'da**: (1) sürüm numarasını `1.1.0` yapıp derlemeyi iliştir,
(2) `ios-screenshots.yml`in bir sonraki koşusunun artefaktını indirip
kareleri 6.9" ve iPad 13" slotlarına yükle.

**Durum:** kullanıcı Apple Developer hesabını açtı. Bu, bugüne kadar altı
ayrı yerde *"🔒 Apple Developer üyeliğine bloke"* diye kayıtlı olan işleri
birden açıyor. Bu bölüm onların **hangi sırayla** yapılacağını söyler —
`0. FAZ B`nin (Google Play) App Store ikizi.

⚠ **Play'in sayacının burada karşılığı YOK.** Faz B'nin takvimini "12
tester × 14 gün" belirliyordu; Apple'da böyle bir bekleme yok. Buradaki
takvimi belirleyen tek şey **App Review** (reddedilirse tur başa döner).
TestFlight'ın *iç* test kanalı incelemesiz; *dış* kanal ayrı bir Beta App
Review istiyor. *(Apple dokümanından; bu depoda ÖLÇÜLMEDİ.)*

**Hesap kimliği (8 Eylül 2026, kullanıcı bildirdi + ekran görüntüsü):**
**Bireysel** (Individual), ad **Alp Reşat Çapa**, Apple ID
**`destek@kelimeki.com`**. Play tarafının karşılığı da kişiseldi
(*Personal account*, Account ID `5939732949280610022`), yani iki mağazada
tutarlı.

✅ **ÜYELİK AKTİF** — aynı gün 14:48'de `(Pending)` düştü (ekran
görüntüsüyle doğrulandı: *Program resources* açıldı, yani **App Store
Connect · Certificates, IDs & Profiles · Membership details** erişilebilir).
Ödeme→aktivasyon **~12 dakika** sürdü; Apple'ın vaat ettiği 48 saatlik
tavan bu turda hiç kullanılmadı. Kimlik taraması İSTENMEDİ.
**24.1 artık koşulabilir.**

⚠ **Bireysel hesabın geri alınamaz sonucu:** App Store'da satıcı olarak
**kişinin yasal adı** görünür ve sonradan değiştirilemez. 24.5'in cevap
kâğıdı bunu veri olarak alır, yeniden sormaz.

⚠ **`destek@kelimeki.com` artık kritik bir kutu:** üyelik yenileme,
sözleşme değişikliği ve App Review yazışmaları oraya düşüyor. Adres Zoho'da
(bkz. `docs/decisions/support-email.md`) ve o kutuya erişimi kaybetmek
geliştirici hesabına erişimi kaybetmek demek. Aynı sebeple Apple ID'nin
2FA'sındaki güvenilir numara/cihaz kalıcı olmalı.

⚠ **`(Pending)` iken hiçbir 24.1 adımı yapılamaz** (bu tur ~12 dakika
sürdü, ama kayda geçsin): Team ID, Identifiers ve Keys ekranları üyelik
aktifleşmeden açılmıyor. Pending sayfasındaki *"complete your purchase
now"* banner'ı hem "ödeme yapılmadı" hem "işleniyor" durumunda göründüğü
için **tek başına kanıt değil** — ayrım Apple'ın makbuzuyla yapılır
(`destek@` kutusu ya da `reportaproblem.apple.com`). Apple bireysel
kayıtlarda ayrıca kimlik taraması isteyebiliyor ve bunu web'den değil
iPad/iPhone'daki *Apple Developer* uygulamasından yaptırıyor; **bu turda
istenmedi**, ama uzun süre Pending kalan bir hesapta ilk bakılacak yer
orası. *(Apple'ın süreci; bu depoda ÖLÇÜLMEDİ.)*

### 24.0 — Neyin HAZIR olduğu (8 Eylül 2026'da depodan ölçüldü)

Beklenenden fazlası hazır; özellikle **sunucu tarafı push tamamen
iOS-hazır**, çünkü tasarım baştan FCM üzerinden yazıldı:

| Hazır olan | Kanıt |
|---|---|
| Bundle id `com.kelimeki.kelimeki` (Android'le AYNI), deployment target iOS 13 | `ios/Runner.xcodeproj/project.pbxproj:385,363` |
| CI'da macOS runner'lı `ios` işi — `--no-codesign` cihaz + Appetize simülatör derlemesi | `.github/workflows/mobile-build.yml:369` |
| `push_tokens.platform` **`'ios'` değerini zaten kabul ediyor**, `register_push_token` doğruluyor | `20260828114349_push_tokens_and_preference.sql:39` · `20260831093203_...:60` |
| Çakıştırma etiketinin iOS yarısı **yazılmış**: `apns-collapse-id` | `supabase/functions/_shared/push.ts:310` (`npm run verify-push-payload` kilitliyor) |
| Admin hata panelinde platform filtresi (#11) | ✅ 31 Ağustos 2026 |
| Sürüm kapısı iOS anahtarını okuyor | `config/version_gate.dart:35` → `Platform.isIOS ? 'ios' : 'android'` |
| `Info.plist`'te `kelimeki://` şeması + iPad yönelimleri | `ios/Runner/Info.plist:30,83` |

### 24.1 — SENDE: hesap & kimlik (Console işi, kod yok)

Bunlar bitmeden 24.2 ve 24.3 test EDİLEMEZ.

1. Üyeliğin aktifleştiğini doğrula (satın alma → aktivasyon Apple'da 24-48
   saat sürebiliyor).
2. **Team ID'yi not et.** 24.4'ün `apple-app-site-association` dosyası buna
   bağlı ve **ben üretemem** — Membership sayfasında yazıyor.
3. Identifiers → App ID `com.kelimeki.kelimeki`; capability olarak **Push
   Notifications** ve **Associated Domains** işaretlensin.
   ⚠ Bundle ID tipi **Explicit** olmalı — *Wildcard* App ID push
   DESTEKLEMEZ ve sonradan değiştirilemez.
   ⚠ Bu adım **5'i kilitliyor**: App Store Connect'in "New App" formunda
   bundle ID bir AÇILIR LİSTE, burada kayıtlı olmayan görünmez.
4. Keys → **APNs Authentication Key** (`.p8`) üret.
5. Keys → **App Store Connect API Key** (rol: Admin ya da App Manager) —
   `.p8` + **Key ID** + **Issuer ID**. CI'ın Mac'siz imzalama yolu bu.
6. App Store Connect → yeni uygulama: ad **Kelimeki**, birincil dil
   **Türkçe**, SKU, bundle id yukarıdaki.

⚠ **5 ve 6 burada İLK KEZ yazılmıyor** — `mobile/docs/test-ortamlari.md`
→ *"TestFlight kurulumu"* onları 25 Ağustos 2026'da adım adım yazmıştı.
O dosya kaynak, burası indeks.

⚠ **İki `.p8` KARIŞTIRILMAZ:** biri APNs (→ Firebase Console'a yüklenir),
biri App Store Connect API (→ GitHub secret'ı olur). İkisi de **yalnızca
bir kez indirilebilir**; kaybolursa iptal edip yenisi üretilir.

### 24.2 — BENDE: Mac'siz imzalama + TestFlight (CI)

**Kısıt, `mobile-build.yml`in kendi notundan:** *"geliştirici iPad'den
çalışıyor; elinde ne Mac ne Android cihaz var"* (satır 461). Yani imzalama
ve yükleme **tamamen CI'dan** yürümek zorunda — Xcode'da elle "Archive"
seçeneği YOK. Android'de `.aab` için kurulan desenin aynısı:

**KAYNAK BU BÖLÜM DEĞİL:** işletim adımları `mobile/docs/test-ortamlari.md`
→ *"TestFlight kurulumu"*'nda zaten yazılı (25 Ağustos 2026) ve orası daha
ayrıntılı. Burada yalnızca indeks duruyor — karar oradan okunur.

- `mobile-build.yml`'e `ios` işinin yanına imzalı `.ipa` adımı: App Store
  Connect API anahtarıyla headless sertifika + App Store profili, sonra
  `upload_to_testflight`.
- Secret'lar: `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
  `APP_STORE_CONNECT_KEY_P8`, `MATCH_PASSWORD`.
- ⚠ **`fastlane match` + AYRI BİR ÖZEL DEPO zorunlu, tercih değil:** Apple
  hesap başına dağıtım sertifikası sayısını sınırlıyor, yani her koşuda
  yenisini üretmek ÇALIŞMAZ — sertifika/profil şifreli olarak kalıcı bir
  depoda saklanmalı (gerekçenin tamamı `test-ortamlari.md`'de).
- **Secret yoksa adım sessizce atlanır** — `ANDROID_KEYSTORE_BASE64`'ün
  kuralı; mevcut Appetize/imzasız akışlar bozulmaz.
- ⚠ **Bu iş ancak gerçek anahtarla doğrulanabilir.** Yazıldığı an "çalışıyor"
  denemez; kanıt, TestFlight'ta beliren derlemedir (Faz B'de `.aab`'nin
  parmak izini CI log'undan geri okumakla aynı refleks).
- ⚠ **`mobile-build.yml`in başlığındaki iki yorum BAYAT ve bilerek
  düzeltilmedi** (satır 42-48 *"TestFlight… o iş üyelik geldiğinde
  eklenecek"*, satır 462 *"Apple Developer üyeliği (TestFlight) askıda"*).
  Sebep: o dosyaya dokunmak `paths` listesi gereği **tam bir macOS+Android
  derlemesi tetikliyor** ve deponun *"yalnızca doküman değişikliği
  ücretsizdir"* ilkesini bir yorum için bozmak anlamsız. **Düzeltme 24.2'nin
  kendi PR'ında yapılır** — imzalama adımı zaten o dosyaya giriyor.

### 24.3 — SENDE + BENDE: APNs / push

ROADMAP bunu bugüne kadar *"APNs anahtarını Firebase'e yükle + Push
capability ekle"* kadar kısa yazıyordu; ölçünce istemci tarafında üç dosya
daha çıktı.

| Kim | İş |
|---|---|
| Sen | Firebase Console → projeye **iOS uygulaması** ekle (`com.kelimeki.kelimeki`) → `GoogleService-Info.plist` indir |
| Sen | ✅ **YAPILDI (8 Eylül 2026)** — `.p8` Firebase'e yüklendi. **İKİ SATIR DA dolu** (*development* + *production*), ikisinde de `RL4JLXL389` / `8277D85FY9`. ⚠ Bu konsol sürümü ortamları AYRI satır olarak listeliyor ve **kritik olan `production`**: TestFlight/App Store derlemeleri production APNs'e bağlanır, yalnız development doluyken bildirim **hatasız** düşmez. *development* pratikte kullanılmıyor (Xcode debug derlemesi Mac ister, yok) — boş bırakılabilirdi, doldurmanın zararı yok |
| — | ⚠ **Yer bulma notu:** APNs yükleme ekranı *Project settings*'in **Cloud Messaging** sekmesinde ve dişli menüsünde GÖRÜNMÜYOR — dişliden **General**'a girip sekme şeridini kullanmak gerekiyor. Firebase bu bölümü birkaç kez taşıdı |
| — | ✅ **APNs anahtarı ÜRETİLDİ** (8 Eylül 2026): **Key ID `RL4JLXL389`**, ad *Kelimeki APNs*, Team Scoped (All Topics) + Sandbox & Production. Firebase'e yüklenmesi gereken üçlü: bu Key ID + Team ID `8277D85FY9` + `.p8` |
| Ben | ✅ **YAPILDI (8 Eylül 2026)** — `ios/Runner/GoogleService-Info.plist`. Aynı Firebase projesi doğrulandı (`kelimeki` / `791040026998`, bundle id eşleşiyor). Android'in `google-services.json`'ı da repoda, aynı karar. ⚠ **Klasöre atmak YETMEZ:** `project.pbxproj`'a dört yerden kaydedildi (PBXFileReference · PBXBuildFile · Runner grubu · **Runner hedefinin Resources fazı**). Sonuncusu olmadan dosya pakete GİRMEZ ve `Firebase.initializeApp()` cihazda sessizce başarısız olur. ⚠ Firebase Console'un **"Flutter"** akışı KULLANILMADI — o akış `firebase_options.dart` üretip Android tarafını da yeniden yazar; bu depo yapılandırmayı iki platformda da NATIVE dosyadan okuyor |
| Ben | `ios/Runner/Runner.entitlements` — dosya bugün **hiç yok**; `aps-environment` + `Info.plist`'e `UIBackgroundModes: remote-notification` |
| Ben | `AppDelegate.swift`'e bildirim paneli kanalı |

⚠ **`.p8` DOSYALARI DEPOYA GİRMEZ — depo PUBLIC** (8 Eylül 2026'da
doğrulandı: `alpcapa/kelimeki`, `visibility: public`). Burada yalnızca
**Key ID** ve **Team ID** kayıtlı; ikisi de gizli değil (Team ID her iOS
uygulamasının AASA'sında zaten yayınlanıyor, APNs Key ID her push JWT'sinin
`kid` başlığında gidiyor) ve özel anahtar olmadan işe yaramıyorlar.
Kaydedilmelerinin sebebi operasyonel: hesapta birkaç anahtar birikince
"Firebase hangisini kullanıyor" sorusunun cevabı olmazsa **yanlış anahtar
iptal edilip canlıda push düşer**.

⚠ **APNs anahtarının iki ayarı sessiz arıza üretir** (bu turda seçildi,
kayda geçsin): *Environment* **Sandbox & Production** olmalı — TestFlight
ve App Store derlemeleri Production'a, Xcode'dan çıkan geliştirme
derlemeleri Sandbox'a bağlanır; tek ortam seçilirse öteki tarafta bildirim
**hata vermeden** gelmez. *Type* **Team Scoped (All Topics)** — kısıtlı bir
anahtar, sonradan eklenen bir bundle ID'de aynı şekilde sessizce çalışmaz.

**Kanal adı ve metot BUGÜNDEN belli, uydurulmayacak** —
`data/notification_shade.dart:52,56` Kotlin tarafıyla birebir aynı olmak
zorunda diyor ve iOS için ne yapılacağını da yazmış: kanal
`kelimeki/bildirimler`, metot `hepsiniTemizle`, iOS karşılığı
`removeAllDeliveredNotifications()`. **Dart tarafı DEĞİŞMEZ.** Parite testi
(`test/notification_shade_parity_test.dart`) bugün Kotlin'i okuyor; iOS
yarısı eklenince Swift'i de okumalı — yoksa uyuşmazlık SESSİZ arıza
(çağrı `MissingPluginException` fırlatır ve yutulur).

⚠ **iOS rozeti bugün hiç ARTMAZ ve bu ayrı bir karar.** Rozet
`aps.badge`den geliyor, sunucu onu **hiç göndermiyor**
(`notification_shade.dart:26`). Yani "paneli temizle" işi iOS'ta rozet
değil yalnızca bildirim satırlarını hedefler. Sunucuya `badge` eklenip
eklenmeyeceği bu fazın parçası DEĞİL — açılırsa `_shared/push.ts` +
`verify-push-payload` birlikte değişir.

### 24.4 — Universal Links (Associated Domains) — **CİHAZDA DOĞRULANDI ✅** (13 Eylül 2026)

✅ **İki yarı da çalışıyor, kanıt cihazdan geldi.** iPad'de Safari'de
`kelimeki.com` açılınca üstte **"Kelimeki: Türkçe Kelime Oyunu — Open in
the Kelimeki app · OPEN"** bandı çıktı (TestFlight 665 kurulu). Bandın
çıkması iki şeyi birden kanıtlıyor: Apple'ın CDN'i AASA'yı **doğrulamış**
ve uygulama `associated-domains` yetkisini **taşıyor**. Aynı anda
depodan/canlıdan ölçüldü: `content-type: application/json` ✅ (aşağıdaki
Vercel tuzağı geçilmiş).

⚠ **Bu bant §26'nın Smart App Banner'ı DEĞİL** — depoda `apple-itunes-app`
meta etiketi yok (13 Eyl 2026'da `index.html`/`src/`/`public/` tarandı,
sıfır eşleşme). İkisi kolay karışıyor ama işleri farklı: Universal Links
bandı yalnızca **uygulamayı ZATEN kurmuş** kişiye çıkar; §26'nın rozetleri
ve Smart App Banner'ı uygulamayı hiç görmemiş ziyaretçi içindir. Biri
ötekinin yerini tutmaz.

**Aşağısı işin nasıl kurulduğunun kaydı.**

**ROADMAP 0.B/3'ün açık kalan TEK parçası buydu** (satır 858).

**Team ID: `8277D85FY9`** (8 Eylül 2026, Membership details'ten okundu —
gizli değil, uygulama kimliğinin parçası).

✅ **Web yarısı YAZILDI** (8 Eylül 2026):
`public/.well-known/apple-app-site-association`, tek `appID`
`8277D85FY9.com.kelimeki.kelimeki`.

**Kapsam Android'le BİLEREK aynı: `/*`, yani tüm `kelimeki.com` yolları.**
`AndroidManifest.xml`'deki `autoVerify` intent-filter'ında da `android:path`
kısıtı yok. İkisi ayrışırsa aynı link iki platformda farklı davranır ve bu
**sessiz** bir arızadır — kapsamı daraltmak isteyen iki tarafı BİRLİKTE
daraltmalı.

⚠ **Vercel'de `Content-Type` ELLE verilmek zorunda ve bu iOS'a özgü.**
Apple dosyayı **uzantısız** istiyor, Vercel ise Content-Type'ı uzantıdan
türetiyor — yani dosya varsayılan olarak `application/json` etiketlenmez ve
Apple'ın CDN'i doğrulamayı reddedebilir. `vercel.json` → `headers`'a açık
bir kural eklendi. `assetlinks.json`'ın böyle bir derdi YOK (`.json`
uzantısı var; canlıda ölçüldü: `content-type: application/json`), o yüzden
bu tuzak Android turunda hiç görülmedi.
⚠ `vercel.json`'a **şema dışı anahtar YAZILMAZ** — gerekçe yorumu olarak
bir `comment` alanı denendi ve geri alındı; Vercel `vercel.json`'ı şemaya
göre doğruluyor, bilinmeyen anahtar deploy'u kırabilir.

**Ölçüldü (derlemeden sonra):** dosya `dist/.well-known/`e kopyalanıyor ve
service worker precache'ine **girmiyor** (`globPatterns` varsayılanı
uzantıya bakıyor, uzantısız dosya eşleşmiyor) — yani SW araya girmiyor.

**KALAN — iOS yarısı, 24.3 ile AYNI PR'da:**
- `ios/Runner/Runner.entitlements` (dosya bugün hiç yok) →
  `com.apple.developer.associated-domains` = `applinks:kelimeki.com`
- `project.pbxproj` → `CODE_SIGN_ENTITLEMENTS` bu dosyayı göstermeli
- ⚠ App Links'in Android'deki dersi burada da geçerli: doğrulama yalnızca
  **TestFlight/mağaza imzalı** derlemede sınanabilir, CI'nın imzasız
  çıktısında değil (`mobile/docs/sonraya-birakilanlar.md`).

⚠ **Yayından sonra `curl` ile OKU** (deploy doğrulamasının aynı kuralı):
```
curl -sI https://kelimeki.com/.well-known/apple-app-site-association | grep -i content-type
```
`application/json` dönmüyorsa Apple doğrulaması yapılmadan iOS yarısına
geçme — entitlements doğru olsa bile link uygulamayı açmaz.

### 24.5 — SENDE + BENDE: mağaza vitrini

- **Ben:** `marketing/app-store/console-formlari.md` — Play'in cevap
  kâğıdının iOS ikizi. **App Privacy**, Play'in Data safety'sinin eşi ve
  büyük ölçüde ondan türer (`marketing/play-store/console-formlari.md` §3).
  Kategori **Games → Word**, destek URL `kelimeki.com`, gizlilik URL
  `kelimeki.com/gizlilik/`, hesap silme `kelimeki.com/hesap-silme/`.
- **Ekran görüntüleri — cihaz yokluğu burada ısırıyor.** Apple hem büyük
  iPhone hem (uygulama iPad'i desteklediği için) **13" iPad** seti istiyor.
  Play'de bunlar gerçek cihazdan alınmıştı; burada kaynak CI'nın zaten
  ürettiği **simülatör derlemesi** (`kelimeki-ios-simulator.zip`) ya da
  Appetize. Çözülmemiş: simülatör penceresinden Apple'ın istediği tam
  piksel ölçüsünde kare almanın yolu — **ölçülmedi, tur açılırken bak.**
- ⚠ **App Store 4.8 kapısı bugün KAPALI ve öyle kalsın:** uygulamada
  üçüncü taraf girişi YOK, o yüzden "Apple ile giriş" de zorunlu değil.
  #17 (Google ile giriş) iOS'a girdiği gün ikisi **birlikte** gider —
  gerekçe #17 → "Apple neden bu maddede YOK".
- ⚠ **`in_app_update` Android'e özgü**, iOS'ta karşılığı yok
  (`mobile/CLAUDE.md`). Yani iOS'ta elimizdeki TEK fren sürüm kapısı
  (`app_config.mobile_min_supported_version`).
  ✅ **9 Eylül 2026'da CANLIDAN ölçüldü: anahtar EKSİK DEĞİL** —
  satır `{"ios":"0.0.0","android":"0.0.0"}`. Bu bölüm *"o anahtarın satırı
  doldurulmalı"* diyordu; yanlıştı, `version_gate.dart`in okuduğu `'ios'`
  anahtarı zaten yazılı. **`0.0.0` bugün DOĞRU değer** (fail-open: kapı
  kapalı, zorunlu güncelleme yok) çünkü henüz yayınlanmış bir iOS sürümü
  yok. Gerçek iş şu: ilk TestFlight/App Store sürümünden SONRA bu satır
  iOS'ta tek fren olduğu için bilinçli yükseltilmeli — Android'deki gibi
  bir mağaza diyaloğu devreye girmiyor.

### 24.6 — Gönderim & inceleme

TestFlight'ta çalışan bir derleme + 24.5'in formları tamamlanınca gönderim.
Faz B'nin dersi burada da geçerli: **bir işin kaydı iki yerde durursa biri
kapanırken öteki kapanmıyor** — bu tablo bir İNDEKS, kararların kaynağı
`marketing/app-store/console-formlari.md` olacak.

### Sıra ve bağımlılıklar

```
24.1 (sende, Console)
  ├─→ 24.2 (imzalama/TestFlight)  ─┐
  ├─→ 24.3 (APNs)                  ├─→ 24.6 (gönderim)
  ├─→ 24.4 (Universal Links)      ─┤
  └─→ 24.5 (vitrin) ───────────────┘
```

**24.1 tek gerçek kilit.** 24.5'in cevap kâğıdı ondan bağımsız yazılabilir
(hesap tipi hariç); 24.2/24.3/24.4 anahtarlar ve Team ID gelmeden
YAZILABİLİR ama DOĞRULANAMAZ — ve bu depoda "yazıldı" ile "çalışıyor"
arasındaki farkın bedeli defalarca ödendi.

---

## Güvenlik geçişi — kapanan maddeler (#19, #20) — ✅ **ÖLÇÜLDÜ, KABUL EDİLDİ** (5 Eylül 2026)

⚠ Bu iki madde "düzeltildi" diye değil, **ölçülüp bilinçli olarak kabul
edildi** diye kapandı — yani burada duran şey bir çözüm değil, bir KARAR ve
onun gerekçesi. Geçiş bir gün yeniden açılırsa önce bunlar okunmalı.
`ROADMAP.md`'de yerlerinde tek satırlık bir işaret bırakıldı; 18 ve 22
orada AÇIK duruyor.

### 19. `anon` için sınırsız telemetri yazımı — **ÖLÇÜLDÜ: KABUL EDİLDİ**

`client_errors`, `device_visits`, `guest_visits`, `game_starts` — dördünde
de INSERT politikası `with_check: true`, yani oturumsuz sınırsız satır
eklenebiliyor. **İlk yazımda "feedback_rate_limit desenini kopyala" deniyordu;
o tavsiye ÖLÇÜMDEN ÖNCEYDİ ve GERİ ALINDI.** Ölçünce üç şey çıktı:

**1. İddia edilen zarar büyük ölçüde YOK — tüketici zaten dayanıklı.**
Dokuz admin RPC'sinin sekizi `count(distinct ...)` kullanıyor.
`admin_source_funnel`ın "Ziyaretçi" adımı YALNIZCA
`count(distinct gv.anon_id)`; `game_starts`/`game_finishes` adımları ham `n`
ile `uniq`i YAN YANA döndürüyor (ham sayı meşru olarak ham: "toplam
başlangıç"). `admin_activation_stats` bu tabloların hiçbirine dokunmuyor.
Yani bir sel `uniq` sütunlarını oynatamaz.

**2. Bugün kötüye kullanım yok ve hacim küçük** (5 Eylül 2026):

| Tablo | Toplam | Farklı cihaz | Son 7 gün |
|---|---|---|---|
| `client_errors` | 40 | 27 | 12 |
| `device_visits` | 877 | 731 | 184 |
| `guest_visits` | 2.316 | 2.032 | 128 |
| `game_starts` | 931 | 181 | 346 |

**3. IP'ye anahtarlanan bir limitin İKİ yan etkisi, faydasından büyük:**
- **CGNAT.** Türk mobil operatörleri operatör düzeyinde NAT kullanıyor;
  gerçek kullanıcılar tek çıkış IP'sini paylaşıyor. Ziyaret/oyun başına
  yazan bir tabloda IP limiti gerçek satırları SESSİZCE düşürür (istemci
  hatayı yutuyor — ölçüldü, iki tarafta da fire-and-forget) ve huni EKSİK
  sayar. Bu, önlemeye çalıştığımız zararın aynı sınıfı, ters yönü.
- **`client_errors`'ta olayı gizler.** Tek cihazdan gelen hata seli tam da
  görmek istediğin şeydir; limit gerçek bir çökme olayında kanıtı kısar.
  Üstelik #10 ile istemci tarafında zaten hız sınırı var.

**Karar: bugün bir şey yapma.** Yeniden açılma tetikleyicisi: telemetri
tablolarından birinde `count(*)` ile `count(distinct anon_id)` arasında
açıklanamayan bir uçurum görülmesi, ya da satır sayısının maliyet yaratacak
mertebeye çıkması.

⚠ Limit ileride gerekirse **IP'ye DEĞİL `anon_id`'ye anahtarla** — CGNAT
komşularını vurmaz. Saldırgan `anon_id`yi de döndürebilir (yani naif seli
durdurur, kararlıyı durdurmaz), ama dürüst kullanıcıya maliyeti sıfırdır.

### 20. `CRON_SECRET` fail-open — **ÖLÇÜLDÜ: DÜŞÜK, kabul edilebilir**

**Durum (5 Eylül 2026): `CRON_SECRET` Dashboard'da TANIMLI DEĞİL** (kullanıcı
ekran görüntüsüyle doğruladı — Custom secrets'ta yalnızca `BREVO_API_KEY` ve
`FCM_SERVICE_ACCOUNT` var). Yani `if (CRON_SECRET && ...)` kapısı fiilen
açık ve **üç** fonksiyon (beş değil — ilk sayım yanlıştı) internetten
çağrılabiliyor: `notify-deadline-warnings`,
`notify-friend-request-reminders`, `sweep-unconfirmed-accounts`.

**Ama etkisi ölçüldü ve düşük** — üçünde de atomik "iddia" koruması var
(`.is(alan, null)` filtreli UPDATE), yani `notify-turn-timeout-surrender`
ile aynı desen:

| Fonksiyon | Dışarıdan tekrar çağrılırsa |
|---|---|
| `notify-deadline-warnings` | `deadline_warning_sent_at` → satır başına tek mail |
| `notify-friend-request-reminders` | `reminder_sent_at` → aynısı |
| `sweep-unconfirmed-accounts` | Yaş ölçütünü kendi uyguluyor → erken silme YOK |

Saldırgan zaten gönderilmeyecek tek bir mail bile göndertemiyor; kalan etki
yalnızca boşa çağrı maliyeti. **Bu yüzden acil değil.**

⚠ **Düzeltmenin bedeli faydasından büyük olabilir — üç parça aynı anda
değişmek zorunda.** Ölçüldü: `cron.job`taki üç komut da **hiçbir
`Authorization` başlığı göndermiyor** (`headers` yalnızca `Content-Type`).
Yani secret'ı tek başına tanımlamak üç özelliği birden 401'e düşürür ve
arıza SESSİZ olur (mailler durur, hata veren bir yüzey yok). Sıra şu
olmalı: secret + cron komutları + kodun fail-closed'a çevrilmesi, hepsi
tek turda.

**İki seçenek:**

- **(a) Vault ile, Dashboard adımı OLMADAN:** sır `supabase_vault`'ta
  (0.3.1 kurulu), cron komutu onu okuyup `Authorization` başlığına koyar,
  Edge Function beklenen değeri kendi `service_role` istemcisiyle DB'den
  okur. Depoda ve sohbette sır geçmez, tamamen ajandan doğrulanabilir.
  Bedeli: çağrı başına bir DB okuması (15 dk/saatlik/günlük iş için
  önemsiz) ve koddaki `Deno.env.get('CRON_SECRET')` deseninden sapma.
- **(b) Kabul et ve YAZ:** bugünkü fiili durum bu; ölçüm yukarıda. Bu
  seçilirse koddaki `if (CRON_SECRET && ...)` satırlarına "secret bilerek
  tanımlı değil, koruma iddia sütunlarından geliyor" notu düşülmeli —
  aksi halde bir sonraki okuyan onu çalışan bir kapı sanır.

⚠ **`inbound-email` bu maddeye DAHİL DEĞİL.** O fail-closed yazılmış
(`INBOUND_EMAIL_SECRET` yoksa 503) ve sırrının tanımsız olması BİLİNÇLİ:
Brevo Inbound webhook'u ücretli plana bloke, bkz.
`docs/decisions/support-email.md` → "GELEN ZİNCİRİ DURDURULDU". Boş
`support_inbox` (0 satır) beklenen durum, arıza değil.

---

## 25. iPad MANZARA düzeni — **KAPANDI** (9-10 Eylül 2026)

**Kullanıcı kararı, sözleri birebir:** *"Ipad olmazsa olmaz. Bu oyunun en
iyi oynandığı yer orası."*

Bu, iPad'in konumunu değiştiriyor: "desteklenen ikinci cihaz" değil,
**birinci sınıf yüzey**. Dolayısıyla manzara sorusu da değişiyor —
*"kırılıyor mu?"* değil, ***"iyi mi?"***

**Nasıl açıldı:** App Store yüklemesi bundle'ı reddetti (90474) — iPad'i
destekleyen bir uygulama `UISupportedInterfaceOrientations~ipad` altında
DÖRT yönelimi bildirmek zorunda. `Info.plist` düzeltildi (#501) ve bunun
sonucu şu: **uygulama iPad'de artık döndürülebilir.**

⚠ **`main.dart`in portre kilidi iPad'de FİİLEN ÖLÜ.**
`setPreferredOrientations([portraitUp])` iPhone'da tutuyor, ama çoklu göreve
açık bir iPad uygulamasında iOS onu yok sayıyor; `UIRequiresFullScreen` ile
kapatmak da modern SDK'larda güvenilir değil. Yani manzara artık bir
"ihtimal" değil, kullanıcının bir saniyede ulaşacağı hâl.

⚠ **Portta manzara için HİÇBİR ŞEY yok** (kaynak taramasıyla doğrulandı):
web'in `LandscapeHint` bileşeninin karşılığı hiç port edilmedi, manzaraya
özgü bir düzen de yok.

**Sıra (hepsi tamamlandı):**

1. ✅ **ÖLÇÜLDÜ — ve ölçümün kendisi bir yolu ELEDİ.**
   - **Ön ölçüm (9 Eylül, Linux widget ağacı):** oyun · kurulum · yardım ×
     portre (1032×1376) · manzara (1376×1032) · dar pencere (458×1032) =
     dokuz kombinasyonda **taşma SIFIR**. Manzara kırılmıyor. Asıl bulgu
     başka: uygulama `max-w-680` kolonuyla çizildiğinden 13" iPad'de
     manzarada genişliğin ~%50'si, portrede altta ~%25'i boş kalıyor — yani
     manzara portreden daha KÖTÜ değil, ikisi de "telefon düzeni büyük
     ekranda".
   - ⚠ **GERÇEK SİMÜLATÖRDE ÖLÇÜM DENENDİ ve ELENDİ.** 24.5'in kare boru
     hattı zaten gerçek bir `iPad Pro 13"` simülatörü koşturduğu için ölçüm
     oraya bindirildi (`ios-screenshots.yml`e ikinci iş). **Simülatör
     DÖNMEDİ** ve sebebini iOS'un kendisi yazdı:
     ```
     UISceneErrorDomain Code=101 "The current windowing mode does not
     allow for programmatic changes to interface orientation."
     ```
     Yani çoklu göreve açık bir iPad uygulamasında
     `SystemChrome.setPreferredOrientations` **İKİ YÖNDE DE** geçersiz —
     bu bölüm bunun yalnızca portre yönünü yazıyordu, artık iki yönü de
     alıntılanabilir bir hata koduyla kanıtlı. **Sonuç: iş silindi.**
     Manzara metriklerini kurabilen tek şey `tester.view.physicalSize`
     override'ı ve o platformdan bağımsız, yani 14 dakikalık macOS işi
     hiçbir şey eklemiyordu.
   - ⚠ **İKİ TURLUK DERS:** ilk sürüm dönüşü bir `expect` ile zorunlu
     kılmıştı; koşu #6'da altı testin altısı o satırda düştü ve bulgunun
     GERİ KALANINI (kareler, taşma raporu, kutular) beraberinde götürdü.
     Dönüş raporlamaya çevrilince (koşu #7) ölçüm baştan sona koştu ve
     iOS'un hata satırı ancak o zaman görüldü. **Bir ölçü aletinin düşme
     koşulu, ölçtüğü şey OLMAYABİLİR diye kurulmaz.**
   - **Cihazda kalan yarım — SENDE.** `mobile/TESTING.md` §26: gerçek
     dönüşün hissi, gerçek Split View/Slide Over jesti, klavye açıkken
     daralan modal. Bunlar tanım gereği otomatikleştirilemiyor.

2. ✅ **KARAR VERİLDİ — (b): mevcut düzen kalıyor** (9 Eylül 2026,
   kullanıcı; sözleri birebir): *"Eğer Apple açısından sıkıntı yoksa bazı
   ekran tiplerinde alt kısımda boşluk kalması ok. Sonuçta her ekran
   tipine göre ekran design etmek çok maliyetli bir iş olur ve riskli
   olur."*
   Elenen iki yol: (a) manzaraya özgü düzen — maliyet/risk gerekçesiyle,
   (c) `LandscapeHint` portu — manzara kırılmadığı için uyarılacak bir şey
   yok, uyarı yalnızca çalışan bir ekranı kapatırdı.
   **Kararın koşulu ÖLÇÜLDÜ (Apple'ın yazılı kuralı, aynı gün okundu):**
   bugünkü **2.4.1** yalnızca *"iPhone apps should run on iPad whenever
   possible"* diyor — letterboxing/"ekranı tam kullan"/"büyütülmüş iPhone
   uygulaması" diye bir yasak metni YOK; **2.3.3** ekran görüntüsünden
   yalnızca *"uygulamayı kullanımda göstersin"* istiyor. Bu turda Apple'dan
   gelen tek sert kapı **90474**'tü (dört yönelim bildirimi) ve kapandı.
   ⚠ **Ölçülemeyen taraf:** App Review'ın İNSAN yorumu. Bu depoda
   kanıtlanabilecek şey yazılı kuraldır, inceleyicinin takdiri değil.
   **Sonucu:** bu madde artık bir TASARIM işi değil, bir **gerileme
   kontrolü** — sorulacak soru *"iyi mi?"* değil, tekrar *"kırılmıyor mu?"*.
3. ⚠ **iPad desteğini bırakmak SEÇENEK DEĞİL** — kullanıcı kararı yukarıda.
   `TARGETED_DEVICE_FAMILY = "1,2"` kalıyor.
4. ✅ **GERİLEME KAPISI KURULDU** — `mobile/app/test/ipad_layout_test.dart`
   (10 Eylül 2026). Üç ölçüde (portre · manzara · Split View 1/3) taşma
   yok + tahta/raf ekranın içinde + `OYNA`/`PAS GEÇ`/`OYUNU BAŞLAT`
   erişilebilir; 9 test, ~4 saniye, her push'ta. **Boşluk ÖLÇÜLMEZ** —
   kararın kendisi bunu bilinçli kabul yaptı. Duyarlılığı kanıtlandı: dar
   pencere geçici olarak 200×320'ye çekilince hem tahta hem `OYUNU BAŞLAT`
   yakalandı.

**Neden ROADMAP'te:** bu bir gönderim kapısı DEĞİL (Apple bundle'ı yönelimler
bildirildiği an kabul ediyor), ama iPad birinci sınıf yüzeyse App Store'da
"en iyi oynandığı yer" olarak sunulan cihazda ölçülmemiş bir düzen bırakmak
kabul edilebilir değil.

## İçindekiler

> Madde 31, madde 24 (FAZ C), güvenlik #19-#20 ve madde 25'in gövdesi bu
> dosyada (yukarıda); tablonun geri kalanının gövdesi
> **`roadmap-arsiv-cilt-1.md`**'de (dondurulmuş, 25 Eylül 2026).

| Ne | Kapanış |
|---|---|
| Madde 31 · **Davet linki `use_count`'u gerçeğin ~12 katı** — `accept_friend_invite` idempotent (iki migration) + `/davet` kuyruğu çağrıdan ÖNCE temizleniyor; kapı `verify-invite-queue` | 18-19 Eylül 2026 |
| Madde 24 · **FAZ C — App Store yayını**, altı fazın tamamı (hesap/kimlik · Mac'siz imzalama + TestFlight · APNs · Universal Links · vitrin + kare boru hattı · gönderim); `1.1.0 (665)` yayında | 15 Eylül 2026 |
| Güvenlik geçişi #19-#20 — `anon` telemetri yazımı · `CRON_SECRET` fail-open (ikisi de ölçülüp kabul edildi; #18 ve #22 ROADMAP'te AÇIK) | 5 Eylül 2026 |
| Madde 24 · Onboarding — "Oynayarak öğren" tanıtımı, BEŞ fazın tamamı (senaryo · bağlamsal ipuçları · tekrar izleme · port ikizi · ölçüm) | 8 Eylül 2026 |
| 1.1.0 sürüm turu — iki pakette (627 · 659), İKİ mağazaya birden; kapalı testte yayında | 11-12 Eylül 2026 |
| 1.0.9 sürüm turu — "oynayarak öğren" tanıtımının port ikizi, kapalı testte yayında | 8 Eylül 2026 |
| 1.0.8 sürüm turu — seviyeli YZ'nin tamamı (Kolay · Normal · Zor), kapalı testte yayında | 7 Eylül 2026 |
| Madde 23 · Faz 2 — motor: `findAIMoves`/`pickTopMove`/`AI_LEVEL_TOP_N` üç kopyada, `GameState.aiLevel`, golden sıfır fark + `reducer_ai2_kolay` | 6 Eylül 2026 |
| Madde 23 · Faz 1 — sunucu: `games.ai_level` + k-lig formülü TEK SQL fonksiyonu (`league_points_for`), `verify-league-points` | 6 Eylül 2026 |
| Madde 23 · Faz 0 — YZ seviye kadranının ölçüm aleti (`simulate-ai-levels`), Kolay N=4 | 6 Eylül 2026 |
| Hata avı geçişi (incelemenin 2. geçişi) | 5 Eylül 2026 |
| Performans geçişi (incelemenin 3. geçişi) | 5 Eylül 2026 |
| Temizlik geçişi (incelemenin 4. geçişi) | 5 Eylül 2026 |
| Madde 1 — `kelimeki://` deep link kanalı | 30 Ağustos 2026 (Faz 3'te ölçüldü) |
| Madde 6 — taranabilir `/nasil-oynanir/` sayfası | 31 Ağustos 2026 |
| Madde 10 — hata raporlama hız sınırı zamana bağlandı | 31 Ağustos 2026 |
| Madde 11 — hata panelinde platform filtresi | 31 Ağustos 2026 |
| Madde 2 — zorunlu güncelleme (Play'in kendi bildirimi yeterli) | 2 Eylül 2026 |
| Madde 8 — FAZ A1 Bölüm 6, iPad paylaş popover'ı (hata bulundu, düzeltildi, doğrulandı) | 3 Eylül 2026 |
| Madde 3 — davetlilere hatırlatma (kullanıcı: zaten yürüyen alışkanlık) | 2 Eylül 2026 |
| Madde 12 — sürüm dağılımının kapsamı | 31 Ağustos 2026 |
| Madde 13 — push bildirimleri + Firebase Analytics (spesifikasyon; gövdesi Faz 1-7'de) | 2 Eylül 2026 |
| Madde 16 — devam eden oyun kartlarının düzen ayrışması | 2 Eylül 2026 |
| Hata avı geçişi #24 — `CONFIRM_SWAP` taslak taşları yok ediyordu | 5 Eylül 2026 |
| Hata avı geçişi #25 — taş değiştirme seçimi indekse bağlıydı | 5 Eylül 2026 |
| Hata avı geçişi #23 — Edge Function'daki motor kopyası bayattı (CANLIDA) | 5 Eylül 2026 |
| Faz 1-7 + Faz dışı (push bildirimleri, madde 13'ün gövdesi) | 30-31 Ağustos, 1 Eylül 2026 |
| 1.0.3, 1.0.4 ve 1.0.5 sürüm turları | 31 Ağustos, 1 ve 2 Eylül 2026 |
| Sürüm A çıkışı + Sürüm B sözlük eklemeleri | 27 ve 31 Ağustos 2026 |

**1.0.5 sürüm turu da burada** (2 Eylül 2026 akşamı eklendi): ilk taşımada
ROADMAP'te bırakılmıştı çünkü üç işin cihaz doğrulaması ⬜'dü; kullanıcı aynı
gün *"1.0.5 turu testi tamam. Herşey düzgün çalışıyor."* deyince tur kapandı
ve kural gereği aynı gün taşındı.

---
