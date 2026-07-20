// Kelimeki — bir hücre kümesinin dış hattını (delikler ve `extraOpen` ile
// bastırılan kenarlar dahil) TEK, tamamen yuvarlatılmış bir SVG path'ine
// dönüştürür. Eski uygulama her hücreye ayrı ayrı CSS border+radius
// veriyordu; bu yalnızca dışbükey (convex) köşeleri yuvarlıyordu — köşe
// bloğu gibi dolu dikdörtgenlerde sorun çıkmıyordu, ama köşeden tek hücre
// genişliğinde uzanan kollarda oluşan içbükey (concave/reflex) köşeler
// köşeli/kesik duruyordu. Bu modül her iki köşe türünü de aynı algoritmayla
// (kenarı köşeye `radius` kadar yaklaşınca ikinci dereceden eğriye geçme)
// yuvarlar, böylece genişleyen bölgeler de köşe bloğu gibi pürüzsüz görünür.
import { key } from './board';

type Pt = readonly [number, number];

/**
 * Hücrelerin sınır kenarlarını birim (1x1) parçalar halinde toplar ve
 * birbirine bağlı zincirlere ayırır. `extraOpen(r,c,nr,nc)` true dönerse o
 * kenar bastırılır (çizilmez) — komşu (nr,nc) kümede olmasa bile.
 * Bastırılan kenarlar zinciri açık (kapanmayan) bırakabilir; bu yüzden hem
 * açık uçlu parçalar hem kapalı halkalar destekli.
 */
function traceEdges(
  cells: [number, number][],
  extraOpen?: (r: number, c: number, nr: number, nc: number) => boolean,
): Pt[][] {
  const cellSet = new Set(cells.map(([r, c]) => key(r, c)));
  const isOpen = (r: number, c: number, nr: number, nc: number) =>
    cellSet.has(key(nr, nc)) || (extraOpen ? extraOpen(r, c, nr, nc) : false);

  const out = new Map<string, Pt[]>();
  const inCount = new Map<string, number>();
  const addEdge = (a: Pt, b: Pt) => {
    const ak = `${a[0]},${a[1]}`;
    const bk = `${b[0]},${b[1]}`;
    if (!out.has(ak)) out.set(ak, []);
    out.get(ak)!.push(b);
    inCount.set(bk, (inCount.get(bk) ?? 0) + 1);
  };

  for (const [r, c] of cells) {
    if (!isOpen(r, c, r - 1, c)) addEdge([c, r], [c + 1, r]);
    if (!isOpen(r, c, r, c + 1)) addEdge([c + 1, r], [c + 1, r + 1]);
    if (!isOpen(r, c, r + 1, c)) addEdge([c + 1, r + 1], [c, r + 1]);
    if (!isOpen(r, c, r, c - 1)) addEdge([c, r + 1], [c, r]);
  }

  const popEdge = (p: Pt): Pt | null => {
    const list = out.get(`${p[0]},${p[1]}`);
    if (!list || list.length === 0) return null;
    return list.pop()!;
  };

  const paths: Pt[][] = [];

  // 1) Gelen kenarı olmayan noktalar gerçek "açık uç" başlangıcıdır.
  for (const [startKey] of out) {
    if ((inCount.get(startKey) ?? 0) > 0) continue;
    while ((out.get(startKey)?.length ?? 0) > 0) {
      const startPt = startKey.split(',').map(Number) as unknown as Pt;
      const path: Pt[] = [startPt];
      let cur: Pt = startPt;
      for (;;) {
        const next = popEdge(cur);
        if (!next) break;
        path.push(next);
        cur = next;
      }
      if (path.length > 1) paths.push(path);
    }
  }

  // 2) Geriye kalan her şey kapalı halka olmalı.
  for (const [startKey] of out) {
    while ((out.get(startKey)?.length ?? 0) > 0) {
      const startPt = startKey.split(',').map(Number) as unknown as Pt;
      const path: Pt[] = [startPt];
      let cur: Pt = startPt;
      for (;;) {
        const next = popEdge(cur);
        if (!next) break;
        path.push(next);
        if (next[0] === startPt[0] && next[1] === startPt[1]) break;
        cur = next;
      }
      if (path.length > 1) paths.push(path);
    }
  }

  return paths;
}

