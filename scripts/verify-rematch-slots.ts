// Kelimeki — `src/utils/rematchSlots.ts`in saf kadro kuralını ÜRETİM kodunu
// import ederek doğrular. Port ikizi `rematchSlots` (online_games_api.dart),
// vakaları `mobile/app/test/rematch_slots_test.dart` — AYNI vakalar.
//
// NEDEN AYRI BİR BETİK: web'de birim test çatısı yok (`npm run test`
// Playwright). `verify-game-list-order` ile aynı desen.
//
// NEDEN ÖNEMLİ: bu sıralama kozmetik DEĞİL, `create_online_game`in üç
// kısıtının karşılığı — ilk koltuk çağıran, YZ'ler sonda. Kural sessizce
// bozulursa RPC reddeder ve hata ancak "Tekrar Oyna çalışmıyor" olarak,
// kullanıcıda görünür. 4 Eylül 2026'da ikinci bir çağıran doğduğu için
// (oyun geçmişindeki "Tekrar Oyna") ortak dosyaya çıkarıldı; bu betik
// iki yüzeyin de aynı kuralı kullandığını değil, KURALIN kendisini korur.
//
// Koşum: npm run verify-rematch-slots
import {
  buildRematchPlan,
  buildRematchSlots,
  rematchBlockedMessage,
  rematchBlockedOpponents,
  rematchConfirmText,
  rematchHasAi,
  rematchOpponentNames,
  rematchSentNotice,
} from '../src/utils/rematchSlots';
import type { OnlineGameSlot } from '../src/lib/database.types';

