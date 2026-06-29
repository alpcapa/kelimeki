import { Modal } from './Modal';

interface TermsModalProps {
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

export function TermsModal({ onClose }: TermsModalProps) {
  return (
    <Modal title="Kullanım Koşulları" onClose={onClose}>
      <div className="flex flex-col gap-5">
        <P>
          Harfik'e kaydolarak aşağıdaki koşulları okuduğunuzu ve kabul ettiğinizi beyan edersiniz.
          Son güncelleme: Haziran 2026.
        </P>

        <Section title="1. Hizmet Kapsamı">
          <P>
            Harfik, Türkçe kelimelerle oynanan çevrimiçi bir kelime oyunudur. Hizmet; oyun tahtası,
            lider tablosu ve kullanıcı hesabı özelliklerini kapsar. Hizmet ücretsizdir ve herhangi
            bir bildirimde bulunmaksızın değiştirilebilir ya da sonlandırılabilir.
          </P>
        </Section>

        <Section title="2. Hesap Sorumluluğu">
          <P>
            Kayıt sırasında verdiğiniz bilgilerin doğru ve güncel olması zorunludur. Hesap
            güvenliğinizden yalnızca siz sorumlusunuz; şifrenizi kimseyle paylaşmayınız. Hesabınızı
            başkasına devredemezsiniz.
          </P>
        </Section>

        <Section title="3. Kabul Edilemez Kullanım">
          <P>
            Aşağıdaki eylemler kesinlikle yasaktır:
          </P>
          <ul className="text-xs font-sans text-text leading-relaxed list-disc list-inside flex flex-col gap-1">
            <li>Otomatik araçlar veya botlar aracılığıyla oyun oynamak</li>
            <li>Diğer kullanıcıları rahatsız edecek içerik paylaşmak</li>
            <li>Sistemi manipüle etmeye veya güvenlik açıklarını istismar etmeye çalışmak</li>
            <li>Başkasının hesabına yetkisiz erişim sağlamaya çalışmak</li>
          </ul>
        </Section>

        <Section title="4. Hesap Askıya Alma">
          <P>
            Yukarıdaki kurallara aykırı davranış tespit edilmesi durumunda hesabınız önceden
            bildirim yapılmaksızın askıya alınabilir veya silinebilir.
          </P>
        </Section>

        <Section title="5. Sorumluluk Sınırlaması">
          <P>
            Harfik, hizmet kesintileri, veri kayıpları veya üçüncü taraf hizmetlerinden
            kaynaklanan zararlardan sorumlu değildir. Hizmet "olduğu gibi" sunulmaktadır.
          </P>
        </Section>

        <Section title="6. Değişiklikler">
          <P>
            Bu koşullar zaman zaman güncellenebilir. Değişiklikler yayımlandıktan sonra hizmeti
            kullanmaya devam etmeniz, güncel koşulları kabul ettiğiniz anlamına gelir.
          </P>
        </Section>

        <Section title="7. İletişim">
          <P>
            Sorularınız için: <span className="text-accent font-mono">destek@harfik.com</span>
          </P>
        </Section>
      </div>
    </Modal>
  );
}
