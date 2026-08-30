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

export function applyPointSizeToMapLibre(map, radius, layerManager) {
  const clamped = clampPointRadius(radius)

  if (layerManager) {
    for (const name of ["points", "anomalies", "points-mvt"]) {
      layerManager.getLayer(name)?.setPointRadius?.(clamped)
    }
    return
  }

  const strokeWidth = getPointStrokeWidth(clamped)
  for (const layerId of ["points", "anomalies", "points-mvt"]) {
    if (!map.getLayer(layerId)) continue
    if (
      layerId === "points-mvt" &&
      map.getPaintProperty(layerId, "circle-opacity") === 0
    ) {
      continue
    }
    map.setPaintProperty(layerId, "circle-radius", clamped)
    map.setPaintProperty(layerId, "circle-stroke-width", strokeWidth)
  }
}
