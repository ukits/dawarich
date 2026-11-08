import { parseTimestamp } from "../utils/geojson_transformers"
import { BaseLayer } from "./base_layer"

/**
 * Layer for displaying selected points with distinct styling
 */
export class SelectedPointsLayer extends BaseLayer {
  constructor(map, options = {}) {
    super(map, { id: "selected-points", ...options })
    this.pointIds = []
  }

  getSourceConfig() {
    return {
      type: "geojson",
      data: this.data || {
        type: "FeatureCollection",
        features: [],
      },
    }
  }

  getLayerConfigs() {
    return [
      // Outer circle (highlight)
      {
        id: `${this.id}-highlight`,
        type: "circle",
        source: this.sourceId,
        paint: {
          "circle-radius": 8,
          "circle-color": "#ef4444",
          "circle-opacity": 0.3,
        },
      },
      // Inner circle (selected point)
      {
        id: this.id,
        type: "circle",
        source: this.sourceId,
        paint: {
          "circle-radius": 5,
          "circle-color": "#ef4444",
          "circle-stroke-width": 2,
          "circle-stroke-color": "#ffffff",
        },
      },
    ]
  }

  /**
   * Get layer IDs for this layer
   */
  getLayerIds() {
    return [`${this.id}-highlight`, this.id]
  }

  /**
   * Update selected points and store their IDs
   */
  updateSelectedPoints(geojson) {
    this.data = geojson

    // Extract point IDs
    this.pointIds = geojson.features.map((f) => f.properties.id)

    // Update map source
    this.update(geojson)

    console.log(
      "[SelectedPointsLayer] Updated with",
      this.pointIds.length,
      "points",
    )
  }

  /**
   * Get IDs of selected points
   */
  getSelectedPointIds() {
    return this.pointIds
  }

  /**
   * Clear selected points
   */
  clearSelection() {
    this.pointIds = []
    this.update({
      type: "FeatureCollection",
      features: [],
    })
  }

  /**
   * Get count of selected points
   */
  getCount() {
    return this.pointIds.length
  }

  /**
   * Min/max timestamps of the selected points
   * @returns {{ start: Date, end: Date }|null}
   */
  getTimeRange() {
    return SelectedPointsLayer.timeRangeFromFeatures(this.data?.features)
  }

  /**
   * Group the selection into candidate stays for pending Create Visit cards.
   * Points on a track stay one group per track_id. Points with no track are
   * split into time-ordered runs, and a run also breaks when visit_id changes.
   * A long gap inside one visit (asleep at home) stays one stay. A later visit
   * stays separate even when the track points between them are outside the
   * rectangle.
   * @returns {Array<{ groupKey: string, trackId: number|null, timeRange: { start: Date, end: Date }, centroid: { lat: number, lng: number }, pointCount: number }>}
   */
  getTrackGroups() {
    if (!this.data?.features?.length) return []

    const features = [...this.data.features].sort(
      (a, b) =>
        SelectedPointsLayer.timestampMs(a) - SelectedPointsLayer.timestampMs(b),
    )

    const trackGroups = new Map()
    const noneRuns = []
    let openNone = null
    let openRunKey = null

    for (const feature of features) {
      const trackId = feature.properties?.track_id ?? null
      if (trackId == null) {
        const runKey = SelectedPointsLayer.noneRunKey(feature)
        if (!openNone || openRunKey !== runKey) {
          openNone = []
          openRunKey = runKey
          noneRuns.push(openNone)
        }
        openNone.push(feature)
        continue
      }

      openNone = null
      openRunKey = null
      const groupKey = String(trackId)
      if (!trackGroups.has(groupKey)) {
        trackGroups.set(groupKey, { groupKey, trackId, features: [] })
      }
      trackGroups.get(groupKey).features.push(feature)
    }

    const groups = [
      ...trackGroups.values(),
      ...noneRuns.map((run, index) => ({
        groupKey: noneRuns.length === 1 ? "none" : `none-${index}`,
        trackId: null,
        features: run,
      })),
    ]

    return groups
      .map(({ groupKey, trackId, features: run }) => {
        const timeRange = SelectedPointsLayer.timeRangeFromFeatures(run)
        const centroid = SelectedPointsLayer.centroidFromFeatures(run)
        if (!timeRange || !centroid) return null

        return {
          groupKey,
          trackId,
          timeRange,
          centroid,
          pointCount: run.length,
        }
      })
      .filter(Boolean)
      .sort((a, b) => a.timeRange.start.getTime() - b.timeRange.start.getTime())
  }

  static noneRunKey(feature) {
    const visitId = feature.properties?.visit_id ?? null
    return visitId == null ? "novisit" : `visit:${visitId}`
  }

  static timestampMs(feature) {
    return (
      parseTimestamp(feature.properties?.timestamp)?.getTime() ??
      Number.POSITIVE_INFINITY
    )
  }

  static timeRangeFromFeatures(features = []) {
    if (!features?.length) return null

    let start = null
    let end = null

    for (const feature of features) {
      const date = parseTimestamp(feature.properties?.timestamp)
      if (!date) continue

      if (!start || date < start) start = date
      if (!end || date > end) end = date
    }

    if (!start || !end) return null
    return { start, end }
  }

  static coordinateFromFeature(feature) {
    const coords = feature.geometry?.coordinates
    if (coords?.length >= 2) {
      const rawLng = coords[0]
      const rawLat = coords[1]
      if (rawLng != null && rawLng !== "" && rawLat != null && rawLat !== "") {
        const lng = Number(rawLng)
        const lat = Number(rawLat)
        if (Number.isFinite(lat) && Number.isFinite(lng)) {
          return { lat, lng }
        }
      }
    }

    const props = feature.properties ?? {}
    const rawPropLat = props.latitude
    const rawPropLng = props.longitude
    if (
      rawPropLat != null &&
      rawPropLat !== "" &&
      rawPropLng != null &&
      rawPropLng !== ""
    ) {
      const lat = Number(rawPropLat)
      const lng = Number(rawPropLng)
      if (Number.isFinite(lat) && Number.isFinite(lng)) {
        return { lat, lng }
      }
    }

    return null
  }

  static centroidFromFeatures(features = []) {
    if (!features?.length) return null

    let sumLat = 0
    let sumLng = 0
    let count = 0

    for (const feature of features) {
      const coordinate = SelectedPointsLayer.coordinateFromFeature(feature)
      if (!coordinate) continue

      sumLng += coordinate.lng
      sumLat += coordinate.lat
      count += 1
    }

    if (count === 0) return null
    return { lat: sumLat / count, lng: sumLng / count }
  }
}
