// Mirrors Users::SafeSettings#point_radius (default 6, clamped to 2..12).
export const DEFAULT_POINT_RADIUS = 6
export const MIN_POINT_RADIUS = 2
export const MAX_POINT_RADIUS = 12

const POINT_LAYER_NAMES = ["anomalies", "points-mvt"]

export function clampPointRadius(value) {
  const parsed = parseInt(value, 10)
  if (Number.isNaN(parsed)) return DEFAULT_POINT_RADIUS
  return Math.min(MAX_POINT_RADIUS, Math.max(MIN_POINT_RADIUS, parsed))
}

export function getPointStrokeWidth(radius) {
  return Math.max(1, Math.round(radius / 3))
}

// Layers repaint through their own setPointRadius so a layer hidden by paint
// (see PointsMvtLayer) keeps its zero radius until it is shown again.
export function applyPointSize(layerManager, radius) {
  const clamped = clampPointRadius(radius)

  for (const name of POINT_LAYER_NAMES) {
    layerManager?.getLayer(name)?.setPointRadius?.(clamped)
  }
}
