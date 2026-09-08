// Kelimeki — "Oynayarak öğren" tanıtımı (7 Eylül 2026, kullanıcı isteği)
//
// NEDEN AYRI BİR EKRAN: tanıtım GERÇEK motorla oynanır (`gameReducer`) ama
// App'in oyun durumuna HİÇ dokunmaz — kendi `useReducer`'ı var. Kazanılan
// şey yalıtım: App'in otomatik kayıt / bulut kaydı / telemetri / k-lig
// effect'lerinin hiçbiri bu ekranda çalışmaz, yani tanıtım bir "oyun" olarak
// sayılmaz (huniye girmez, istatistik kirletmez, terk-edilme cezası
// üretmez). Motora ise tek bir action bile eklenmedi — bu depoda motorun
// DÖRT kopyası var (src, Dart portu, Edge `_game/`, SQL aynası) ve tanıtım
// bir UI işidir, motor işi değil (bkz. `src/utils/tutorialScript.ts`).
//
// ⚠ ETKİLEŞİM MODELİ CİHAZ TESTİNDEN SONRA DEĞİŞTİ (7 Eylül 2026, kullanıcı):
// *"Ekrana dokunup taşların gelmesi gerçekçi değil. Rafta taşıması gereken
// taşları yanyana koy ve highlight et, ayrıca oraya balon koyup 'şimdi BÜYÜ
// kelimesini taşı' yaz."* İlk sürümde işaretli kareye dokunmak doğru harfi
// raftan KENDİLİĞİNDEN getiriyordu — hızlıydı ama oyuncu gerçek oyundaki
// jesti hiç öğrenmiyordu. Artık taş elle alınıyor:
//   • raftaki harfe dokun → seçilir, sonra işaretli kareye dokun, VEYA
//   • harfi işaretli kareye sürükle (gerçek oyundaki jestin aynısı).
// Boş kareye dokunmak tek başına HİÇBİR ŞEY yapmaz.
//
// RAYLAR: yalnızca o sahnenin harfleri seçilebilir/sürüklenebilir ve yalnızca
// o sahnenin kareleri taş kabul eder. Yanlış kare sessizce reddedilir —
// tanıtımda "yanlış yaptım" duygusu olmamalı. Konan taşa dokunmak geri alır.
import { useEffect, useMemo, useReducer, useRef, useState } from 'react';
import { PLAYER_COLORS } from '../game/constants';
import { gameReducer } from '../game/gameReducer';
import type { Tile as TileModel } from '../game/types';
import { getFormedWords, key } from '../utils/board';
import { calcScore, validatePlacement } from '../utils/validator';
import { isFirstMove } from '../game/gameReducer';
import { swallowNextClick } from '../utils/ghostClick';
import {
  GHOST_TILE_STYLE,
  TAP_SLOP_ON_RELEASE,
  dragThresholdFor,
  liftedPoint,
} from '../utils/dragFeel';
import { isWordSetReady, preloadWordSet } from '../data/wordSetLoader';
import {
  TUTORIAL_FINISH_BUTTON,
  TUTORIAL_FINISH_TEXT,
  TUTORIAL_FINISH_TITLE,
  TUTORIAL_INTRO_BUTTON,
  TUTORIAL_INTRO_TEXT,
  TUTORIAL_INTRO_TITLE,
  TUTORIAL_REPLAY_FINISH_BUTTON,
  TUTORIAL_STEPS,
  createTutorialState,
} from '../utils/tutorialScript';
import { logTutorialEvent } from '../lib/api';
import { getOrCreateAnonId } from '../utils/visitTracking';
import { useModalA11y } from '../hooks/useModalA11y';
import { Board } from './Board';
import { GameHeader } from './GameHeader';
import { Rack } from './Rack';
import { Tile } from './Tile';

const MESSAGE_COLORS: Record<string, string> = {
  ok: 'text-green',
  err: 'text-red',
  warn: 'text-gold',
  '': 'text-muted',
};

/** Rakibin taşları arasındaki bekleme (ms) — insan gibi "diziliyor" hissi. */
const RAKIP_TAS_ARASI = 260;
/** Oyuncunun hamlesi oynandıktan sonra sonucu okuma payı (ms). */
const SONUC_OKUMA = 1400;
/**
 * Rakip oynadıktan SONRA "Rakip hamlesini yaptı" balonunun ekranda kalma
 * süresi (ms). Balon taş dizilirken DEĞİL, hamle bittikten sonra çıkıyor —
 * dizilme ~1 sn sürüyor ve o sırada göz zaten taşları izliyor. Süre iki
 * turda kullanıcıyla ayarlandı (7 Eylül 2026): 1800 *"çok hızlı gidiyor"*,
 * 2600 fazla → **2000**.
 */