/** Ardışık, aynı yöndeki (düz devam eden) noktaları atarak gerçek köşeleri bırakır. */
function simplifyPath(pts: Pt[]): Pt[] {
  const closed =
    pts.length > 2 && pts[0][0] === pts[pts.length - 1][0] && pts[0][1] === pts[pts.length - 1][1];
  const core = closed ? pts.slice(0, -1) : pts;
  const n = core.length;
  if (n < 3) return pts;
  const result: Pt[] = [];
  for (let i = 0; i < n; i++) {
    if (!closed && (i === 0 || i === n - 1)) {
      result.push(core[i]);
      continue;
    }
    const prev = core[(i - 1 + n) % n];
    const cur = core[i];
    const next = core[(i + 1) % n];
    const dx1 = cur[0] - prev[0];
    const dy1 = cur[1] - prev[1];
    const dx2 = next[0] - cur[0];
    const dy2 = next[1] - cur[1];
    const cross = dx1 * dy2 - dy1 * dx2;
    const sameDir = dx1 * dx2 + dy1 * dy2 > 0;
    if (cross === 0 && sameDir) continue;
    result.push(cur);
  }
  if (closed) result.push(result[0]);
  return result;
}

function offsetPoint(from: Pt, to: Pt, dist: number): Pt {
  const len = Math.hypot(to[0] - from[0], to[1] - from[1]);
  if (len === 0) return from;
  const t = Math.min(dist, len / 2) / len;
  return [from[0] + (to[0] - from[0]) * t, from[1] + (to[1] - from[1]) * t];
}

function roundedLoopPath(pts: Pt[], radius: number): string {
  const core = pts.slice(0, -1);
  const n = core.length;
  if (n < 2) return '';
  let d = '';
  for (let i = 0; i < n; i++) {
    const prev = core[(i - 1 + n) % n];
    const cur = core[i];
    const next = core[(i + 1) % n];
    const inPt = offsetPoint(cur, prev, radius);
    const outPt = offsetPoint(cur, next, radius);
    d += i === 0 ? `M ${inPt[0]} ${inPt[1]} ` : `L ${inPt[0]} ${inPt[1]} `;
    d += `Q ${cur[0]} ${cur[1]} ${outPt[0]} ${outPt[1]} `;
  }
  return `${d}Z`;
}

function roundedOpenPath(pts: Pt[], radius: number): string {
  const n = pts.length;
  if (n < 2) return '';
  let d = `M ${pts[0][0]} ${pts[0][1]} `;
  for (let i = 1; i < n - 1; i++) {
    const prev = pts[i - 1];
    const cur = pts[i];
    const next = pts[i + 1];
    const inPt = offsetPoint(cur, prev, radius);
    const outPt = offsetPoint(cur, next, radius);
    d += `L ${inPt[0]} ${inPt[1]} Q ${cur[0]} ${cur[1]} ${outPt[0]} ${outPt[1]} `;
  }
  d += `L ${pts[n - 1][0]} ${pts[n - 1][1]}`;
  return d;
}

/**
 * Verilen hücre kümesinin (delikler dahil) dış hattını, tüm köşeleri
 * (dışbükey + içbükey) `radius` (ızgara birimi) kadar yuvarlatılmış tek bir
 * SVG path `d` dizesi olarak döndürür. Birden fazla ayrık parça/halka varsa
 * hepsi tek dizede birleştirilir (SVG path birden fazla alt-yol içerebilir).
 */
export function buildRoundedOutlinePath(
  cells: [number, number][],
  radius: number,
  extraOpen?: (r: number, c: number, nr: number, nc: number) => boolean,
): string {
  const rawPaths = traceEdges(cells, extraOpen);
  const parts = rawPaths
    .map(simplifyPath)
    .map((p) => {
      const closed = p.length > 2 && p[0][0] === p[p.length - 1][0] && p[0][1] === p[p.length - 1][1];
      return closed ? roundedLoopPath(p, radius) : roundedOpenPath(p, radius);
    })
    .filter(Boolean);
  return parts.join(' ');
}
