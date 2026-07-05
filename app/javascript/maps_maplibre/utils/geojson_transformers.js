/**
 * Transform points array to GeoJSON FeatureCollection
 * @param {Array} points - Array of point objects from API
 * @returns {Object} GeoJSON FeatureCollection
 */
export function pointsToGeoJSON(points) {
  return {
    type: "FeatureCollection",
    features: points.map((point) => ({
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [point.longitude, point.latitude],
      },
      properties: {
        id: point.id,
        timestamp: point.timestamp,
        altitude: point.altitude,
        battery: point.battery,
        accuracy: point.accuracy,
        velocity: point.velocity,
        country_name: point.country_name,
      },
    })),
  }
}

/**
 * Parse a point timestamp into a Date
 * @param {number|string} timestamp - Unix timestamp (seconds) or ISO 8601 string
 * @returns {Date|null} Parsed date, or null when invalid
 */
export function parseTimestamp(timestamp) {
  if (timestamp == null || timestamp === "") return null

  let date
  if (typeof timestamp === "string") {
    date = new Date(timestamp)
  } else if (timestamp < 10000000000) {
    date = new Date(timestamp * 1000)
  } else {
    date = new Date(timestamp)
  }

  return Number.isNaN(date.getTime()) ? null : date
}

/**
 * Format timestamp for display
 * @param {number|string} timestamp - Unix timestamp (seconds) or ISO 8601 string
 * @param {string} timezone - IANA timezone string (e.g., 'Europe/Berlin')
 * @returns {string} Formatted date/time
 */
export function formatTimestamp(timestamp, timezone = "UTC") {
  const date = parseTimestamp(timestamp)
  if (!date) return ""

  return date.toLocaleString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
    timeZone: timezone,
  })
}

/**
 * Format timestamp as time only (HH:MM)
 * @param {number|string} timestamp - Unix timestamp (seconds) or ISO 8601 string
 * @param {string} timezone - IANA timezone string (e.g., 'Europe/Berlin')
 * @returns {string} Formatted time (e.g., "14:30")
 */
export function formatTimeOnly(timestamp, timezone = "UTC") {
  const date = parseTimestamp(timestamp)
  if (!date) return "--:--"

  return date.toLocaleTimeString("en-US", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZone: timezone,
  })
}

/**
 * Format a date as YYYY-MM-DD hh:mm in the given timezone
 * @param {Date} date
 * @param {string} timezone - IANA timezone string (e.g., 'Europe/Berlin')
 * @returns {string} Formatted date/time (e.g., "2026-07-05 09:00")
 */
export function formatDateTimeLabel(date, timezone = "UTC") {
  if (!date) return ""

  const options = {
    timeZone: timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }
  const parts = new Intl.DateTimeFormat("en-CA", options).formatToParts(date)
  const get = (type) => parts.find((p) => p.type === type)?.value || "00"
  return `${get("year")}-${get("month")}-${get("day")} ${get("hour")}:${get("minute")}`
}

/**
 * Format a date/time range for compact UI labels
 * @param {Date} start
 * @param {Date} end
 * @param {string} timezone - IANA timezone string (e.g., 'Europe/Berlin')
 * @returns {string} Formatted range (e.g., "2026-07-05 09:00 - 18:30" or "2026-07-05 09:00 - 2026-07-06 18:30")
 */
export function formatDateTimeRange(start, end, timezone = "UTC") {
  if (!start || !end) return ""

  const startLabel = formatDateTimeLabel(start, timezone)
  const endLabel = formatDateTimeLabel(end, timezone)

  if (!startLabel || !endLabel) return ""
  if (startLabel === endLabel) return startLabel

  const startDate = startLabel.slice(0, 10)
  const endDate = endLabel.slice(0, 10)

  if (startDate === endDate) {
    return `${startLabel} - ${endLabel.slice(11)}`
  }

  return `${startLabel} - ${endLabel}`
}

/**
 * Escape HTML special characters to prevent XSS when using innerHTML.
 * @param {*} value - Value to escape (coerced to string)
 * @returns {string} HTML-safe string
 */
export function escapeHtml(value) {
  if (value == null) return ""
  const str = String(value)
  const div = document.createElement("div")
  div.textContent = str
  return div.innerHTML
}
