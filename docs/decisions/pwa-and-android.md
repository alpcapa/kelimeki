# PWA — Servis Çalışanı ve Android Uyumluluğu — Karar Kaydı

> docs/decisions/'e taşındı (context split, 24 Ağustos 2026).

## PWA — Servis Çalışanı Güncellemesi ve Android Uyumluluğu (31 Temmuz 2026)

Kullanıcının Android kullanan bir tanıdığı iki ayrı sorun bildirdi (ekran görüntüsüyle): (1) `color-scheme: light` düzeltmesine (23 Temmuz 2026, bkz. `LogoMark` notundaki FOUT anlatımının hemen öncesi) rağmen sayfa hâlâ siyah zeminle açılıyordu; (2) "Ana Ekrana Ekle" denenince Google Play Protect "Güvenli olmayan uygulama engellendi — bu uygulama Android'in daha eski bir sürümü için geliştirilmiş" uyarısıyla kurulumu tamamen engelliyordu.

- **Siyah zemin — kök sebep gerçek bir güncelleme-engelleme hatasıydı (`src/lib/pwa.ts`):** `registerType: 'prompt'` olduğundan yeni bir sürüm hazır olduğunda sayfa kendiliğinden yenilenmiyor, `tryApplyUpdate()` bunu ne zaman uygulayacağına karar veriyor. Düzeltmeden ÖNCE bu karar `loadGameState() !== null` (yani localStorage'da HERHANGİ bir yarım kalmış Yapay Zeka oyunu var mı) koşuluna bağlıydı — niyeti "oyun sırasında habersizce kesintiye uğratma" idi, ama gerçekte "şu an bu oyunu OYNUYOR muyum" sorusunun çok kaba bir vekiliydi: kullanıcı Setup ekranında dursa, hatta uygulamayı hiç açmasa bile, yarım bıraktığı bir oyun "Devam eden oyunun kalıcılığı" tasarımı gereği günlerce/haftalarca localStorage'da kalabiliyordu — o süre boyunca güncelleme SONSUZA DEK erteleniyordu. Sonuç: sürekli yarım bir oyunu olan gerçek kullanıcılar (bu tanıdık dahil) haftalar sonra bile 23 Temmuz'daki `color-scheme` gibi kritik düzeltmeleri hiç almıyordu. **Düzeltme:** `pwa.ts`'e `setActivelyPlaying(v: boolean)` adında dışa açık bir bayrak eklendi; `App.tsx`'teki yeni bir `useEffect` bunu yalnızca kullanıcı GERÇEKTEN o an bir oyun ekranındayken (`state.phase==='play' && !state.isGameOver` YA DA açık bir Canlı `onlineGame` ekranı) `true` yapıyor — `tryApplyUpdate` artık `loadGameState()` yerine bu canlı bayrağı kontrol ediyor. Yarım kalmış ama o an görüntülenmeyen bir kayıt artık güncellemeyi bloklamıyor.
  **Bu düzeltme geriye dönük olarak "şu an zaten takılı kalmış" kullanıcıları anında kurtarmaz** — onların tarayıcısında hâlâ ESKİ service worker/JS çalıştığından, güncelleme uygulama kararını hâlâ ESKİ (hatalı) mantık veriyor; yeni düzeltme ancak bir kez uygulandıktan SONRA devreye girebilir (tavuk-yumurta). Böyle sıkışmış biri için pratik çözüm: yarım kalan oyunu bitirmek/terk etmek (en geç 7 gün içinde `ABANDON_TIMEOUT_MS` kendiliğinden temizler, bir sonraki visibilitychange/focus/saatlik kontrolde güncelleme uygulanır) ya da tarayıcıda site verisini/önbelleği elle temizlemek.
- **Play Protect "Anladım" engeli — WebAPK'nin hedef Android SDK sürümüyle ilgili, bizim tarafımızdan düzeltilemez:** Chrome'un "Ana Ekrana Ekle"si, kurulabilir bir PWA için gerçek (küçük) bir APK sarmalayıcı (**WebAPK**) üretir — bunu Google'ın kendi WebAPK Minter servisi, CİHAZDAKİ Chrome/Android System WebView sürümüne göre oluşturur. Google Play Protect'in "daha eski bir Android sürümü için geliştirilmiş" uyarısı APK'nın hedef SDK sürümüne bakıyor — bu değer bizim `manifest.webmanifest`'imizden DEĞİL, o cihazdaki WebAPK üretim şablonundan geliyor; site tarafında kontrol edilemez. `vite.config.ts`'teki PWA manifest'i (name/short_name/description/icons 192+512+maskable/display/scope/start_url) baştan sona kontrol edildi, eksik/bozuk bir şey bulunmadı — kurulabilirlik kriterleri zaten sağlanıyordu. Yine de iki küçük, doğru ama muhtemelen bu uyarıyı düzeltmeyecek iyileştirme yapıldı: `id: '/'` eklendi (modern manifest spesifikasyonunun önerdiği, Chrome'un kurulu uygulamayı sürümler arasında doğru tanımasını sağlayan alan) ve `lang: 'tr'` eklendi (öncesinde vite-plugin-pwa'nın varsayılanı olan `"en"` sızıyordu — Türkçe bir uygulama için yanlıştı, `<html lang="tr">` ile tutarsızdı). Bu iki alan zaten olması gereken düzeltmelerdi ama kullanıcıya AÇIKÇA belirtilen sınır şu: **gerçek çözüm o cihazda Chrome/Android System WebView'i Play Store'dan güncellemek** — bu, aynı uyarının başka sitelerde de yaşandığı, yaygın raporlanan bir Chrome/WebAPK altyapı davranışı, Kelimeki'ye özgü değil.


## 31 Ağustos 2026 — Yeni statik sayfa eklendi, denylist güncellenmedi

Kullanıcı `/nasil-oynanir/` yayına girdikten sonra bildirdi: *"Önce setup
sayfası geliyor, birkaç saniye (3-4 belki 5 sn) sonra [kurallar sayfası]
geliyor."*

**Ne olduğu — zincir:** tarayıcısında ESKİ service worker kuruluydu (sayfa
daha var olmadan kurulmuş). O SW'nin precache manifest'inde
`nasil-oynanir/index.html` YOK ve `navigateFallbackDenylist`inde de yok →
gezinme `navigateFallback: index.html`e düşüyor, yani **uygulama kabuğu →
Setup ekranı**. Ardından `setupPwaUpdates()` (`src/lib/pwa.ts`,
`immediate: true`) yeni SW'yi buluyor; kullanıcı o an oyunda olmadığı için
`updateSW(true)` çalışıp sayfayı yeniliyor; yeni SW artık sayfayı precache
ediyor ve doğru içerik geliyor. **3-5 saniye tam olarak SW kurulum +
etkinleşme + reload süresi.** Yani gördüğü şey mevcut kullanıcılar için
TEK SEFERLİK bir geçiş; ikinci ziyarette doğru sayfa anında geliyor.

**Asıl hata ise kalıcıydı ve benimdi:** `vite.config.ts`teki denylist ELLE
yazılmış üç girdi taşıyordu ve dördüncü sayfa eklenirken güncellenmedi.
Bunun sonucu, denylist'in var oluş sebebi olan hatanın aynısı: eğik
çizgisiz `/nasil-oynanir` precache rotasına takılmaz (`directoryIndex`
yalnızca `/` ile biten adresi `index.html`e çevirir), NavigationRoute'a
düşer ve SW kurulu her tarayıcıda SÜREKLİ uygulama kabuğu döner. Aynı şey
`/gizlilik` için 2026'nın başında zaten ÖLÇÜLMÜŞTÜ — o ölçüm dosyanın
yorumunda yazılıydı ve yine de tekrarlandı.

**Ölçüm — sunucu tarafı SUÇLU DEĞİL.** Canlıdan `WebFetch` ile
`https://kelimeki.com/nasil-oynanir` (eğik çizgisiz) ve
`https://kelimeki.com/gizlilik` çekildi: ikisi de DOĞRU statik sayfayı
döndürüyor. `WebFetch` service worker çalıştırmadığından bu, sorunun
tamamen istemci tarafındaki SW'de olduğunu gösteriyor. `vite preview`
üzerinden yapılan ilk deneme yanıltıcıydı: orada `controller: null` çıktı
(SW `registerType: 'prompt'` ile `clientsClaim` YAPMIYOR, ilk yüklemede
sayfayı kontrol etmiyor), yani ölçülen şey preview sunucusunun kendi SPA
fallback'iydi — SW davranışı değil. **Ders: bir SW ölçümünde önce
`navigator.serviceWorker.controller`ı doğrula; null ise ölçtüğün şey SW
değildir.**

**Düzeltme — kural değil MEKANİZMA.** Liste artık elle tutulmuyor:
`scripts/static-pages.js` tek kaynak. `STATIC_PAGE_PATHS` hem `Sayfa.yol`un
birleşim tipini (`render.tsx`) hem `staticPageDenylist()`i
(`vite.config.ts`) besliyor. Yeni bir sayfa listeye girmeden `render.tsx`
DERLENMİYOR ve denylist kendiliğinden büyüyor. Negatif eş: beşinci bir
sayfa listeye eklenmeden tanımlanınca `tsc` TS2322 ile düşüyor
(`Type '"/sahte/"' is not assignable to ...`). Üretilen `dist/sw.js`te
denylist artık dört desen taşıyor.

⚠ **İLK DENEME CI'da DÜŞTÜ — kaydı burada.** Dosya önce `src/legal/paths.ts`
olarak konup `tsconfig.node.json`un `include`ına eklendi (`vite.config.ts`
ayrı bir composite proje ve onu aksi halde import edemiyor: TS6307). Ama o
zaman dosya İKİ composite projeye birden girdi — `tsconfig.json` zaten
`src`i kapsıyor — ve temiz bir checkout'ta:

    error TS6305: Output file '.../tsc-node/src/legal/paths.d.ts' has not
    been built from source file 'src/legal/paths.ts'.

**Yerelde GÖRÜNMÜYORDU** çünkü önceki bir derlemeden kalan `.d.ts` duruyordu.
Düşen adım `npm run build` değil `npm run lint`: `tsc --noEmit` referans
projeleri İNŞA ETMEZ, yani `.d.ts` hiç oluşmaz. `tsc -b` ise onu ürettiği
için build iki hâlde de geçiyordu — reprodüksiyonu ilk denemede tam bu
yüzden ıskaladım.

**Çözüm repo'nun kendi kalıbı:** `scripts/` altındaki Vite eklentileri
(`landing-plugin`, `legal-plugin`) düz `.js` + elle yazılmış `.d.ts` olarak
duruyor ve hiçbir TS programının parçası değil. Tek kaynak da oraya taşındı
(`scripts/static-pages.js` + `.d.ts`). `render.tsx` yalnızca TİPİ import
ediyor (`import { type StaticPagePath }`), yani çalışma zamanında bağ yok.

⚠ **Ölçüm sırasında ikinci bir tuzak bulundu:** `npm run build` =
`tsc -b && vite build` ve `tsc -b` KÖKE `vite.config.js` üretiyor
(composite, `outDir` yok). Vite ise config ararken `.js`i `.ts`ten ÖNCE
deniyor — yani `vite build` çoğu zaman `vite.config.ts`i değil `tsc`nin
ürettiği JS'i yüklüyor. Dosya `.gitignore`da olduğundan `git stash` da
temizlemiyor ve dallar arası geçişte BAYAT kalıyor; bir ölçüm bu yüzden
yanlış hata verdi. Yerelde dal değiştirip derleme davranışı ölçerken
`vite.config.js`/`.d.ts` ve `node_modules/.cache` ELLE silinmeli.

**Ölçüm yöntemi (tekrarlanabilir):** önbelleği sil → `npm run lint`.
Bozuk hâlde TS6305, düzeltilmiş hâlde temiz — ikisi de koşuldu.

## Yeniden yükleme döngüsü — ana ekrandan açılan iOS PWA'sı (19 Eylül 2026)

Kullanıcı bildirdi: *"Web'i açınca sürekli her şey yüklemeye çalışıyor, ekran
deli gibi hareket ediyor, bir türlü durmuyor."* Sonra: *"Aç kapa yapınca loop
yaptı, kapatıp açtım düzeldi, tekrar açınca yine yaptı."* Ve teşhisi açan tek
cümle: ***"Bunu 'add to home screen' ikonuyla yapıyorum."***

### Mekanik

```
pageshow → checkForUpdate() → registration.update()
         → bekleyen SW hâlâ orada → onNeedRefresh() → updateSW(true)
         → skipWaiting → controllerchange → location.reload()
         → pageshow → (baştan)
```

`pwa.ts`in tek koruması `applyUpdate = null` idi ve o **yalnızca tek bir
sayfa ömrü içinde** çalışıyor; `reload` o ömrü bitirdiği için döngüyü hiç
görmüyordu. Bekleyen service worker bir sebeple etkinleşemezse (iOS
standalone'da `skipWaiting`/`controllerchange` zinciri güvenilmez) döngü
sonsuz: yalnızca uygulamayı tamamen kapatmak kırıyor.

### Neden üç tur boyunca yanlış yerde arandı

Sunucudan görünen şey "oturum saniyede iki kez `null`a düşüyor"du ve bu bir
BELİRTİYDİ: sayfa her seferinde sıfırdan açılıyordu. Auth katmanında üç ayrı
düzeltme yayına çıktı (`sameAuthUser` · olay adı filtresi · depo
doğrulaması), üçü de döngüyü durdurmadı.

⚠ **"Sayfa yenileniyor" hipotezi bir kez YANLIŞ gerekçeyle elendi:** *"bir
iPhone saniyede iki kez 400 KB paketi indirip React'i kuramaz"*. Doğru
görünüyordu ve yanlıştı — **ana ekrandan açılan bir PWA'da HTML/JS/font
tamamen service worker ÖNBELLEĞİNDEN gelir, ağdan hiçbir şey inmez.**
Saniyede iki açılış o koşulda gayet mümkün.

**İki ders, ikisi de genel:**

1. **Bir hipotezi elerken gerekçenin KENDİSİNİ de sına.** Yanlış gerekçeyle
   elenen doğru hipotez geri gelir — burada üç tur kaybettirdi.
2. **Yüzeyi sor.** "Web'i açıyorum" ile "ana ekran ikonuyla açıyorum" iki
   ayrı çalışma ortamı (önbellek, service worker, storage, yaşam döngüsü).
   Bir tarayıcı hatasında **hangi yüzey** sorusu, tarayıcı/sürüm sorusu kadar
   erken sorulmalı.

### Kural

**Bir uygulama oturumunda güncelleme en fazla BİR KEZ uygulanır**; ikinci
deneme yalnızca derleme kimliği gerçekten değiştiyse serbest. Kayıt
`sessionStorage`da tutuluyor: yeniden yüklemeleri aşar, uygulamayı kapatıp
açmak sıfırlar — yani gerçek bir güncelleme bir sonraki açılışta normal
şekilde uygulanır, kalıcı olarak bloklanmaz.

Kapı `npm run verify-sw-update-loop` (CI'da): saf fonksiyonun dört durumu +
`pwa.ts`in kapıyı gerçekten çağırdığının ve kaydı `apply()`den ÖNCE
yazdığının kaynak taraması.

Güncelleme tutmazsa `client_errors`'a `sw-update-loop` bağlamıyla tek satır
düşüyor — kullanıcı eski sürümde kalıyor demektir, birinin bakması gerekir.

### İkinci ölçüm — kapı çalıştı, ama deneme AÇILIŞ başınaydı (aynı gün)

Düzeltme yayına çıktı (`d7816d7`) ve `client_errors` ÜÇ satır yazdı —
14:09:28 · 14:09:40 · 14:10:19, üçü de:

```
[sw-update-loop] service worker güncellemesi TUTMADI — derleme d7816d7 değişmedi, döngü kesildi
```

**Bu üç satır iki şeyi birden kanıtladı:** (1) teşhis doğru — bekleyen
service worker gerçekten etkinleşemiyor; (2) kapı çalışıyor — sonsuz döngü
kırıldı. Ama kayıt `sessionStorage`daydı, yani **her açılış bir boş yeniden
yükleme harcıyordu**. Kullanıcı bunu *"sanki her seferinde 2 kere refresh
yapıyor"* diye tarif etti: ilk açılış + bir reload.

⚠ **Bu turda bir ölçüm aracı bedavaya çıktı:** aynı PR `fetchMyProfile`'ın
`getUser()` çağrısını kaldırdığı için, edge loglarında **`/auth/v1/user` = 0
olması artık "kullanıcı yeni derlemede" demek.** Sunucudan derleme
tespitinin en ucuz yolu; yeni bir sürümün sahaya inip inmediği bundan
okunabiliyor.

**Değişiklik:** kayıt `localStorage`a alındı → deneme **derleme başına bir**.
Bir kez denenir, tutmazsa o derleme için bir daha denenmez. Güncelleme
kaybolmuyor: bekleyen worker, tüm istemciler kapanınca normal yaşam
döngüsüyle kendiliğinden etkinleşir — biz yalnızca onu ZORLAMAYI bırakıyoruz.
Derleme gerçekten değiştiği an kayıt eskiyor ve kapı kendiliğinden yeniden
kuruluyor.

⚠ Bedeli bilinçli: bir güncelleme geçici bir sebeple tutmazsa o derleme için
otomatik yeniden deneme yok.

**Ayrıca `registration.update()` kısıldı (5 dk).** iOS standalone'da
`visibilitychange` + `focus` + `pageshow` her uygulama geçişinde ÜÇÜ BİRDEN
ateşliyor, yani her geçiş üç ayrı `sw.js` çekimi demekti. Saatlik tetikleyici
duruyor ve 5 dakikadan uzun her dönüş yine kontrol ediyor.

⚠ **Hâlâ BİLİNMEYEN:** bekleyen worker'ın neden etkinleşmediği. Üretilen
`sw.js`te `SKIP_WAITING` dinleyicisi ve `skipWaiting()` var, ama
`clientsClaim` YOK (vite-plugin-pwa'nın `prompt` modundaki varsayılanı).
Dağıtım karışması elendi: canlıdaki `index.html`in yüklediği iki paket de
(`boot-*.js`, `index-*.js`) aynı `sw.js`in precache manifest'inde duruyor,
yani HTML ile service worker AYNI dağıtımdan geliyor. Bu soru açık; ama
artık kullanıcıya bir maliyeti yok.

### Üçüncü ölçüm — telemetri AÇILIŞ başına yazıyordu (aynı gün)

`localStorage`a geçildikten sonra yeniden yükleme derleme başına bire indi,
**ama telemetri inmedi.** Canlıda görüldü: kapı her açılışta yeniden
değerlendiğinden `client_errors`'a her açılış bir satır düşüyordu (aynı
derleme `ae9b247` için art arda kayıtlar).

Kaydın İLK yazılması değerli — "bekleyen worker etkinleşemiyor, kullanıcı
eski sürümde kalıyor, birinin bakması gerekir". Tekrarı gürültü, ve
`errorReporting.ts`in kendi kuralını çiğniyor: *"bir kayıt 'birinin bakması
gereken bir şey' demek olmalı; gürültü sinyali boğarsa panel bir daha
açılmaz."*

⚠ **`reportClientError`in kendi tekilleştirmesi burada YETMEZ** — o pencere
sayfa ömrüyle sınırlı, bu arıza ise her AÇILIŞTA yeniden doğuyor. Bu yüzden
işaret kalıcı kayda kondu: `SwUpdateKaydi.reported`. Telemetri artık
**derleme başına bir**; derleme değişince kayıt tazelenir ve yeni bir arıza
yine bir kez bildirilir.

Kapı üç yeni kontrolle genişledi (kayıt yok → bildirme · ilk bastırma →
bildir · aynı derleme ikinci kez → bildirme) + çağrı yeri taraması: işaret
rapordan ÖNCE konmalı. Duyarlılığı düzeltme geri alınarak kanıtlandı.

**Ders:** bir "sessize alma" mekanizması eklerken sessize alınan ŞEYİ de say.
Yeniden yükleme susturuldu, telemetri susturulmadı — ikisi aynı kapıdan
geçiyor görünüyordu ama ömürleri farklıydı (biri sayfa, öteki cihaz).
