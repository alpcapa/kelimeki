// Harfik — nasıl oynanır / kurallar sayfası. İki adım: kısa "Hızlı Başlangıç"
// (varsayılan) ve altındaki linkle açılan "Detaylı Kurallar".
import { useState } from 'react';
import { Modal } from './Modal';
import { BINGO_BONUS } from '../game/constants';

interface HelpModalProps {
  onClose: () => void;
  initialStep?: 'quick' | 'detailed';
}

type Step = 'quick' | 'detailed';

const Section = ({ title, children }: { title: string; children: React.ReactNode }) => (
  <div className="flex flex-col gap-2">
    <h3 className="font-mono text-[11px] uppercase tracking-[1.5px] text-accent border-b border-border pb-1">
      {title}
    </h3>
    {children}
  </div>
);

const P = ({ children }: { children: React.ReactNode }) => (
  <p className="text-xs font-sans text-text leading-relaxed">{children}</p>
);

const Pill = ({
  label,
  color,
  desc,
}: {
  label: string;
  color: string;
  desc: string;
}) => (
  <div className="flex items-center gap-2">
    <span
      className="shrink-0 w-8 h-6 rounded text-[10px] font-bold font-mono flex items-center justify-center text-white"
      style={{ background: color }}
    >
      {label}
    </span>
    <span className="text-xs font-sans text-text">{desc}</span>
  </div>
);

const TileRow = ({
  pts,
  tiles,
}: {
  pts: number | string;
  tiles: string;
}) => (
  <div className="flex items-start gap-2">
    <span className="shrink-0 w-8 text-right font-mono text-xs font-bold text-accent">
      {pts}
    </span>
    <span className="font-mono text-xs text-text leading-relaxed">{tiles}</span>
  </div>
);

const QuickItem = ({ icon, children }: { icon: string; children: React.ReactNode }) => (
  <div className="flex items-start gap-2.5">
    <span
      className="shrink-0 w-7 h-7 rounded-full bg-accent/10 flex items-center justify-center text-sm"
      aria-hidden
    >
      {icon}
    </span>
    <span className="text-xs font-sans text-text leading-relaxed pt-1.5">{children}</span>
  </div>
);

function QuickStart() {
  return (
    <div className="flex flex-col gap-3.5">
      <QuickItem icon="🎯">
        2 ya da 4 oyuncuyla, <strong>Yapay Zekâ</strong>'ya karşı oynanır.
      </QuickItem>
      <QuickItem icon="🏠">
        Kendi köşenden başlarsın, tahtanın <strong>ortasına doğru</strong> ilerlersin.
      </QuickItem>
      <QuickItem icon="🔗">
        Yeni kelimeler tahtadaki mevcut harflere (rakiplerinki dahil) bağlanmalı.
      </QuickItem>
      <QuickItem icon="🗺️">
        Bölgen, bağladığın kelimelerle büyür; kalın çizgiyle gösterilir.
      </QuickItem>
      <QuickItem icon="💰">
        Bir rakip bölgesine değen/giren hamle, kazandığın puanın <strong>1/3</strong>'ünü ona
        verir.
      </QuickItem>
      <QuickItem icon="✨">
        Ortadaki 5×5 alan puanı <strong>×2</strong>, tam merkez ise <strong>×3</strong> yapar
        (sadece o kare ilk kullanıldığında).
      </QuickItem>
      <QuickItem icon="🎁">
        7 taşını tek hamlede bitirirsen <strong>+{BINGO_BONUS} bonus</strong> (Bingo).
      </QuickItem>
      <QuickItem icon="⭐">
        Joker (<strong>?</strong>) istediğin harfe dönüşür, puan değeri 0'dır.
      </QuickItem>
      <QuickItem icon="📖">
        Sadece <strong>TDK sözlüğündeki</strong> Türkçe kelimeler geçerlidir.
      </QuickItem>
      <QuickItem icon="🏁">
        Raf + torba boşalınca ya da art arda 2 tur pas geçilince oyun biter; en yüksek puan
        kazanır.
      </QuickItem>
    </div>
  );
}

