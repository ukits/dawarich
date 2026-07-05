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
    if (!this.data?.features?.length) return null

    let start = null
    let end = null

    for (const feature of this.data.features) {
      const date = parseTimestamp(feature.properties?.timestamp)
      if (!date) continue

      if (!start || date < start) start = date
      if (!end || date > end) end = date
    }

    if (!start || !end) return null
    return { start, end }
  }
}
