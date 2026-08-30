import { translate } from "i18n"
import { formatISODateTime } from "utils/date_format"

// MapLibre serializes nested GeoJSON property values to JSON strings on
// queried features — `center` arrives as "[lng,lat]", not an array.
function parsedCenter(props) {
  if (Array.isArray(props.center)) return props.center
  if (typeof props.center !== "string") return null

  try {
    const parsed = JSON.parse(props.center)
    return Array.isArray(parsed) ? parsed : null
  } catch {
    return null
  }
}

export function buildHexagonPopup(props, timezone) {
  const startDateTime = props.earliest_point
    ? formatISODateTime(props.earliest_point, timezone)
    : translate("common.not_available")
  const endDateTime = props.latest_point
    ? formatISODateTime(props.latest_point, timezone)
    : translate("common.not_available")
  const center = parsedCenter(props)

  return `
    <div style="font-size: 12px; line-height: 1.6; max-width: 300px;">
      <strong style="color: #3388ff;">📍 ${translate("map_info.location_data")}</strong><br>
      <div style="margin: 4px 0;">
        <strong>${translate("map_info.points")}:</strong> ${props.point_count || 0}
      </div>
      ${
        props.h3_index
          ? `
      <div style="margin: 4px 0;">
        <strong>${translate("map_info.h3_index")}:</strong><br>
        <code style="font-size: 10px; background: #f5f5f5; padding: 2px;">${props.h3_index}</code>
      </div>
      `
          : ""
      }
      <div style="margin: 4px 0;">
        <strong>${translate("map_info.time_range")}:</strong><br>
        <small>${startDateTime} → ${endDateTime}</small>
      </div>
      ${
        center
          ? `
      <div style="margin: 4px 0;">
        <strong>${translate("map_info.center")}:</strong><br>
        <small>${Number(center[0]).toFixed(6)}, ${Number(center[1]).toFixed(6)}</small>
      </div>
      `
          : ""
      }
    </div>
  `
}
