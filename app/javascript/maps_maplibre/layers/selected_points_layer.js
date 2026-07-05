import { BaseLayer } from "./base_layer"
import { parseTimestamp } from "../utils/geojson_transformers"

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
   * Min/max timestamps of selected points
   * @returns {{ start: Date, end: Date }|null}
   */
  getTimeRange() {
    return SelectedPointsLayer.timeRangeFromFeatures(this.data?.features)
  }

  /**
   * Average coordinates of selected points (for visit placement)
   * @returns {{ lat: number, lng: number }|null}
   */
  getCentroid() {
    return SelectedPointsLayer.centroidFromFeatures(this.data?.features)
  }

  /**
   * Group selected points by track_id for split visit creation.
   * @returns {Array<{ groupKey: string, trackId: number|null, timeRange: { start: Date, end: Date }, centroid: { lat: number, lng: number }, pointCount: number }>}
   */
  getTrackGroups() {
    if (!this.data?.features?.length) return []

    const groups = new Map()

    for (const feature of this.data.features) {
      const trackId = feature.properties?.track_id ?? null
      const groupKey = SelectedPointsLayer.trackGroupKey(trackId)

      if (!groups.has(groupKey)) {
        groups.set(groupKey, { groupKey, trackId, features: [] })
      }
      groups.get(groupKey).features.push(feature)
    }

    return Array.from(groups.values())
      .map(({ groupKey, trackId, features }) => {
        const timeRange = SelectedPointsLayer.timeRangeFromFeatures(features)
        const centroid = SelectedPointsLayer.centroidFromFeatures(features)
        if (!timeRange || !centroid) return null

        return {
          groupKey,
          trackId,
          timeRange,
          centroid,
          pointCount: features.length,
        }
      })
      .filter(Boolean)
      .sort(
        (a, b) => a.timeRange.start.getTime() - b.timeRange.start.getTime(),
      )
  }

  static trackGroupKey(trackId) {
    return trackId == null ? "none" : String(trackId)
  }

  static timeRangeFromFeatures(features = []) {
    if (!features.length) return null

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

  static centroidFromFeatures(features = []) {
    if (!features.length) return null

    let sumLat = 0
    let sumLng = 0
    let count = 0

    for (const feature of features) {
      const coords = feature.geometry?.coordinates
      if (!coords || coords.length < 2) continue

      sumLng += coords[0]
      sumLat += coords[1]
      count += 1
    }

    if (count === 0) return null
    return { lat: sumLat / count, lng: sumLng / count }
  }
}