const RAKIP_OKUMA = 2000;

/**
 * Tanıtım balonu — mavi kutu + aşağı bakan kuyruk (tahtadaki balonun eşi).
 *
 * ⚠ HİZA `style` ile veriliyor, Tailwind SINIFIYLA DEĞİL (7 Eylül 2026
 * akşamı, kullanıcı: *"'Hamleni tamamlamak için Oyna' balon yazısının oku
 * Oyna butonunu göstermiyor"*). Sebep bu depoya özgü bir tuzak: kap zaten
 * `items-center` taşıyordu ve çağıran `items-end` ekliyordu — Tailwind'de
 * hangisinin kazandığını SINIF DİZESİNDEKİ sıra değil, üretilen CSS'teki
 * sıra belirler, yani `items-end` sessizce yutuluyor ve kuyruk balonun
 * ORTASINDA kalıyordu (OYNA butonunu değil rafın ortasını işaret ediyordu).
 * Satır içi stil bu belirsizliği tamamen kaldırır.
 *
 * Kuyruk ayrıca kenardan 12 px içeride duruyor (portun `_Balon`ıyla aynı):
 * tam köşeye oturan bir üçgen yuvarlatılmış kenarın dışına taşmış görünür.
 */
function Balon({
  text,
  className,
  hiza,
}: {
  text: string;
  className: string;
  /** Balonun ve kuyruğun yatay hizası — kuyruk neyi işaret ediyorsa o. */
  hiza: 'sol' | 'orta' | 'sag';
}) {
  const alignItems = hiza === 'sol' ? 'flex-start' : hiza === 'sag' ? 'flex-end' : 'center';
  const kuyrukKenar =
    hiza === 'sol' ? { marginLeft: 12 } : hiza === 'sag' ? { marginRight: 12 } : {};
  return (
    <div
      data-balon={hiza}
      className={`pointer-events-none absolute z-30 flex flex-col ${className}`}
      style={{ alignItems }}
    >
      <div
        className="font-bold leading-snug text-center rounded-[9px] text-white"
        style={{
          // Punto ve genişlik BİRLİKTE ayarlandı (7 Eylül 2026 akşamı,
          // kullanıcı: *"Balon fontlarını da biraz büyütelim. Tek satır uzun
          // olanları 2 satıra bölelim."*). Genişlik kapağı daraltılmasa büyüyen
          // punto balonu ekran boyunca UZATIRDI; 58vw uzun cümleleri iki satıra
          // kırıyor, kısa olanlar tek satır kalıyor.
          background: '#2563EB',
          fontSize: 'clamp(11px, 3.2vw, 16px)',
          padding: '7px 10px',
          maxWidth: '58vw',
          boxShadow: '0 2px 6px rgba(15,23,42,0.28)',
        }}
      >
        {text}
      </div>
      <span
        // Testin ölçtüğü öğe: kuyruk GERÇEKTEN neyi gösteriyor
        // (`smoke.spec.ts` → OYNA butonunun x aralığı).
        data-balon-kuyruk=""
        style={{
          width: 0,
          height: 0,
          borderLeft: '5px solid transparent',
          borderRight: '5px solid transparent',
          borderTop: '6px solid #2563EB',
          ...kuyrukKenar,
        }}
      />
    </div>
  );
}

interface TutorialGameProps {
  /** Skor kutusunda ve rafta görünen ad (hesap adı ya da "Sen"). */
  playerName: string;
  /**
   * Tanıtım tamamlandı. `source: 'auto'`da çağıran GERÇEK OYUNU başlatır;
   * `'replay'`de hiçbir oyun başlamaz, çağıran geldiği ekrana döner.
   */
  onFinish: () => void;
  /** "Atla" — `onFinish` ile aynı hedef, ama sahne yarıda bırakılmış olur. */
  onSkip: () => void;
  /**
   * Tanıtım NEREDEN açıldı (Onboarding Faz 3 + 5, 8 Eylül 2026):
   *   'auto'   → ilk oyunda kapı açtı (`shouldShowTutorial`),
   *   'replay' → kullanıcı "Nasıl oynanır?" penceresinden kendi başlattı.
   *
   * İki iş yapıyor: kapanış butonunun sözünü (`TUTORIAL_FINISH_BUTTON` ↔
   * `TUTORIAL_REPLAY_FINISH_BUTTON`) ve telemetrinin `source` alanını
   * belirliyor — ikisi aynı satırda tutulmasa `auto` kitlesinin gerçek terk
   * oranı meraklı tekrar izleyenlerle karışırdı (bkz. `AdminTutorialFunnelRow`).
   */
  source?: 'auto' | 'replay';
}

