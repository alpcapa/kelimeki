// Shared geometry for the "kelimeki" wordmark — single source of truth for
// both the exported static assets (generate-logo.mjs -> public/logo.svg/
// .png/.jpg) and the in-app vector component (generate-logo-paths.mjs ->
// src/components/LogoMark.tsx). Change the design here once and both
// outputs stay in sync.
//
// Before this file existed, both scripts hand-duplicated the same numbers
// independently — that duplication is exactly how the underline swash
// ended up clipped in an early version of generate-logo-paths.mjs: it
// re-typed a bounding-box guess for the underline instead of deriving it
// from the one place the curve was actually defined.

export const TEXT = 'kelimeki';
export const LOGO_COLOR = '#2563EB';
export const FONT_SIZE = 280;
export const LETTER_SPACING = 30;
export const TEXT_Y = 300;
export const CANVAS_WIDTH = 1400;
export const CANVAS_HEIGHT = 400;
export const UNDERLINE_Y = 330;
// Not exported past this point — only used below to derive the values
// consumers actually need (UNDERLINE_OFFSET_X, UNDERLINE_PATH_LOCAL,
// underlinePathAbsolute()). Keep it that way; a name gets `export` only
// once something outside this file actually imports it.
const UNDERLINE_WIDTH = 640;
// Control/end points of the underline swash, in local space (before
// centering under the text via UNDERLINE_OFFSET_X below).
const UNDERLINE_POINTS_X = [20, 160, 320, 480, 620];
const UNDERLINE_POINTS_Y = [30, 10, 30, 50, 30];
export const UNDERLINE_STROKE_WIDTH = 20;

export const UNDERLINE_OFFSET_X = (CANVAS_WIDTH - UNDERLINE_WIDTH) / 2;

// Local-space 'M...Q...Q...' path, for consumers that apply their own
// translate transform (e.g. generate-logo.mjs's exported SVG <path>).
export const UNDERLINE_PATH_LOCAL =
  `M${UNDERLINE_POINTS_X[0]} ${UNDERLINE_POINTS_Y[0]}` +
  ` Q${UNDERLINE_POINTS_X[1]} ${UNDERLINE_POINTS_Y[1]} ${UNDERLINE_POINTS_X[2]} ${UNDERLINE_POINTS_Y[2]}` +
  ` Q${UNDERLINE_POINTS_X[3]} ${UNDERLINE_POINTS_Y[3]} ${UNDERLINE_POINTS_X[4]} ${UNDERLINE_POINTS_Y[4]}`;

// Absolute-space path + point arrays, for consumers that need real
// coordinates without a transform (generate-logo-paths.mjs's bbox
// cropping needs both the path string and the raw points).
export function underlinePathAbsolute(offsetX = UNDERLINE_OFFSET_X, offsetY = UNDERLINE_Y) {
  const absX = UNDERLINE_POINTS_X.map((x) => x + offsetX);
  const absY = UNDERLINE_POINTS_Y.map((y) => y + offsetY);
  return {
    d:
      `M${absX[0]} ${absY[0]}` +
      ` Q${absX[1]} ${absY[1]} ${absX[2]} ${absY[2]}` +
      ` Q${absX[3]} ${absY[3]} ${absX[4]} ${absY[4]}`,
    x: absX,
    y: absY,
  };
}