function DetailedRules() {
  return (
    <div className="flex flex-col gap-5">
      <Section title="Oyun Nedir?">
        <P>
          Bu, klasik kelime oyunlarından farklı, strateji odaklı bir kelime oyunudur. 2 veya 4
          oyuncu ile, Yapay Zekâ'ya karşı oynanır. Her oyuncu kendi köşesinden başlayarak
          tahtanın merkezine doğru ilerler ve kelimeler oluşturarak puan kazanır.
        </P>
        <P>
          İlk hamleni mutlaka kendi bölgenin köşesinden yapmalısın. Bundan sonraki hamlelerini
          ise tahtanın istediğin herhangi bir yerine yapabilirsin. Ancak önemli bir kural var:
          Eğer yaptığın hamle başka bir oyuncunun bölgesine temas ederse, kazandığın puanın
          üçte birini o oyuncuyla paylaşmak zorunda kalırsın.
        </P>
        <P>
          Bu nedenle en iyi strateji, mümkün olduğunca kendi bölgeni büyütürken rakiplerinin
          genişlemesini zorlaştıracak hamleler yapmaktır. Oyuncuların kontrol ettiği bölgeler
          kalın çizgilerle gösterilir. Hamlen herhangi bir oyuncunun bölgesine temas etmiyorsa
          puan paylaşımı olmaz ve kazandığın puanın tamamı sana kalır.
        </P>
        <P>
          Her hamle hem kelime puanını hem de tahtadaki konumunu etkilediği için, oynamadan
          önce tüm olasılıkları dikkatlice değerlendirmelisin.
        </P>
      </Section>

      <Section title="Temel Kurallar">
        <P>
          <strong>Başlangıç:</strong> Her oyuncu tahtanın köşelerindeki 4×4'lük bölgelere
          sahiptir. 2 kişilik oyunda 1. oyuncu sol-üst, 2. oyuncu sağ-alt köşeyi kullanır; 4
          kişilik oyunda her oyuncu tek bir köşe kullanır. Köşelerdeki ev işaretli kare, o
          oyuncunun başlangıç noktasıdır.
        </P>
        <P>
          <strong>Bağlantı:</strong> Her hamle, oyun tahtasındaki mevcut harflere (rakipler de
          dahil) yatay ya da dikey olarak bağlanmalıdır.
        </P>
      </Section>

      <Section title="Bölge Vergisi">
        <P>
          Her oyuncunun bölgesi 4×4'lük köşeyle başlar; köşenden başlayıp, kelimeleri
          bağladıkça genişler. Board üzerinde her oyuncunun güncel bölgesi kalın çizgiyle
          belirlenir.
        </P>
        <P>
          İlk hamleden sonra rakibin bölgesine de taş koyabilirsin — buna hiçbir ön koşul yok,
          her zaman serbesttir. Ancak yerleştirdiğin harflerden herhangi biri rakibin bölgesine
          temas eder ya da içine yerleşirse, o hamleden kazandığın puanın 1/3'ü bölge sahibine
          gider, 2/3'ü sende kalır. Aynı hamle iki farklı rakip bölgesiyle birden etkileşirse
          puan üç kişi arasında eşit paylaşılır — bu durumda herkese 1/3 düşer.
        </P>
        <P>
          Rakip bölgesine temas eden ama senin bölgene dahil olmayan kelimeler sana vergi
          kazandırmaz. Ancak ilerleyen hamlelerde bu kelimeyi kendi bölgene bağlarsan artık
          bölgene dahil olur ve bundan sonra o kelime üzerinden vergi kazanmaya başlarsın.
        </P>
      </Section>

      <Section title="Bonus Bölgesi">
        <div className="flex flex-col gap-1.5 mt-0.5">
          <Pill label="X2" color="#FBBF24" desc="En ortadaki 5×5 sarı alanda yapılan hamleler ikiye katlanır" />
          <Pill label="X3" color="#F97316" desc="Tam merkezdeki tek kare: kelime puanı üçe katlanır" />
        </div>
        <P>
          X2 ve X3 bonusları yalnızca o kare ilk kez kullanıldığında geçerlidir; daha önce
          kullanılmış karelere yapılan bağlantılar bonus kazandırmaz. İki bonus hiçbir zaman
          aynı kelimede birleşmez: bir kelime X3 hücresine değiyorsa tamamen ×3 sayılır, ayrıca
          X2 eklenmez.
        </P>
      </Section>

      <Section title="Hamle Seçenekleri">
        <P>
          <strong>Oyna:</strong> Harf kutundan seçtiğin harfleri oyun tahtasına koy, kelimelerin
          geçerli olup olmadığını gör ve ardından "Oyna" düğmesine bas.
        </P>
        <P>
          <strong>Değiştir:</strong> Harf kutundan istediğin taşları torbaya geri at, yerine
          yeni taş çek. Sıran sonraki oyuncuya geçer. Torba boşken değiştirme pasif olur.
        </P>
        <P>
          <strong>Pas Geç:</strong> Sıranı kullanmadan pas geçmeni sağlar. Tüm oyuncular arka
          arkaya 2 tur pas geçerse oyun sona erer.
        </P>
        <P>
          <strong>Karıştır:</strong> Harf kutundaki taşların yerlerini değiştirerek kelime
          bulmanı kolaylaştırır.
        </P>
        <P>
          <strong>Geri Al:</strong> Oyun tahtasına koyup deneme yaptığın taşları kutuya geri
          alır.
        </P>
        <P>
          <strong>Torba:</strong> Torbada kalan taş sayısını ve dışarıda kalan taşların
          dağılımını gösterir.
        </P>
      </Section>

      <Section title="Bingo Bonusu">
        <P>
          Harf kutundaki 7 taşın tamamını tek hamlede kullanırsan{' '}
          <strong>+{BINGO_BONUS} puan</strong> bonus kazanırsın.
        </P>
      </Section>

      <Section title="Joker (Yıldız) Taşı">
        <P>
          Torbada 2 adet joker bulunur. Joker taşı oynandığında istediğin herhangi bir Türkçe
          harfe dönüşebilir ve puan değeri <strong>0</strong>'dır.
        </P>
        <P>
          Oyun sonunda elinde kalan son taş joker ise ve onu yerleştirerek bitersen{' '}
          <strong>+25 yıldız bonus</strong> puan kazanırsın. 2 joker taş ile bitiş ise{' '}
          <strong>+50 puan</strong> kazandırır. Becerebilirsen jokerini en son hamleye bırak,
          bonusu kap.
        </P>
      </Section>

      <Section title="Sözlük">
        <P>
          Yalnızca Türkçe kelimeler geçerlidir ve sadece Türk Dil Kurumu (TDK) sözlüğünde yer
          alan kelimeler bulunur. TDK sözlüğünde olmayan ama bulmacalarda sık kullanılan bazı
          ekleşimler yapılmıştır.
        </P>
      </Section>

      <Section title="Oyunun Sonu">
        <P>
          Bir oyuncunun harf kutusu boşaldığında ve torbada taş kalmadığında oyun biter. Oyun
          bittiğinde harf kutusunda taş kalan oyuncuların puanından o taşların toplam değeri
          düşülür. Ancak bu puanlar bitiren oyuncuya eklenmez.
        </P>
        <P>
          Tüm oyuncular arka arkaya 2 tur boyunca pas geçerse de oyun sona erer. Bu durumda da
          tüm oyuncuların puanından elinde kalan taşların değeri düşer. En yüksek puana sahip
          oyuncu kazanır.
        </P>
      </Section>

      <Section title="Skor Kartı ve Puanlama">
        <P>
          Oyun oynamak için giriş yapman gerekmez. Sadece oyun istatistikleri ve Sanal Lig için
          giriş yapman gerekir. Giriş yapmış kullanıcılar için her oyun sonucu Skor Kartı'na
          kaydedilir. Oyun içi puanının yanında, sıralamana göre bir Sanal Lig puanı da
          kazanırsın. 4 kişilik oyunda birinci bitirirsen <strong>+2</strong>, ikinci
          bitirirsen <strong>+1</strong> puan; üçüncü ve dördüncü puan almaz. 2 kişilik oyunda
          ise sadece birinci <strong>+2</strong> puan alır; ikinci puan almaz. Beraberlikte
          aynı sırayı paylaşan oyuncuların hepsi o sıranın puanını alır.
        </P>
      </Section>

      <Section title="Puan Tablosu">
        <P>
          Torbada oyuncu sayısından bağımsız olarak sabit toplam 100 taş bulunur. Aşağıdaki
          döküm bu değere göredir.
        </P>
        <div className="flex flex-col gap-1 mt-0.5">
          <TileRow pts="1" tiles="A (×12)  E (×8)  İ (×7)  K (×7)  L (×7)  R (×6)  N (×5)  T (×5)" />
          <TileRow pts="2" tiles="I (×4)  M (×4)  O (×3)  S (×3)  U (×3)" />
          <TileRow pts="3" tiles="B (×2)  Ç (×2)  D (×2)  Ü (×2)  Y (×2)" />
          <TileRow pts="4" tiles="C (×2)  Ş (×2)  Z (×2)" />
          <TileRow pts="5" tiles="G (×1)  H (×1)  P (×1)" />
          <TileRow pts="7" tiles="F (×1)  Ö (×1)  V (×1)" />
          <TileRow pts="8" tiles="Ğ (×1)" />
          <TileRow pts="10" tiles="J (×1)" />
          <TileRow pts="0" tiles="? Joker (×2)" />
        </div>
      </Section>
    </div>
  );
}

export function HelpModal({ onClose, initialStep = 'quick' }: HelpModalProps) {
  const [step, setStep] = useState<Step>(initialStep);

  return (
    <Modal
      title={step === 'quick' ? 'Hızlı Başlangıç' : 'Detaylı Kurallar'}
      onClose={onClose}
      headerLink={
        <button
          onClick={() => setStep(step === 'quick' ? 'detailed' : 'quick')}
          className="self-start font-mono text-[10px] uppercase tracking-[1px] text-accent active:opacity-70 transition-opacity"
        >
          {step === 'quick' ? 'Detaylı Kurallar →' : 'Hızlı Başlangıç →'}
        </button>
      }
    >
      {step === 'quick' ? <QuickStart /> : <DetailedRules />}
    </Modal>
  );
}
