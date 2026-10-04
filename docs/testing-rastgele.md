# Elle test — Rastgele Oyuncu

> `TESTING.md` §13.10'un gövdesi (3 Ekim 2026). Bölüm numarası korundu.

## 13.10 Rastgele Oyuncu — açık ilan (3 Ekim 2026)

İki gerçek hesap (T1, T2; üçüncü bir T3 eşzamanlı kabul için çok iyi olur) ve
bir de ESKİ sürümlü istemci (mağazadaki 1.1.0 ya da cache'lenmiş eski web) ister.
Tasarım ve sunucu sonuçları: `docs/decisions/random-opponent.md`. Otomatik kapı
yalnızca saf kuralları sınar: `npm run verify-random-games`.

**13.10.1 İlan aç — kurulum ekranı**
- [ ] Canlı → Yeni Oyun Başlat: listenin EN ÜSTÜNDE "?" avatarlı "Rastgele Oyuncu" satırı, alt yazı "Açık oyun başlatır. Oyuna herkes katılabilir.". Satıra tekrar tekrar dokun: her dokunuş bir "?" koltuğu ekler; boş koltuk kalmayınca (2 kişide 1., 4 kişide ×3'ten sonra) bir sonraki dokunuş TÜM "?"leri GERİ ALIR. Arama kutusuna bir şey yaz: satır KAYBOLMAZ. "Tüm oyuncular" görünümünde ve hiç arkadaşı olmayan hesapta da görünür.
- [ ] 2 kişi: satıra dokun → 2. koltuk "?" ("Rastgele oyuncu") olur; tekrar dokun → değişmez (tek rakip). Bir arkadaşa dokun → "?" yerine arkadaş geçer.
- [ ] 4 kişi: her dokunuş bir boş koltuğu "?" yapar (en çok 3, satırda ×N). Arkadaş + "?" karışabilir. Tek seçimde "Davet Gönder" kapalı; tam 2 seçimde 4. koltuk "Yapay Zeka" görünür; 3 seçimde YZ yok.
- [ ] "?" koltuk kartına dokun → seçim kalkar.
- [ ] HİÇ "?" yokken akış bugünküyle AYNI (`create_online_game`, "Davetin gönderildi" ekranı).

**13.10.2 İlan — sonuç ekranı ve şerit (T1 aç, T2 gör)**
- [ ] T1 yalnızca "?" ile 2 kişilik ilan açar → "İlanın yayında. Biri kabul edince oyun başlar. 7 gün içinde dolmazsa kendiliğinden kalkar, ceza yok."
- [ ] T1'in Devam Edenler'inde "Bekliyor 1/2" satırı: avatar + kesik çerçeveli "?", "Rastgele oyuncu bekleniyor", "İlanı iptal et". Oyun Davetleri sekmesinde AYNI oyun GÖRÜNMEZ (dört kova).
- [ ] T2'nin Devam Edenler'inde, Devam Eden Oyunlar'ın ÜSTÜNDE "Rastgele Oyunlar · N" şeridi: T1 avatarı + ad, "2 kişi", koltuk noktaları, "1 koltuk kaldı" (saat/gün YOK), Kabul. T1'in KENDİ ilanı T1'in şeridinde de VAR (§15): en başta, "Kabul" yerine soluk "Bekliyor" etiketi + "İptal" (kabul ettiğim ilanda "Ayrıl"); "İptal" kartı kaldırır, ceza yok. Yalnızca benim ilanım varken şerit görünür; başlık sayısı onu da sayar; ilan Devam Edenler'deki "Bekliyor n/N" satırıyla yinelenir (kabul edildi).
- [ ] Hiç ilan yokken şerit TAMAMEN gizli (başlık da yok); "Yeni Oyun Başlat" kalır.
- [ ] Şerit yatay kayar (320 px'te ~3 kart, dördüncünün kenarı görünür); sayfa yatay taşmaz. Başlığın sağındaki "Rastgele oyun aç" kurulum ekranını açar.
- [ ] Şerit yoklaması (Realtime YOK, RLS): T2 şeride bakarken T1 yeni ilan açar → en geç ~40 sn içinde belirir; sekme arka plandayken istek ATILMAZ (ağ sekmesinden bak), öne dönünce bir kez yoklar.

**13.10.3 Kabul / ayrıl / iptal**
- [ ] T2 "Kabul": onay sorulmaz. 2 kişilikte "Kabul ettin. Oyun başladı." ve oyun Devam Edenler'de normal oyun (sıra T1'de); 4 kişilikte "Kabul ettin. Diğer oyuncular bekleniyor." + T2'de "Bekliyor 2/4" ve "Ayrıl". T1 tarafında koltuk dolar (Realtime ya da öne dönüş).
- [ ] T2 "Ayrıl" → koltuk yeniden açılır, ilan şeride geri döner, ceza YOK (k-lig puanına bak). T1 "İlanı iptal et" → satır ve şerit kartı kalkar.
- [ ] ESZAMANLI KABUL: T2 ve T3 aynı ilanda aynı anda Kabul → biri kazanır, öteki "Bu oyun doldu." benzeri sunucu metnini görür (ham hata YOK), şerit tazelenir.
- [ ] 3 SINIRI: T1 eşzamanlı 3 rastgele (açtığı + kabul edip beklediği) oyunla dördüncüyü açar/kabul eder → sunucunun Türkçe reddi ekranda (ham `err.message` değil).
- [ ] "ÖNCE BİR OYUN BİTİR" KAPISI: hiç bitmiş oyunu olmayan yeni hesap ilan açar/kabul eder → sunucu reddi gösterilir.
- [ ] Uygun ilan varken T3 yalnızca "?" kadrosuyla aynı boyutta ilan açar → yeni ilan AÇILMAZ, mevcut ilana katılır ("Uygun bir ilan vardı, ona katıldın.").
- [ ] 7 gün dolumu (hızlandırılmış: SQL'de `expires_at`ı geçmişe çek): sekme açılınca `check_invite_expiry` tetiklenir, ilan ve "Bekliyor" satırı kalkar.

**13.10.4 Karma kadro**
- [ ] T1: arkadaş T2 + "?" + (4 kişi) YZ. T2'nin Oyun Davetleri sekmesinde bugünkü davet kartı: "?" satırı "Rastgele oyuncu bekleniyor", "Yapay Zeka" satırı yalnızca GERÇEK YZ koltuğu için. T2 kabul edince oyun BAŞLAMAZ (açık koltuk var); yabancı da oturunca başlar.
- [ ] T2 reddederse ilan (oturmuş yabancıyla birlikte) kapanır (bugünkü ret kuralı).

**13.10.5 ESKİ istemci maskesi** (eski web/port)
- [ ] Eski sürümlü T2, karma kadroda arkadaş olarak çağrılır → açık koltuğu "Yapay Zeka" sanır (BİLİNEN bedel), ama daveti görür ve kabul edebilir.
- [ ] YENİ web aynı oyunda açık koltuğu "?" çizer, "Yapay Zeka" YAZMAZ.

**13.10.6 Rozetler DEĞİŞMEZ**
- [ ] Yalnızca ilan açık/bekleyen T1'de: "Arkadaşınla" rozeti, "Devam Edenler"/"Oyun Davetleri" sekme rozetleri ve uygulama ikonu rozeti ARTMAZ; girişte Canlı sekmesi ZORLANMAZ. Kabul edip bekleyen T2'de de aynı.
- [ ] Karma kadroda arkadaşın bekleyen daveti bugünkü gibi rozete SAYILIR.
- [ ] Oyun dolup başlayınca ve sıra çağıranda olunca normal oyun gibi sayılır.

**13.10.7 Yan etkiler**
- [ ] Gizlilik/Kullanım Koşulları metninde Rastgele Oyuncu maddesi var (pencere + `/gizlilik/`, `/kullanim-kosullari/`).
- [ ] Yabancıyla biten oyunda "Tekrar Oyna" (rövanş): sunucu "Yalnızca arkadaşlarını davet edebilirsin" diyebilir — davranışı not et (karar bekliyor, `random-opponent.md` §7).

## Bilinçle ATLANAN test: 48 saat zaman aşımı (4 Ekim 2026, kullanıcı kararı)

Rastgele ilanla başlayan oyunda zaman aşımı **normal Canlı oyunla birebir aynıdır** (`check_turn_timeout` `listing`
kolonuna HİÇ bakmaz; ara bir değişiklik aynı gün geri alındı, bkz. `random-opponent.md` §16). Yani teslim/−2/+2 mantığı bu
özellikle değişmedi ve burada ayrıca test EDİLMEZ; normal Canlı oyun testleri (`TESTING.md`) kapsar. Bu yüzden listede bir
"süreyi geçmişe al" adımı YOK.
