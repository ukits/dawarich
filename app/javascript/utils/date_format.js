/**
 * Date/time display helpers for user-facing labels.
 * Datetime-local inputs and API params still use `YYYY-MM-DDTHH:MM`.
 */

export function formatISODate(date, timeZone) {
  const d = date instanceof Date ? date : new Date(date)
  if (Number.isNaN(d.getTime())) return "Invalid Date"

  return d.toLocaleDateString("en-CA", timeZone ? { timeZone } : undefined)
}

export function formatISOMonth(date) {
  const d = date instanceof Date ? date : new Date(date)
  if (Number.isNaN(d.getTime())) return "Invalid Date"

  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`
}

export function formatISOMonthParts(year, monthIndex) {
  return `${year}-${String(monthIndex + 1).padStart(2, "0")}`
}

export function formatISODateWithWeekday(date, timeZone) {
  const d =
    date instanceof Date
      ? date
      : new Date(`${String(date).slice(0, 10)}T00:00:00`)
  if (Number.isNaN(d.getTime())) return "Invalid Date"

  const weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  const iso = formatISODate(d, timeZone)
  return `${iso} (${weekdays[d.getDay()]})`
}

export function formatISODateTime(date, timeZone, { seconds = false } = {}) {
  const d = date instanceof Date ? date : new Date(date)
  if (Number.isNaN(d.getTime())) return "Invalid Date"

  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: timeZone || undefined,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: seconds ? "2-digit" : undefined,
    hour12: false,
  }).formatToParts(d)

  const get = (type) => parts.find((p) => p.type === type)?.value
  const base = `${get("year")}-${get("month")}-${get("day")} ${get("hour")}:${get("minute")}`

  return seconds ? `${base}:${get("second")}` : base
}

export function formatISOTime(date, timeZone, { seconds = false } = {}) {
  return formatISODateTime(date, timeZone, { seconds }).split(" ")[1] ?? ""
}
