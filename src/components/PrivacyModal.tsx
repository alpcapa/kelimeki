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
          nasıl kullandığımızı ve haklarınızı açıklar. Son güncelleme: Haziran 2026.
        </P>

        <Section title="1. Toplanan Veriler">
          <P>Hesap oluştururken şu bilgileri topluyoruz:</P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Ad ve soyad</li>
            <li>E-posta adresi</li>
            <li>Takma isim (isteğe bağlı)</li>
            <li>Oyun istatistikleri (oynanan oyunlar, kazanma/kaybetme, puan geçmişi)</li>
          </ul>
        </Section>

        <Section title="2. Verilerin Kullanım Amacı">
          <P>Topladığımız veriler yalnızca şu amaçlarla kullanılır:</P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Hesap oluşturma ve kimlik doğrulama</li>
            <li>Lider tablosu ve skor kartı gösterimi</li>
            <li>Oyun deneyiminin kişiselleştirilmesi</li>
            <li>Hesap güvenliği ve destek hizmetleri</li>
          </ul>
        </Section>

        <Section title="3. Veri Paylaşımı">
          <P>
            Kişisel verileriniz; reklam, pazarlama veya üçüncü taraflara satış amacıyla
            kullanılmaz. Altyapı hizmeti olarak Supabase kullanılmaktadır; veriler onların güvenli
            sunucularında saklanır. Yasal zorunluluk halinde yetkili makamlarla paylaşım
            yapılabilir.
          </P>
        </Section>

        <Section title="4. Veri Saklama Süresi">
          <P>
            Verileriniz hesabınız aktif olduğu sürece saklanır. Hesabınızı silmeniz durumunda
            tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.
          </P>
        </Section>

        <Section title="5. Çerezler">
          <P>
            Oturum yönetimi için zorunlu çerezler kullanılmaktadır. Analitik veya pazarlama
            amaçlı çerez kullanılmamaktadır.
          </P>
        </Section>

        <Section title="6. Haklarınız">
          <P>KVKK kapsamında aşağıdaki haklara sahipsiniz:</P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Verilerinize erişim ve kopyasını talep etme</li>
            <li>Hatalı verilerin düzeltilmesini isteme</li>
            <li>Verilerinizin silinmesini talep etme</li>
            <li>İşlemeye itiraz etme</li>
          </ul>
        </Section>

        <Section title="7. İletişim">
          <P>
            Gizlilik talepleriniz için:{' '}
            <button
              type="button"
              onClick={() => setShowFeedback(true)}
              className="text-accent font-mono hover:underline"
            >
              Görüş Bildir formu
            </button>
          </P>
        </Section>
      </div>
    </Modal>
    {showFeedback && <FeedbackModal onClose={() => setShowFeedback(false)} />}
    </>
  );
}
