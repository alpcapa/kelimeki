import { useState } from 'react';
import { Modal } from './Modal';
import { FeedbackModal } from './FeedbackModal';

interface PrivacyModalProps {
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

export function PrivacyModal({ onClose }: PrivacyModalProps) {
  const [showFeedback, setShowFeedback] = useState(false);

  return (
    <>
    <Modal title="Gizlilik Politikası" onClose={onClose}>
      <div className="flex flex-col gap-5">
        <P>
          Harfik olarak gizliliğinize önem veriyoruz. Bu politika, hangi verileri topladığımızı,
          nasıl kullandığımızı ve haklarınızı açıklar. Son güncelleme: Temmuz 2026.
        </P>

        <Section title="1. Veri Sorumlusu">
          <P>
            Harfik, herhangi bir şirket ya da tüzel kişilik bulunmaksızın, bağımsız bir geliştirici
            tarafından bireysel olarak geliştirilmekte ve işletilmektedir; faaliyet merkezi
            Sarıyer, İstanbul'dur. 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") anlamında
            veri sorumlusu bu bireysel geliştiricidir ve işbu politikada "Harfik" bu kapsamda
            anılmaktadır. Talep ve başvurularınız için 8. bölümdeki iletişim kanalını
            kullanabilirsiniz.
          </P>
        </Section>

        <Section title="2. Toplanan Veriler">
          <P>Hesap oluştururken şu bilgileri topluyoruz:</P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Ad ve soyad</li>
            <li>E-posta adresi</li>
            <li>Takma isim (isteğe bağlı)</li>
            <li>Oyun istatistikleri (oynanan oyunlar, kazanma/kaybetme, puan geçmişi)</li>
          </ul>
        </Section>

        <Section title="3. Verilerin Kullanım Amacı ve Hukuki Sebebi">
          <P>
            Verileriniz, hesap oluştururken verdiğiniz açık rızanıza (KVKK m.5/1) ve hizmetin
            sunulabilmesi için sözleşmenin kurulması/ifasına (KVKK m.5/2-c) dayanılarak, yalnızca
            şu amaçlarla işlenir:
          </P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Hesap oluşturma ve kimlik doğrulama</li>
            <li>Lider tablosu ve skor kartı gösterimi</li>
            <li>Oyun deneyiminin kişiselleştirilmesi</li>
            <li>Hesap güvenliği ve destek hizmetleri</li>
          </ul>
        </Section>

        <Section title="4. Veri Paylaşımı ve Aktarım">
          <P>
            Kişisel verileriniz; reklam, pazarlama veya üçüncü taraflara satış amacıyla
            kullanılmaz. Altyapı hizmeti olarak Supabase kullanılmaktadır; bu kapsamda veriler
            Supabase'in sunucularında saklanır ve bu sunucular yurt dışında bulunabilir. Böyle bir
            durumda aktarım, KVKK m.9'da aranan (yeterli korumanın bulunduğu ülke veya uygun
            güvencelerin sağlanması gibi) şartlara uygun şekilde yapılır. Yasal zorunluluk halinde
            yetkili makamlarla paylaşım yapılabilir.
          </P>
        </Section>

        <Section title="5. Veri Saklama Süresi">
          <P>
            Verileriniz hesabınız aktif olduğu sürece saklanır. Hesabınızı silmeniz durumunda
            tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.
          </P>
        </Section>

        <Section title="6. Çerezler ve Yerel Depolama">
          <P>
            Harfik, HTTP çerezi (cookie) kullanmaz. Bunun yerine oturumunuzu açık tutmak, oyun
            ilerlemenizi kaydetmek ve tercihlerinizi hatırlamak için tarayıcınızın yerel depolama
            alanı (localStorage/sessionStorage) kullanılır; bu veriler cihazınızda tutulur ve
            sunucularımıza otomatik gönderilmez. Analitik, reklam veya pazarlama amaçlı herhangi
            bir çerez ya da izleme teknolojisi kullanılmamaktadır. Yazı tipleri de dahil tüm
            statik içerikler kendi sunucularımızdan sağlanır; üçüncü taraf (ör. Google Fonts)
            çağrısı yapılmaz.
          </P>
        </Section>

        <Section title="7. KVKK Kapsamındaki Haklarınız">
          <P>KVKK m.11 uyarınca aşağıdaki haklara sahipsiniz:</P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Kişisel verilerinizin işlenip işlenmediğini öğrenme</li>
            <li>İşlenmişse buna ilişkin bilgi talep etme</li>
            <li>İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme</li>
            <li>Yurt içinde/yurt dışında aktarıldığı üçüncü kişileri bilme</li>
            <li>Eksik veya yanlış işlenmişse düzeltilmesini isteme</li>
            <li>Silinmesini veya yok edilmesini talep etme</li>
            <li>Düzeltme/silme işlemlerinin verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme</li>
            <li>Otomatik sistemlerle analiz edilmesi sonucu aleyhinize çıkan bir sonuca itiraz etme</li>
            <li>Kanuna aykırı işleme nedeniyle uğradığınız zararın giderilmesini talep etme</li>
          </ul>
        </Section>

        <Section title="8. Başvuru Usulü ve Kurul'a Şikayet Hakkı">
          <P>
            Yukarıdaki haklarınızı kullanmak için{' '}
            <button
              type="button"
              onClick={() => setShowFeedback(true)}
              className="text-accent font-mono hover:underline"
            >
              Görüş Bildir formu
            </button>{' '}
            üzerinden başvurabilirsiniz. Başvurunuz niteliğine göre en geç 30 gün içinde ücretsiz
            olarak sonuçlandırılır. Başvurunuzun reddedilmesi, yetersiz bulunması veya süresinde
            cevap verilmemesi halinde Kişisel Verileri Koruma Kurulu'na şikayette bulunma
            hakkınız bulunmaktadır.
          </P>
        </Section>
      </div>
    </Modal>
    {showFeedback && <FeedbackModal onClose={() => setShowFeedback(false)} />}
    </>
  );
}
