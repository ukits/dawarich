import { formatDate, formatTime, translate } from "i18n"
import { escapeAttribute } from "../utils/geojson_transformers"

/**
 * Pending card for a stay found in the selected area that has no visit yet.
 * Shown above the existing visit cards; its Create button opens the Create
 * Visit form prefilled from that group's points.
 */
export class PendingVisitCard {
  /**
   * @param {{ groupKey: string, trackId: number|null, timeRange: { start: Date, end: Date }, pointCount: number }} group
   * @param {{ timezone?: string }} options
   * @returns {string} HTML string, or "" when the group has no time range
   */
  static create(group, { timezone } = {}) {
    const { start, end } = PendingVisitCard.displayRange(group.timeRange)
    if (!start) return ""

    const options = { timeZone: timezone }
    const minutes = Math.max(1, Math.round((end - start) / 60000))
    const hours = Math.floor(minutes / 60)
    const durationStr =
      hours > 0
        ? translate("map_info.duration_hours_minutes", {
            hours,
            minutes: minutes % 60,
          })
        : translate("map_info.duration_minutes", { minutes })

    return `
      <div class="pending-visit-card card bg-base-100 border-dashed border-2 border-base-content/20 mb-2 hover:shadow-md transition-all"
           data-visit-pending-group="${escapeAttribute(group.groupKey)}">
        <div class="card-body p-3">
          <div class="text-xs text-base-content/70 space-y-1">
            <div class="truncate">${formatDate(start, options)}</div>
            <div class="truncate">${formatTime(start, options)} - ${formatTime(end, options)}</div>
            <div class="truncate">${durationStr}</div>
            <div class="truncate">${translate("selection.points", { count: group.pointCount })}</div>
            ${
              group.trackId == null
                ? ""
                : `<div class="truncate">${translate("visits.track_id", { id: group.trackId })}</div>`
            }
          </div>
          <div class="card-actions justify-end mt-3">
            <button type="button" class="btn btn-xs btn-primary" data-visit-create-from-points="${escapeAttribute(group.groupKey)}">
              ${translate("visits.create")}
            </button>
          </div>
        </div>
      </div>
    `
  }

  /**
   * A stay seen at a single instant still needs a positive duration, as the
   * Create Visit form requires the end to be after the start.
   * @param {{ start: Date, end: Date }|null} timeRange
   * @returns {{ start: Date|null, end: Date|null }}
   */
  static displayRange(timeRange) {
    if (!timeRange?.start || !timeRange?.end) return { start: null, end: null }

    const { start } = timeRange
    const end =
      timeRange.end > start
        ? timeRange.end
        : new Date(start.getTime() + 60 * 1000)
    return { start, end }
  }
}