export function TutorialGame({ playerName, onFinish, onSkip, source = 'auto' }: TutorialGameProps) {
  const [state, dispatch] = useReducer(gameReducer, playerName, createTutorialState);
  const [stepIndex, setStepIndex] = useState(0);
  // 'oyna' = sıra oyuncuda, raylar açık · 'bekle' = hamle/rakip animasyonu
  // sürüyor, tahta kilitli · 'bitti' = kapanış kartı.
  const [mode, setMode] = useState<'oyna' | 'bekle' | 'bitti'>('oyna');
  // Rakip sırasının evresi. 'diziyor' = taşlar tek tek iniyor (balon YOK,
  // göz zaten taşları izliyor; mesaj şeridi "Rakip oynuyor…" diyor),
  // 'bitti' = hamle oynandı, balon 2,6 sn "Rakip hamlesini yaptı" der.
  const [rakipEvre, setRakipEvre] = useState<'yok' | 'diziyor' | 'bitti'>('yok');
  const [confirmOpen, setConfirmOpen] = useState(false);
  // Karşılama penceresi — tanıtım AÇILIRKEN, ilk sahneden önce (bkz.
  // `TUTORIAL_INTRO_TITLE`). Kapanınca bir daha açılmaz.
  const [introOpen, setIntroOpen] = useState(true);
  const [note, setNote] = useState<string | null>(null);
  const [wordsReady, setWordsReady] = useState(isWordSetReady());

  const step = TUTORIAL_STEPS[stepIndex];
  const me = state.players[0];

  // Zamanlayıcılarla sürülen rakip animasyonu, ekran kapanırken durmalı.
  const timers = useRef<number[]>([]);
  const alive = useRef(true);
  // Async dizide `state` bayatlar (closure) — rakibin raf indeksleri her taşta
  // yeniden okunmak zorunda. Her render'da tazelenen bir ref bunu çözüyor;
  // aradaki `await` (≥260 ms) React'in yeniden render etmesine fazlasıyla yeter.
  const stateRef = useRef(state);
  stateRef.current = state;

  useEffect(() => {
    // ⚠ Bayrak effect'in İÇİNDE yeniden açılıyor, `useRef(true)` YETMEZ:
    // StrictMode dev'de bağla → çöz → yeniden bağla yapıyor, yani ilk
    // çözümde `false`a düşen bayrak bir daha hiç açılmıyordu ve rakibin
    // sırası ilk `await`ten sonra sessizce duruyordu (7 Eylül 2026, duman
    // testi yakaladı: skor 12 yazıyor, sahne 1'de kilitli kalıyor).
    alive.current = true;
    return () => {
      alive.current = false;
      timers.current.forEach((id) => window.clearTimeout(id));
      timers.current = [];
    };
  }, []);

  // ── Telemetri (Onboarding Faz 5) ─────────────────────────────────────────
  // Tanıtımın KENDİ ölçümü; oyun telemetrisi (`logGameStart`, `games`) hâlâ
  // ÇALIŞMIYOR — tanıtım bir "oyun" değil (bkz. dosya başı). Üç olay:
  // ekrana geldi · dört sahne bitti · atlandı (hangi sahnede).
  //
  // ⚠ `sentRef`: StrictMode dev'de effect iki kez çalışır ve tek açılış İKİ
  // 'start' satırı yazardı — `useBoardZoom`'daki `hintDecided` ile aynı
  // sınıf koruma. Fire-and-forget: hata tanıtımı etkilemez.
  const telemetriRef = useRef<Record<string, boolean>>({});
  const olayYaz = (event: 'start' | 'finish' | 'skip', step: number | null = null) => {
    if (telemetriRef.current[event]) return;
    telemetriRef.current[event] = true;
    void logTutorialEvent(event, source, getOrCreateAnonId(), step);
  };
  useEffect(() => {
    olayYaz('start');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  useEffect(() => {
    // Kapanış kartı açıldı = tanıtım tamamlandı. (Senaryo bozulursa açılan
    // acil çıkış dalı da buraya düşer — doğrulayıcı o dalı zaten imkânsız
    // kılıyor, ölçümü ikiye bölmeye değmez.)
    if (mode === 'bitti') olayYaz('finish');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mode]);
  /** "Atla" — önce ölçülür, sonra çağırana devredilir. */
  const atla = () => {
    // Sahne numarası ekrandaki "TANITIM · n/4" sayacıyla AYNI (1'den başlar).
    olayYaz('skip', Math.min(stepIndex + 1, TUTORIAL_STEPS.length));
    onSkip();
  };

  // Motor kelime listesini tembel yüklenen chunk'tan okuyor: hazır değilken
  // `PLAY` fırlatır (bkz. `wordSetLoader`). Setup'tan gelen normal akışta
  // liste çoktan yüklü olur, yine de tanıtım kendi kapısını kuruyor.
  useEffect(() => {
    if (wordsReady) return;
    let iptal = false;
    preloadWordSet()
      .then(() => {
        if (!iptal) setWordsReady(true);
      })
      .catch(() => {
        // Sessiz: buton "Yükleniyor…" olarak kalır, "Atla" hep çalışır.
      });
    return () => {
      iptal = true;
    };
  }, [wordsReady]);

  const bekle = (ms: number) =>
    new Promise<void>((resolve) => {
      const id = window.setTimeout(resolve, ms);
      timers.current.push(id);
    });

  // ── Bu sahnede ne kaldı ──────────────────────────────────────────────────
  const kalanHedefler = useMemo(() => {
    if (mode !== 'oyna') return [];
    return step.move.cells.filter((cell) => !state.placed[key(cell.r, cell.c)]);
  }, [mode, step, state.placed]);

  const targets = useMemo(
    () => new Set(kalanHedefler.map((cell) => key(cell.r, cell.c))),
    [kalanHedefler],
  );
  const hazir = mode === 'oyna' && kalanHedefler.length === 0;

  /**
   * Rafta işaretlenecek taşlar: bu sahnede daha oynanmamış harflerin raf
   * indeksleri, KELİME SIRASINDA.
   *
   * ⚠ Harfleri tek tek aramak YETMEZ ve bu bir varsayım değil, ölçülmüş bir
   * hata (7 Eylül 2026, cihaz testinden sonraki ilk koşum): 3. sahnede raf
   * `A T N S A N K` ve hedef harfler `N S A N`. Harf harf eşleyen bir arama
   * üçüncü hedef için raftaki İLK "A"yı (indeks 0, önceki sahneden kalan
   * artık taş) işaretliyordu; oyuncu "sıradaki" sanıp onu seçince kare
   * harfi kabul etmiyor ve tanıtım kilitleniyordu.
   *
   * Doğrusu senaryonun kendi garantisini kullanmak: kalan harfler rafta
   * YAN YANA ve kelime sırasında durur (torba sırası elle yazılı; kullanıcı
   * isteği "yanyana koy ve highlight et"). Bu yüzden bitişik blok aranıyor —
   * `verify-tutorial-script` her sahnede bu bloğun var olduğunu kilitliyor.
   */
  const vurgulu = useMemo(() => {
    if (mode !== 'oyna' || kalanHedefler.length === 0) return [];
    const harfler = kalanHedefler.map((h) => h.letter);
    for (let bas = 0; bas + harfler.length <= me.rack.length; bas++) {
      if (harfler.every((l, i) => me.rack[bas + i].letter === l)) {
        return harfler.map((_, i) => bas + i);
      }
    }
    // Bitişik blok yoksa senaryo bozulmuş demektir; tanıtım yine de
    // kilitlenmesin diye harf harf eşleşmeye düşülüyor.
    const kullanildi = new Set<number>();
    const out: number[] = [];
    for (const hedef of kalanHedefler) {
      const idx = me.rack.findIndex((t, i) => t.letter === hedef.letter && !kullanildi.has(i));
      if (idx >= 0) {
        kullanildi.add(idx);
        out.push(idx);
      }
    }
    return out;
  }, [mode, kalanHedefler, me.rack]);

  const vurguluSet = useMemo(() => new Set(vurgulu), [vurgulu]);

  // ── Sürükleme (raftan tahtaya) ───────────────────────────────────────────
  // App/OnlineGameScreen'deki jestin SADELEŞTİRİLMİŞ eşi: taslak taşı geri
  // sürükleme, ıskalama kurtarma, zoom ve joker YOK — tanıtımda bunların
  // hiçbiri kullanılmıyor. Jestin MANTIĞI böyle sade, ama HİSSİ birebir
  // aynı: eşikler, kaldırma payı ve hayaletin görseli `utils/dragFeel.ts`ten
  // geliyor (kullanıcı: *"taşlar gerçek oyundaki gibi çok akıcı değil"* —
  // 7 Eylül 2026; fark tam olarak bu dört ayardı).
  const [ghost, setGhost] = useState<{ x: number; y: number; index: number; tile: TileModel } | null>(
    null,
  );
  const [dragOverKey, setDragOverKey] = useState<string | null>(null);
  const dragRef = useRef<{ index: number; tile: TileModel; x: number; y: number; moved: boolean } | null>(
    null,
  );

  /** İşaretçinin altındaki tahta hücresi ("r,c") — yoksa null. */
  const hucreAt = (x: number, y: number): string | null => {
    const el = document.elementFromPoint(x, y);
    const cell = el?.closest('[data-cell]') as HTMLElement | null;
    return cell?.getAttribute('data-cell') ?? null;
  };

  /** Bu hücre, seçili/sürüklenen harf için geçerli bir hedef mi? */
  const hedefUygun = (k: string | null, letter: string): boolean => {
    if (!k) return false;
    const [r, c] = k.split(',').map(Number);
    return kalanHedefler.some((h) => h.r === r && h.c === c && h.letter === letter);
  };

  const onRackPointerDown = (i: number, e: React.PointerEvent<HTMLDivElement>) => {
    if (mode !== 'oyna' || !vurguluSet.has(i)) return;
    try {
      e.currentTarget.setPointerCapture(e.pointerId);
    } catch {
      // Nadir: pointerId geçersiz olabilir — yakalama olmadan da çalışır.
    }
    dragRef.current = { index: i, tile: me.rack[i], x: e.clientX, y: e.clientY, moved: false };
  };

  const onRackPointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = dragRef.current;
    if (!d) return;
    if (!d.moved) {
      // Eşik parmakta 10, farede 6 — tek sayı ikisine birden uymuyor
      // (ölçüm `dragFeel.ts`te).
      if (Math.hypot(e.clientX - d.x, e.clientY - d.y) < dragThresholdFor(e.pointerType)) return;
      d.moved = true;
    }
    // Taş parmağın 30 px ÜZERİNDE çizilir ve hedef DE aynı noktadan
    // hesaplanır — görsel ile bırakma noktası asla ayrışmaz.
    const kaldirilmis = liftedPoint(e.clientY);
    setGhost({ x: e.clientX, y: kaldirilmis, index: d.index, tile: d.tile });
    setDragOverKey(hucreAt(e.clientX, kaldirilmis));
  };

  const onRackPointerUp = (e: React.PointerEvent<HTMLDivElement>) => {
    const d = dragRef.current;
    dragRef.current = null;
    setGhost(null);
    setDragOverKey(null);
    if (!d) return;
    // Bırakma kararının eşiği hayalet eşiğinden AYRI ve daha geniş (24 px):
    // parmak titremesi yüzünden "sürükleme" sayılan dokunuşlar sessizce
    // kayboluyordu — gerçek oyunda iki kez bildirilmiş bir hata
    // (bkz. `TAP_SLOP_ON_RELEASE`).
    if (Math.hypot(e.clientX - d.x, e.clientY - d.y) < TAP_SLOP_ON_RELEASE) {
      // Yerinde dokunuş = seçim (gerçek oyundaki davranışın aynısı:
      // `draggable` rafta `onClick` bağlanmadığından seçimi bu dal yapar).
      dispatch({ type: 'SELECT_TILE', index: d.index });
      return;
    }
    const k = hucreAt(e.clientX, liftedPoint(e.clientY));
    if (!hedefUygun(k, d.tile.letter)) return; // yanlış kare: taş rafa döner
    const [r, c] = k!.split(',').map(Number);
    dispatch({ type: 'PLACE_TILE', r, c, rackIndex: d.index });
    // ⚠ Jestin ardından gelen compat `click` bu hücreye düşer ve orada artık
    // TAŞ vardır → `handleCellClick` onu anında geri alırdı (bu depodaki
    // "hayalet tık" sınıfının ta kendisi, bkz. utils/ghostClick.ts).
    swallowNextClick();
  };

  const onRackPointerCancel = () => {
    dragRef.current = null;
    setGhost(null);
    setDragOverKey(null);
  };

  // ── Dokunarak yerleştirme (seç → kareye dokun) ───────────────────────────
  const handleCellClick = (r: number, c: number) => {
    if (mode !== 'oyna') return;
    const k = key(r, c);
    if (state.placed[k]) {
      dispatch({ type: 'RECALL_CELL', r, c });
      return;
    }
    const hedef = kalanHedefler.find((cell) => cell.r === r && cell.c === c);
    if (!hedef) return; // hedef dışı kare: sessizce yoksayılır (ray)
    const sec = state.selectedTile;
    // Harf seçilmeden kareye dokunmak taş GETİRMEZ (kullanıcı isteği): taş
    // her zaman raftan gelir. Yönlendirme raf balonunda zaten yazıyor.
    if (sec === null || me.rack[sec]?.letter !== hedef.letter) return;
    dispatch({ type: 'PLACE_TILE', r, c, rackIndex: sec });
  };

  /** Hamleyi oynatır, rakibin cevabını dizer, sonraki sahneye geçer. */
  const oyna = async () => {
    setConfirmOpen(false);
    setMode('bekle');
    dispatch({ type: 'PLAY' });
    setNote(step.done);
    await bekle(SONUC_OKUMA);
    if (!alive.current) return;

    setNote(null);
    setRakipEvre('diziyor');
    for (const cell of step.reply.cells) {
      const s = stateRef.current;
      const idx = s.players[s.current].rack.findIndex((t) => t.letter === cell.letter);
      if (idx < 0) {
        // Senaryo bozulduysa (olmaması gereken durum — doğrulayıcı bunu
        // koşumda yakalıyor) oyuncuyu kilitli bir tahtada bırakmaktansa
        // tanıtımı bitiriyoruz.
        setRakipEvre('yok');
        setMode('bitti');
        return;
      }
      dispatch({ type: 'PLACE_TILE', r: cell.r, c: cell.c, rackIndex: idx });
      await bekle(RAKIP_TAS_ARASI);
      if (!alive.current) return;
    }
    dispatch({ type: 'PLAY' });
    setRakipEvre('bitti');
    setNote(step.reply.note);
    await bekle(RAKIP_OKUMA);
    if (!alive.current) return;

    setRakipEvre('yok');
    setNote(null);
    if (stepIndex + 1 < TUTORIAL_STEPS.length) {
      setStepIndex(stepIndex + 1);
      setMode('oyna');
    } else {
      setMode('bitti');
    }
  };

  const handlePlay = () => {
    if (!hazir || !wordsReady) return;
    // Vergi sahnesinde gerçek oyundaki onay penceresi çıkar — tanıtımın işi
    // oyuncuyu o pencereye de alıştırmak.
    if (step.move.tax > 0) {
      setConfirmOpen(true);
      return;
    }
    void oyna();
  };

  // ── Board'un canlı hamle çerçevesi (App.tsx ile aynı hesap) ──────────────
  const moveStatus = useMemo(() => {
    const placedKeys = Object.keys(state.placed);
    if (placedKeys.length === 0 || !wordsReady) return null;
    const current = state.players[state.current];
    if (!current) return null;
    const result = validatePlacement(
      state.board,
      state.placed,
      state.current,
      current.corners,
      isFirstMove(state),
    );
    const formed = getFormedWords(state.board, state.placed);
    const cells =
      formed.length > 0
        ? formed.flatMap((f) => f.coords)
        : (placedKeys.map((k) => k.split(',').map(Number)) as [number, number][]);
    return {
      valid: result.valid,
      reason: result.reason,
      cells,
      score: calcScore(state.board, state.placed, state.bonuses),
    };
  }, [state.placed, state.board, state.players, state.current, state.bonuses, wordsReady]);

  const introRef = useModalA11y(introOpen, () => setIntroOpen(false));
  const confirmRef = useModalA11y(confirmOpen, () => setConfirmOpen(false));
  const finishRef = useModalA11y(mode === 'bitti', onFinish);

  /**
   * Tahtadaki balon. Aynı anda EKRANDA TEK balon olsun diye sıra şu:
   *   1. rakip oynadıysa → "Rakip hamlesini yaptı" (oynadığı karenin yanında),
   *   2. oyuncunun sırası ve hamle HENÜZ TAMAMLANMADIYSA → dersin cümlesi,
   *   3. hamle tamamlandıysa → HİÇBİRİ; söz sırası OYNA balonunun.
   *
   * (3) kullanıcı isteği (7 Eylül 2026, cihaz testi): *"BÜYÜ tahtaya
   * koyulduktan sonra OYNA balonu çıkınca 'Kendi köşenden başla' balonu
   * kaybolmalı."* İki balon aynı anda duruyordu.
   */
  const tahtaBalonu =
    rakipEvre === 'bitti'
      ? {
          r: step.reply.cells[0].r,
          c: step.reply.cells[0].c,
          // Rakibin bütün cevapları 6. satır ve altında; balon her zaman
          // ÜSTTE duruyor ve kapattığı satırlarda hedef kare olmuyor
          // (o sırada zaten oyuncunun sırası değil).
          yon: 'ust' as const,
          text: 'Rakip hamlesini yaptı',
        }
      : mode === 'oyna' && !hazir
        ? { ...step.bubble, text: step.say }
        : null;

  const mesaj =
    note ??
    (rakipEvre === 'diziyor'
      ? 'Rakip oynuyor…'
      : mode === 'oyna' && !hazir
        ? 'Harfi raftan al, işaretli kareye koy.'
        : '');
  const mesajRengi = note ? 'ok' : '';

  return (
    <div className="min-h-[100dvh] w-full flex flex-col items-center overflow-x-hidden">
      <GameHeader state={state} onLogoClick={atla} />

      {/* Sahne sayacı + her sahnede duran "Atla". Kullanıcı kararı: tanıtım
          zorunlu değil, ama atlayan da ilk gerçek oyununda ipuçlarını görür. */}
      <div className="w-full max-w-[680px] px-3 flex items-center justify-between">
        <span className="font-mono text-[10px] tracking-[1.5px] text-muted">
          TANITIM · {Math.min(stepIndex + 1, TUTORIAL_STEPS.length)}/{TUTORIAL_STEPS.length}
        </span>
        <button
          onClick={atla}
          className="font-mono text-[10px] tracking-[1.5px] text-accent min-h-[44px] px-1 active:opacity-70 transition-opacity"
        >
          ATLA →
        </button>
      </div>

      <main className="w-full flex flex-col items-center">
        <Board
          state={state}
          onCellClick={(r, c) => handleCellClick(r, c)}
          moveStatus={moveStatus}
          onOpenHistory={() => {}}
          hideFooter
          targets={mode === 'oyna' ? targets : null}
          coach={tahtaBalonu}
          tileLifted={ghost !== null}
          dragOverKey={dragOverKey}
          dragOverValid={ghost ? hedefUygun(dragOverKey, ghost.tile.letter) : false}
        />

        <div className="w-full max-w-[680px] px-3 pb-3 pt-1">
          {/* ⚠ `relative` BURADA, raf satırında DEĞİL (7 Eylül 2026 akşamı,
              kullanıcı: *"zaten orada 'kelimeyi taşı' balonu duruyor ve
              mesajlar görünmüyor… kaydırsak iyi olur"*). Balonlar
              `bottom-full` ile bu sarmalayıcının üstüne çıkıyor ve
              sarmalayıcı MESAJ ŞERİDİNİ DE kapsadığından balon artık şeridi
              örtmüyor — tahtanın alt kenarına doğru taşıyor.
              Sarmalayıcı raf satırıyla AYNI genişlikte: OYNA balonunun
              `right-1`i butonun sağ kenarına göre hesaplanıyor. */}
          <div className="relative flex flex-col gap-1.5">
            {/* Raf balonu SATIRIN ORTASINDA (7 Eylül 2026 akşamı, kullanıcı:
                *"Hepsinin ortalı ve yerinde olması lazım"*). Önceden sola
                yaslıydı ve rafın sol ucunu işaret ediyordu — oysa cümle
                rafın TAMAMI hakkında; satırın ortası rafın üstüne düşüyor
                (raf `flex-1`, buton ~90px). OYNA balonu sağda KALIYOR:
                o gerçekten sağdaki butonu işaret ediyor. */}
            {mode === 'oyna' && !hazir && (
              <Balon
                text={`Şimdi ${step.move.word} kelimesini taşı`}
                className="left-0 right-0 bottom-full mb-1"
                hiza="orta"
              />
            )}
            {/* Kuyruk OYNA butonunu işaret ETMEK ZORUNDA: balon sağa yaslı
                ve kap butonun sağ kenarına (`right-1`) çapalı. */}
            {hazir && (
              <Balon
                text="Hamleni tamamlamak için OYNA'ya bas"
                className="right-1 bottom-full mb-1"
                hiza="sag"
              />
            )}

            <div
              data-mesaj=""
              className={`text-[11px] font-mono font-bold text-center min-h-[30px] py-0.5 flex items-center justify-center ${MESSAGE_COLORS[mesajRengi]}`}
            >
              {mesaj}
            </div>

            <div className="flex gap-1.5 items-stretch">
            <div className="flex-1 min-w-0">
              {/* Raf HER ZAMAN oyuncunun (rakip oynarken bile) — App'teki
                  `rackPlayer` ile aynı kural. */}
              <Rack
                tiles={me.rack}
                selectedTile={state.selectedTile}
                onSelect={(i) => {
                  if (mode === 'oyna' && vurguluSet.has(i)) {
                    dispatch({ type: 'SELECT_TILE', index: i });
                  }
                }}
                title={me.name}
                color={PLAYER_COLORS[me.colorIndex]}
                draggable={mode === 'oyna'}
                highlight={vurgulu}
                dragHiddenIndex={ghost?.index ?? null}
                onTilePointerDown={onRackPointerDown}
                onTilePointerMove={onRackPointerMove}
                onTilePointerUp={onRackPointerUp}
                onTilePointerCancel={onRackPointerCancel}
              />
            </div>
            <button
              disabled={!hazir || !wordsReady}
              onClick={handlePlay}
              className="btn-raised shrink-0 px-5 rounded-lg font-sans text-[12px] font-bold uppercase tracking-[1.2px] bg-accent text-white active:scale-[0.97] disabled:opacity-35 disabled:cursor-not-allowed"
            >
              {!wordsReady ? 'Yükleniyor…' : 'Oyna'}
            </button>
            </div>
          </div>
        </div>
      </main>

      {/* Sürüklenen taşın parmağın altındaki kopyası. */}
      {ghost && (
        <div
          data-tutorial-ghost=""
          className="pointer-events-none fixed z-[300]"
          style={{ left: ghost.x, top: ghost.y, ...GHOST_TILE_STYLE }}
        >
          <Tile tile={ghost.tile} variant="rack" />
        </div>
      )}

      {/* Vergi sahnesi — gerçek oyundaki onay penceresinin aynısı, üstüne
          tanıtımın tek satırlık açıklaması. */}
      {confirmOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
          <div
            ref={confirmRef}
            role="dialog"
            aria-modal="true"
            aria-label="Sınır ihlali onayı"
            tabIndex={-1}
            className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-4 outline-none"
          >
            <p className="text-base font-bold text-text font-sans">Sınır İhlali!</p>
            <p className="text-sm text-text font-sans leading-relaxed">
              Bu hamleden kazanacağın{' '}
              <strong className="text-green">{step.move.points + step.move.tax}</strong> puanın{' '}
              <strong className="text-red">{step.move.tax}</strong> puanı{' '}
              <strong>{state.players[1].name}</strong> kullanıcısına vergi olarak gidecek.
            </p>
            <p className="text-xs text-muted font-sans leading-relaxed">
              Rakibin bölgesine değen veya giren bir hamle yaparsan vergisini ödersin.
            </p>
            <div className="flex gap-2 mt-1">
              <button
                onClick={() => void oyna()}
                className="btn-raised flex-1 py-2.5 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Oyna
              </button>
              <button
                onClick={() => setConfirmOpen(false)}
                className="btn-raised-neutral flex-1 py-2.5 rounded-md bg-void border border-border text-text text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
              >
                Vazgeç
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Karşılama penceresi: tanıtımın ne olduğunu ve ne kadar süreceğini
          ilk saniyede söyler — kullanıcı isteği (7 Eylül 2026 akşamı).
          Kapanış kartıyla AYNI kabuk (384px onay kartı). */}
      {introOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
          <div
            ref={introRef}
            role="dialog"
            aria-modal="true"
            aria-label={TUTORIAL_INTRO_TITLE}
            tabIndex={-1}
            className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-3 outline-none"
          >
            <p className="text-lg font-bold text-text font-sans">{TUTORIAL_INTRO_TITLE}</p>
            <p className="text-sm text-text font-sans leading-relaxed">{TUTORIAL_INTRO_TEXT}</p>
            <button
              onClick={() => setIntroOpen(false)}
              className="btn-raised mt-1 py-3 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              {TUTORIAL_INTRO_BUTTON}
            </button>
          </div>
        </div>
      )}

      {mode === 'bitti' && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center px-4">
          <div
            ref={finishRef}
            role="dialog"
            aria-modal="true"
            aria-label="Tanıtım tamamlandı"
            tabIndex={-1}
            className="w-full max-w-sm bg-panel border border-[#B8C2D1] rounded-2xl shadow-[0_20px_45px_rgba(15,23,42,0.5)] p-6 flex flex-col gap-3 outline-none"
          >
            <p className="text-lg font-bold text-text font-sans">{TUTORIAL_FINISH_TITLE}</p>
            <p className="text-sm text-text font-sans leading-relaxed">{TUTORIAL_FINISH_TEXT}</p>
            <button
              onClick={onFinish}
              className="btn-raised mt-1 py-3 rounded-md bg-accent text-white text-xs font-bold uppercase tracking-[1px] active:scale-[0.97] transition-transform"
            >
              {source === 'replay' ? TUTORIAL_REPLAY_FINISH_BUTTON : TUTORIAL_FINISH_BUTTON}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
