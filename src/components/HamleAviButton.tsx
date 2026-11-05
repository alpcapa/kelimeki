// Kelimeki — Setup'taki "Hamle Avı" girişi (3 Kasım 2026, ROADMAP #48).
//
// Yerleşim kararı (kullanıcı, 3 Kasım): Hamle Avı Setup'ta HER görünümde
// (misafir formu, girişli liste, misafirin devam eden oyunu) en ÜSTTE, kendi
// geniş satırında durur ve "Ya da bir oyun kur" ayırıcısıyla oyun kurma
// bölümünden ayrılır. Sebep: Zorluk seçicisinin yanında dururken Kolay/Normal/Zor'a bağlıymış
// gibi okunuyordu (Hamle Avı'nda rakip yok). 2/3+1/3 yan yana düzen denendi ve elendi.
// 🎯 simgesi kullanıcı onaylı. "YENİ" balonu HEP görünür (kullanıcı, 3 Kasım 2026:
// "Şimdi hep kalsın") — önce bir kez açılınca kalkıyordu, kaldırıldı; ileride süreli/
// kullanıma bağlı bir kural istenirse karar kaydı product-backlog.md'de.
export function HamleAviButton({ onOpen }: { onOpen: () => void }) {
  return (
    <>
      <button
        onClick={onOpen}
        data-hamle-avi-buton=""
        className="relative w-full btn-raised-neutral bg-panel text-text border border-border min-h-[56px] rounded-md font-sans font-bold flex items-center justify-between px-4 active:scale-[0.97] transition-transform"
      >
        <span
          className="absolute -top-2 -right-1 bg-red text-white text-[9px] px-1.5 py-0.5 rounded-full tracking-[0.5px]"
          data-hamle-avi-yeni=""
        >
          YENİ
        </span>
        <span className="flex items-center gap-3">
          <span className="text-xl" aria-hidden>
            🎯
          </span>
          <span className="flex flex-col items-start leading-tight">
            <span className="text-sm uppercase tracking-[0.5px]">Hamle Avı</span>
            <span className="text-[10px] text-muted font-mono normal-case font-normal">
              3 dakikada en iyi hamleyi bul!
            </span>
          </span>
        </span>
        <span className="text-muted" aria-hidden>
          ›
        </span>
      </button>
      {/* `-mb-3`: Setup'ın ana akışı bloklar arası 20 px bırakıyor; ayıraç altındaki
          "Kime karşı" başlığının ÖNSÖZÜ gibi okunduğundan ona yapışık durur (5 Kasım
          2026, kullanıcı: "ekstra boşluğu kaldır"). Ölçüm: ayıraç→başlık 20 → 8 px,
          başlığın kendi altındaki boşlukla (gap-2) aynı. */}
      <div className="-mb-3 flex items-center gap-2" aria-hidden>
        <div className="flex-1 h-px bg-border" />
        <span className="text-[10px] font-mono text-muted uppercase">Ya da bir oyun kur</span>
        <div className="flex-1 h-px bg-border" />
      </div>
    </>
  );
}
