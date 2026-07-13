// Harfik — nasıl oynanır / kurallar sayfası
import { Modal } from './Modal';

interface HelpModalProps {
  onClose: () => void;
}

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

export function HelpModal({ onClose }: HelpModalProps) {
  return (
    <Modal title="Nasıl Oynanır?" onClose={onClose}>
      <div className="flex flex-col gap-5">

        <Section title="Oyun Nedir?">
          <P>
            Harfik, 13×13'lük özel bir oyun tahtasında oynanan Türkçe kelime oyunudur. 2 veya 4
            oyuncu ile oynanır; oyuncular kendi köşelerinden başlayıp tahtanın ortasına doğru
            ilerlerken puan toplar.
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
            <strong>İlk hamle:</strong> İlk kelimen mutlaka kendi köşendeki ev işaretli kareye
            değmelidir, oradan tahtanın ortasına doğru ilerlersin.
          </P>
          <P>
            <strong>Bağlantı:</strong> Her hamle, oyun tahtasındaki mevcut harflere yatay ya da
            dikey olarak bağlanmalıdır. Harfler aynı satır veya aynı sütun üzerinde olmalıdır.
          </P>
        </Section>

        <Section title="Bölge Vergisi">
          <P>
            Her oyuncunun bölgesi 4×4'lük köşeyle sınırlı değildir: köşesinden başlayıp, o
            oyuncunun kendi taşlarıyla ortogonal (yatay/dikey) olarak bağlı hücrelere doğru
            oyun ilerledikçe genişler. Board üzerinde her oyuncunun bölgesinin güncel dış hattı
            kendi rengiyle çizilir.
          </P>
          <P>
            İlk hamleden sonra bir rakibin bölgesine de taş koyabilirsin — buna hiçbir ön koşul
            yok, her zaman serbesttir. Ama bir hamlen bir rakip bölgesinin içine düşerse ya da
            dışarıdan sınırına bitişik olursa (bölgenin içine girmen şart değil, kenarına
            değmesi yeter), o hamleden kazandığın puanın 1/3'ü bölge sahibine gider, 2/3'ü sende
            kalır. Aynı hamle iki farklı rakip bölgesiyle birden etkileşirse puan üç kişi
            arasında (sen ve iki bölge sahibi) eşit paylaşılır — bu durumda herkese 1/3 düşer.
          </P>
          <P>
            Vergi ödeyerek rakip bölgesine koyduğun taş orada kalıcı olarak senindir: bölgeler
            her hamleden sonra yeniden hesaplanır, bu yüzden o taş kendi taşlarınla kesintisiz
            bağlıysa (köşenden oraya kadar uzanan bir zincir oluşturuyorsa) artık senin
            bölgene dahil olur — rakibin bölgesi o noktada küçülür, seninki büyür. Sadece tek
            başına, kendi zincirine bağlanmayan izole bir taş bırakırsan orası hâlâ rakibin
            bölgesinde sayılır.
          </P>
        </Section>

        <Section title="Bonus Bölgesi">
          <div className="flex flex-col gap-1.5 mt-0.5">
            <Pill label="X2" color="#FBBF24" desc="Bölgeye yeni taş koyunca kelimenin puanı ikiye katlanır" />
            <Pill label="X3" color="#F97316" desc="Tam merkezdeki tek kare: kelime puanı üçe katlanır" />
          </div>
          <P>
            Tahtanın ortasındaki 5×5'lik altın bölgedeki bir kareye o tur yeni bir taş
            koyarsan, o kelimenin puanı x2 olur — klasik bonus kare gibi, yalnızca kare ilk
            kullanıldığında. Daha önceki bir turda oraya konmuş bir taşa sırf bağlanmak ya da
            ondan geçmek x2 kazandırmaz. Tam merkezdeki tek kare turuncu zeminli X3 etiketini
            taşır (üç kat kelime), o da aynı şekilde yalnızca o kareye o tur yeni bir taş
            konursa uygulanır.
          </P>
        </Section>

        <Section title="Hamle Seçenekleri">
          <P>
            <strong>Oyna:</strong> Harf kutusundan seçtiğin harfi oyun tahtasına koy, ardından
            "Oyna" düğmesine bas. Kelimenin geçerli olması gerekir.
          </P>
          <P>
            <strong>Değiştir:</strong> Harf kutusundan istediğin taşları torbaya geri at, yerine
            yeni taş çek. Sıran geçer. Torba boşken kullanılamaz.
          </P>
          <P>
            <strong>Pas Geç:</strong> Sıranı kullanmadan geç. Tüm oyuncular arka arkaya 2 tur
            pas geçerse oyun sona erer.
          </P>
          <P>
            <strong>Karıştır:</strong> Harf kutusundaki taşların sırasını karıştırır (puan
            değişmez).
          </P>
          <P>
            <strong>Geri Al:</strong> Bu turda oyun tahtasına koyduğun taşları harf kutusuna geri
            alır.
          </P>
          <P>
            <strong>Torba:</strong> Torbada kalan taş sayısını ve dışarıda kalan taşların
            dağılımını gösterir.
          </P>
        </Section>

        <Section title="Bingo Bonusu">
          <P>
            Harf kutusundaki 7 taşın tamamını tek hamlede kullanırsan{' '}
            <strong>+50 puan</strong> bonus kazanırsın.
          </P>
        </Section>

        <Section title="Joker (Yıldız) Taşı">
          <P>
            Torbada 2 adet joker vardır. Joker taşı, oynandığında istediğin herhangi bir Türkçe
            harfe dönüşebilir. Puan değeri <strong>0</strong>'dır; bonus kareler de jokere
            uygulanmaz.
          </P>
          <P>
            Rafını ve torbayı tamamen bitiren hamlen <strong>sadece</strong> joker(ler)den
            oluşuyorsa (tek taş olarak 1 joker ya da iki taş olarak 2 joker — başka hiçbir harf
            olmadan) ekstra bonus kazanırsın: <strong>1 jokerle bitiş +50</strong>,{' '}
            <strong>2 jokerle bitiş +100</strong>.
          </P>
        </Section>

        <Section title="Sözlük">
          <P>
            Yalnızca Türkçe kelimeler geçerlidir. Her hamledeki tüm yeni kelimeler (ana kelime +
            yan oluşumlar) sözlükte bulunmalıdır.
          </P>
          <P>
            Sadece Türk Dil Kurumu sözlüğünde yer alan kelimeler bulunur.
          </P>
        </Section>

        <Section title="Oyunun Sonu">
          <P>
            Bir oyuncunun harf kutusu boşaldığında ve torbada taş kalmadığında oyun biter. Harf
            kutusunda taş kalan oyuncuların puanından o taşların toplam değeri düşülür.
          </P>
          <P>
            Tüm oyuncular arka arkaya 2 tur boyunca pas geçerse de oyun sona erer. En yüksek
            puana sahip oyuncu kazanır.
          </P>
        </Section>

        <Section title="Skor Kartı ve Puanlama">
          <P>
            Giriş yapmış kullanıcılar için her oyun sonucu Skor Kartı'na kaydedilir. Oyun içi
            puanının yanında, sıralamana göre bir <strong>lig puanı</strong> de kazanırsın.
            4 kişilik oyunda birinci bitirirsen <strong>+2</strong>, ikinci bitirirsen{' '}
            <strong>+1</strong> puan; üçüncü ve dördüncü sıralar 0 puan getirir. 2 kişilik
            oyunda ise sadece birinci <strong>+2</strong> puan alır — ikinci 0 puan getirir,
            çünkü tek rakibin olduğu bir oyunda ikinci olmak kaybetmekle aynı şeydir. Tam
            beraberlikte aynı sırayı paylaşan oyuncuların hepsi o sıranın puanını alır.
          </P>
          <P>
            Bu lig puanları 2 kişilik ve 4 kişilik oyunlar için ayrı ayrı toplanır; Skor
            Kartı'ndaki sekmeler bu iki modun istatistiklerini ayrı ayrı, üstteki "Lig Puanı"
            ise ikisinin toplamını gösterir.
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
    </Modal>
  );
}