let failures = 0;
function check(name: string, cond: boolean, detail = ''): void {
  if (cond) console.log(`  ✓ ${name}`);
  else {
    failures++;
    console.log(`  ✗ ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

const human = (id: string, name?: string): OnlineGameSlot =>
  name === undefined ? { type: 'human', user_id: id } : { type: 'human', user_id: id, name };
const ai = (): OnlineGameSlot => ({ type: 'ai' });
const özet = (slots: OnlineGameSlot[]) =>
  slots.map((s) => (s.type === 'ai' ? 'YZ' : s.type === 'open' ? 'açık' : s.user_id)).join(',');

console.log('Rövanş kadrosu — kural kontrolleri\n');

// (1) İlk koltuk HER ZAMAN çağıran — biten oyunu ben kurmamış olsam bile.
check(
  'kuran bensem sıra korunur',
  özet(buildRematchSlots([human('ben'), human('rakip')], 'ben')) === 'ben,rakip',
);
check(
  'kuran BEN DEĞİLSEM kendimi başa alırım',
  özet(buildRematchSlots([human('rakip'), human('ben')], 'ben')) === 'ben,rakip',
  özet(buildRematchSlots([human('rakip'), human('ben')], 'ben')),
);

// (2) 4 kişilikte YZ yalnız SON koltukta olabilir.
check(
  'YZ ortadayken sona taşınır, insanların sırası korunur',
  özet(buildRematchSlots([human('a'), ai(), human('ben'), human('b')], 'ben')) ===
    'ben,a,b,YZ',
  özet(buildRematchSlots([human('a'), ai(), human('ben'), human('b')], 'ben')),
);
check(
  'iki YZ de sonda ve SAYISI korunur',
  özet(buildRematchSlots([ai(), human('ben'), ai(), human('a')], 'ben')) === 'ben,a,YZ,YZ',
);

// (3) Koltuk sayısı hiçbir koşulda değişmez — RPC oyuncu sayısını ayrıca
// alıyor, kadro ondan kısa/uzun gelirse sessizce reddedilir.
for (const [ad, slots] of [
  ['2 kişilik', [human('ben'), human('a')]],
  ['4 kişilik insan', [human('ben'), human('a'), human('b'), human('c')]],
  ['4 kişilik YZ karışık', [human('ben'), human('a'), ai(), ai()]],
] as [string, OnlineGameSlot[]][]) {
  check(`${ad}: koltuk sayısı korunur`, buildRematchSlots(slots, 'ben').length === slots.length);
}

// (4) RPC'ye YALNIZCA type + user_id gider — görüntü alanları sızmaz.
const kirli = buildRematchSlots([human('ben', 'Ben'), human('a', 'Ali')], 'ben');
check(
  'name/avatar gibi görüntü alanları RPC yüküne sızmaz',
  kirli.every((s) => Object.keys(s).sort().join(',') === (s.type === 'ai' ? 'type' : 'type,user_id')),
  JSON.stringify(kirli),
);

// (5) Yardımcılar — onay metninin girdileri.
check(
  'rakip adları: kendim hariç, adsız koltuk için yer tutucu',
  rematchOpponentNames([human('ben', 'Ben'), human('a', 'Ali'), human('b')], 'ben').join('|') ===
    'Ali|Bir arkadaşın',
);
check('YZ var mı — yok', rematchHasAi([human('ben'), human('a')]) === false);
check('YZ var mı — var', rematchHasAi([human('ben'), ai()]) === true);

// (6) Engellediğim rakip (13 Ekim 2026, kullanıcı kararı): oyun KURULMAZ, önce
// engel kaldırılır. Engelli listesi `fetchBlockedUsers()` çıktısıdır; yalnızca
// `userId`/`name` okunur. Dart ikizi `rematch_slots_test.dart` AYNI vakalarla.
const engelli = (...ids: string[]) => ids.map((id) => ({ userId: id, name: id.toUpperCase() }));
check(
  'engelli rakip yok → boş',
  rematchBlockedOpponents([human('ben'), human('a')], 'ben', []).length === 0,
);
check(
  '2 kişilik: engellediğim rakip → adı döner',
  rematchBlockedOpponents([human('ben'), human('a')], 'ben', engelli('a')).join('|') === 'A',
);
check(
  'kendim engelli listesinde olsam da sayılmam',
  rematchBlockedOpponents([human('ben'), human('a')], 'ben', engelli('ben')).length === 0,
);
check(
  'kadroda OLMAYAN engelli sayılmaz',
  rematchBlockedOpponents([human('ben'), human('a')], 'ben', engelli('z')).length === 0,
);
check(
  '4 kişilik: iki engelli, KOLTUK sırasıyla (listenin sırasıyla değil)',
  rematchBlockedOpponents(
    [human('ben'), human('c'), human('a'), human('b')],
    'ben',
    engelli('a', 'c'),
  ).join('|') === 'C|A',
);
check(
  'YZ koltuğu engelli sayılmaz',
  rematchBlockedOpponents([human('ben'), human('a'), ai(), ai()], 'ben', engelli('a')).join('|') ===
    'A',
);

// (7) Mesaj — tekil / çoğul / üçlü; "engeli kaldırmanız" yönlendirmesi sabit.
check(
  'mesaj tekil',
  rematchBlockedMessage(['Ali']) ===
    'Ali kullanıcısını engellediğiniz için önce engeli kaldırmanız gerekiyor.',
  rematchBlockedMessage(['Ali']),
);
check(
  'mesaj iki kişi',
  rematchBlockedMessage(['Ali', 'Veli']) ===
    'Ali ve Veli kullanıcılarını engellediğiniz için önce engeli kaldırmanız gerekiyor.',
);
check(
  'mesaj üç kişi',
  rematchBlockedMessage(['Ali', 'Veli', 'Can']) ===
    'Ali, Veli ve Can kullanıcılarını engellediğiniz için önce engeli kaldırmanız gerekiyor.',
);

// (8) Yabancılı rövanş planı (S2, 13 Ekim 2026): arkadaş olmayan insan rakip
// → AÇIK (rastgele) koltuk, arkadaşlar davetli, YZ yalnızca eski oyunda varsa
// SONDA (sunucu: `create_random_game`, 4 kişilikte son koltuk). Dart ikizi
// `rematch_slots_test.dart` AYNI vakalarla.
const dost = (...pairs: [string, string][]) => new Map<string, string>(pairs);
{
  const hepsi = buildRematchPlan([human('ben'), human('a', 'Ali')], 'ben', dost(['a', 'Ali']));
  check('hepsi arkadaş → bugünkü akış (friends)', hepsi.kind === 'friends' && özet(hepsi.slots) === 'ben,a');
  const okunamadi = buildRematchPlan([human('ben'), human('a', 'Ali')], 'ben', null);
  check(
    'arkadaş listesi OKUNAMADI (null) → bugünkü akış, "hiç arkadaşım yok" SANILMAZ',
    okunamadi.kind === 'friends' && özet(okunamadi.slots) === 'ben,a' && okunamadi.openCount === 0,
  );
  const bos = buildRematchPlan([human('ben'), human('a')], 'ben', dost());
  check('listeden OKUNAN boş arkadaş kümesi → rakip yabancı sayılır', bos.kind === 'random');

  const dortlu = buildRematchPlan(
    [human('ben'), human('f', 'Fatma'), human('s1'), human('s2')],
    'ben',
    dost(['f', 'Fatma']),
  );
  check(
    '4 kişi: ben+F+S1+S2 → ben,F,açık,açık',
    dortlu.kind === 'random' &&
      özet(dortlu.slots) === 'ben,f,açık,açık' &&
      dortlu.openCount === 2 &&
      dortlu.friendNames.join('|') === 'Fatma',
    özet(dortlu.slots),
  );
  const yzli = buildRematchPlan(
    [human('ben'), human('f'), human('s'), ai()],
    'ben',
    dost(['f', 'Fatma']),
  );
  check('4 kişi: ben+F+S+YZ → ben,F,açık,YZ (YZ SONDA, eskiden vardı)', özet(yzli.slots) === 'ben,f,açık,YZ', özet(yzli.slots));
  const yzsiz = buildRematchPlan([human('ben'), human('a'), human('b'), human('c')], 'ben', dost());
  check(
    'YZ kendiliğinden EKLENMEZ (eski oyunda yoksa)',
    özet(yzsiz.slots) === 'ben,açık,açık,açık' && !yzsiz.slots.some((x) => x.type === 'ai'),
    özet(yzsiz.slots),
  );
  const ikili = buildRematchPlan([human('ben'), human('s')], 'ben', dost());
  check(
    '2 kişi: ben+S → ben,açık',
    ikili.kind === 'random' && özet(ikili.slots) === 'ben,açık' && ikili.friendNames.length === 0,
  );
  const sirali = buildRematchPlan([human('s'), human('ben'), human('f')], 'ben', dost(['f', 'F']));
  check('kuran ben DEĞİLSEM kendimi başa alırım (random planında da)', özet(sirali.slots) === 'ben,f,açık', özet(sirali.slots));
  const ad = buildRematchPlan([human('ben'), human('a', 'KoltukAdı')], 'ben', dost(['a', 'ListeAdı']));
  check('friends planında ad önceliği: arkadaş listesi > koltuk adı', ad.friendNames.join('|') === 'ListeAdı');
  const adsiz = buildRematchPlan([human('ben'), human('a')], 'ben', null);
  check('adı hiçbir yerde olmayan koltuk için yer tutucu', adsiz.friendNames.join('|') === 'Bir arkadaşın');
}

// (9) Onay + sonuç metinleri — 'friends' planı bugünkü cümleyle BİREBİR aynı.
{
  const f = buildRematchPlan([human('ben'), human('a', 'Ali')], 'ben', dost(['a', 'Ali']));
  check(
    'onay metni (friends) bugünküyle birebir',
    rematchConfirmText(f, false) ===
      'Ali ile aynı kadroda yeni bir oyun açılacak ve davet gönderilecek. Emin misin?',
  );
  check(
    'onay metni (friends + YZ)',
    rematchConfirmText(f, true) ===
      'Ali ile aynı kadroda yeni bir oyun açılacak ve davet gönderilecek. 4. koltuk yine Yapay Zeka olacak. Emin misin?',
  );
  const r1 = buildRematchPlan([human('ben'), human('f'), human('s1'), human('s2')], 'ben', dost(['f', 'Fatma']));
  check(
    'onay metni (random, arkadaş + 2 yabancı)',
    rematchConfirmText(r1, false) ===
      'Fatma davet edilecek; arkadaşınız olmayan oyuncuların yerine 2 rastgele oyuncu aranacak. Emin misin?',
    rematchConfirmText(r1, false),
  );
  const r2 = buildRematchPlan([human('ben'), human('s')], 'ben', dost());
  check(
    'onay metni (random, tek yabancı, arkadaşsız)',
    rematchConfirmText(r2, false) ===
      'Arkadaşınız olmayan oyuncunun yerine rastgele bir oyuncu aranacak. Emin misin?',
    rematchConfirmText(r2, false),
  );
  const r3 = buildRematchPlan([human('ben'), human('f'), human('s'), ai()], 'ben', dost(['f', 'Fatma']));
  check(
    'onay metni (random + YZ)',
    rematchConfirmText(r3, true) ===
      'Fatma davet edilecek; arkadaşınız olmayan oyuncunun yerine rastgele bir oyuncu aranacak. 4. koltuk yine Yapay Zeka olacak. Emin misin?',
  );
  check(
    'sonuç: yeni ilan + davet notu',
    rematchSentNotice(r1, { joined: false, started: false }).body.endsWith(' Fatma davet edildi.'),
  );
  check(
    'sonuç: yeni ilan, arkadaşsız → ek not YOK',
    rematchSentNotice(r2, { joined: false, started: false }).title === 'İlanın yayında' &&
      !rematchSentNotice(r2, { joined: false, started: false }).body.includes('davet edildi'),
  );
  check(
    'sonuç: var olan ilana KATILDI → ayrı başlık, davet notu YOK',
    rematchSentNotice(r2, { joined: true, started: false }).title === 'Oyuna katıldın',
  );
}

console.log(failures === 0 ? '\nTümü geçti.' : `\n${failures} kontrol DÜŞTÜ.`);
process.exit(failures === 0 ? 0 : 1);
