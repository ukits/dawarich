import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"
import test from "node:test"

const geometrySource = await readFile(
  new URL(
    "../../app/javascript/maps_maplibre/utils/geometry.js",
    import.meta.url,
  ),
  "utf8",
)
const transformersSource = await readFile(
  new URL(
    "../../app/javascript/maps_maplibre/utils/geojson_transformers.js",
    import.meta.url,
  ),
  "utf8",
)
const withoutImports = transformersSource.replace(
  /^import[\s\S]*?from "[^"]+"\n/gm,
  "",
)
const i18nStubs = `
const formatDate = (value, { timeZone } = {}) => new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" }).format(value)
const formatTime = (value, { timeZone } = {}) => new Intl.DateTimeFormat("en-GB", { timeZone, hour: "2-digit", minute: "2-digit", hourCycle: "h23" }).format(value)
const formatDateTime = (value, options) => formatDate(value, options) + ", " + formatTime(value, options)
`
const combinedSource = `${i18nStubs}\n${geometrySource}\n${withoutImports}`
const moduleUrl = `data:text/javascript;base64,${Buffer.from(combinedSource).toString("base64")}`
const {
  pointsToGeoJSON,
  simplifyPointsForRendering,
  parseTimestamp,
  formatDateTimeRange,
} = await import(moduleUrl)

function point(id, latitude, longitude, timestamp) {
  return { id, latitude, longitude, timestamp }
}

test("simplified point rendering keeps first point and drops nearby dense points", () => {
  const points = [
    point(1, 52.52, 13.405, 1_700_000_000),
    point(2, 52.52001, 13.40501, 1_700_000_010),
    point(3, 52.52002, 13.40502, 1_700_000_015),
    point(4, 52.521, 13.405, 1_700_000_016),
  ]

  assert.deepEqual(
    simplifyPointsForRendering(points).map((p) => p.id),
    [1, 4],
  )
})

test("simplified point rendering drops nearby points regardless of time gap", () => {
  const points = [
    point(1, 52.52, 13.405, 1_700_000_000),
    point(2, 52.52001, 13.40501, 1_700_086_400),
  ]

  assert.deepEqual(
    pointsToGeoJSON(points, { simplified: true }).features.map(
      (feature) => feature.properties.id,
    ),
    [1],
  )
})

test("simplified point rendering measures distance from the last kept point", () => {
  const points = [
    point(1, 52.52, 13.405, 1_700_000_000),
    point(2, 52.52027, 13.405, 1_700_000_010),
    point(3, 52.52054, 13.405, 1_700_000_020),
  ]

  assert.deepEqual(
    simplifyPointsForRendering(points).map((p) => p.id),
    [1, 3],
  )
})

test("raw point rendering keeps dense points", () => {
  const points = [
    point(1, 52.52, 13.405, 1_700_000_000),
    point(2, 52.52001, 13.40501, 1_700_000_010),
  ]

  assert.deepEqual(
    pointsToGeoJSON(points).features.map((feature) => feature.properties.id),
    [1, 2],
  )
})

test("features carry the point's track and visit, or null when it has none", () => {
  const [linked, loose] = pointsToGeoJSON([
    { ...point(1, 52.52, 13.405, 1_700_000_000), track_id: 7, visit_id: 9 },
    point(2, 52.53, 13.405, 1_700_000_010),
  ]).features

  assert.equal(linked.properties.track_id, 7)
  assert.equal(linked.properties.visit_id, 9)
  assert.equal(loose.properties.track_id, null)
  assert.equal(loose.properties.visit_id, null)
})

test("parseTimestamp accepts unix seconds and rejects invalid values", () => {
  assert.equal(
    parseTimestamp(1_700_000_000)?.toISOString(),
    "2023-11-14T22:13:20.000Z",
  )
  assert.equal(parseTimestamp(null), null)
  assert.equal(parseTimestamp(""), null)
  assert.equal(parseTimestamp("not a date"), null)
})

test("formatDateTimeRange shortens the end to its time on the same day", () => {
  assert.equal(
    formatDateTimeRange(
      new Date("2026-07-05T09:00:00Z"),
      new Date("2026-07-05T18:30:00Z"),
      "UTC",
    ),
    "2026-07-05, 09:00 - 18:30",
  )
})

test("formatDateTimeRange repeats the end date when the range crosses days", () => {
  assert.equal(
    formatDateTimeRange(
      new Date("2026-07-05T09:00:00Z"),
      new Date("2026-07-06T18:30:00Z"),
      "UTC",
    ),
    "2026-07-05, 09:00 - 2026-07-06, 18:30",
  )
})

test("formatDateTimeRange collapses an instant to one date and time", () => {
  const instant = new Date("2026-07-05T09:00:00Z")

  assert.equal(
    formatDateTimeRange(instant, instant, "UTC"),
    "2026-07-05, 09:00",
  )
})

test("formatDateTimeRange reads the days in the given timezone", () => {
  assert.equal(
    formatDateTimeRange(
      new Date("2026-07-05T20:00:00Z"),
      new Date("2026-07-05T22:00:00Z"),
      "Asia/Seoul",
    ),
    "2026-07-06, 05:00 - 07:00",
  )
})

test("formatDateTimeRange is empty without both ends", () => {
  assert.equal(formatDateTimeRange(null, new Date(), "UTC"), "")
})
