// Harfik — el yazısı logo seçenekleri önizlemesi
interface LogoOptionProps {
  font: string;
  size: string;
  color: string;
  letterSpacing?: string;
  rotate?: string;
  decoration?: React.ReactNode;
  description: string;
}

function LogoOption({
  font,
  size,
  color,
  letterSpacing = 'normal',
  rotate = '0deg',
  decoration,
  description,
}: LogoOptionProps) {
  return (
    <div className="flex flex-col items-center gap-2 p-4 rounded-xl border border-border bg-panel">
      <div
        style={{
          fontFamily: font,
          fontSize: size,
          color,
          letterSpacing,
          transform: `rotate(${rotate})`,
          lineHeight: 1.1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        HARFİK
        {decoration}
      </div>
      <p className="text-[10px] text-muted font-mono text-center mt-1">{description}</p>
    </div>
  );
}

export function LogoOptions() {
  return (
    <div className="w-full flex flex-col gap-3">
      <div className="text-[10px] uppercase tracking-[1.5px] text-muted font-mono text-center">
        Logo Seçenekleri
      </div>

      {/* Option A — Caveat: samimi, oyunsu el yazısı */}
      <LogoOption
        font="'Caveat', cursive"
        size="52px"
        color="#2563EB"
        letterSpacing="4px"
        description="A — Caveat · samimi ve oyunsu"
        decoration={
          <svg width="100" height="8" viewBox="0 0 100 8" fill="none" style={{ marginTop: 2 }}>
            <path
              d="M4 4 Q25 1 50 4 Q75 7 96 4"
              stroke="#2563EB"
              strokeWidth="2.5"
              strokeLinecap="round"
              fill="none"
            />
          </svg>
        }
      />

      {/* Option B — Dancing Script: zarif kursif */}
      <LogoOption
        font="'Dancing Script', cursive"
        size="54px"
        color="#1B2430"
        letterSpacing="2px"
        description="B — Dancing Script · zarif ve klasik"
        decoration={
          <div
            style={{
              width: 32,
              height: 3,
              background: '#B7791F',
              borderRadius: 2,
              marginTop: 4,
            }}
          />
        }
      />

      {/* Option C — Permanent Marker: kalın marker darbesi */}
      <LogoOption
        font="'Permanent Marker', cursive"
        size="44px"
        color="#1B2430"
        letterSpacing="3px"
        rotate="-1.5deg"
        description="C — Permanent Marker · güçlü ve enerjik"
      />

      {/* Option D — Pacifico: yuvarlak fırça yazısı */}
      <LogoOption
        font="'Pacifico', cursive"
        size="42px"
        color="#2563EB"
        letterSpacing="1px"
        description="D — Pacifico · arkadaşça ve okunaklı"
        decoration={
          <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
            {['H', 'A', 'R', 'F'].map((l) => (
              <div
                key={l}
                style={{
                  width: 14,
                  height: 14,
                  background: '#2563EB',
                  borderRadius: 2,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontFamily: 'monospace',
                  fontSize: 8,
                  fontWeight: 'bold',
                  color: '#fff',
                }}
              >
                {l}
              </div>
            ))}
          </div>
        }
      />
    </div>
  );
}
