// Validates the tsconfig presets, including their JSDoc type-checking.
// Deliberately environment-neutral (no Node/DOM globals) and ES2020-max so it
// passes every preset from node14 to browser, and kept a plain script (no
// import/export) so module detection stays identical across presets.

/**
 * @typedef {object} Point
 * @property {number} x
 * @property {number} y
 */

/**
 * @param {Point} point
 * @param {number} [scale]
 * @returns {Point}
 */
function scalePoint (point, scale) {
  const factor = scale ?? 1;
  return { x: point.x * factor, y: point.y * factor };
}

/** @type {Point} */
const origin = { x: 0, y: 0 };

void scalePoint(origin, 2);
