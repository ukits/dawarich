export const DEFAULT_POINT_RADIUS = 6
export const MIN_POINT_RADIUS = 2
export const MAX_POINT_RADIUS = 12

export function clampPointRadius(value) {
  const parsed = parseInt(value, 10)
  if (Number.isNaN(parsed)) return DEFAULT_POINT_RADIUS
  return Math.min(MAX_POINT_RADIUS, Math.max(MIN_POINT_RADIUS, parsed))
}

export function getPointStrokeWidth(radius) {
  return Math.max(1, Math.round(radius / 3))
}

export function getLeafletMarkerSize(radius) {
  return Math.max(2, Math.round((radius * 2) / 3))
}

export function applyPointSizeToMapLibre(map, radius) {
  const strokeWidth = getPointStrokeWidth(radius)

  for (const layerId of ["points", "anomalies"]) {
    if (map.getLayer(layerId)) {
      map.setPaintProperty(layerId, "circle-radius", radius)
      map.setPaintProperty(layerId, "circle-stroke-width", strokeWidth)
    }
  }
}
