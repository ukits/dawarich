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
const dateFormatSource = await readFile(
  new URL("../../app/javascript/utils/date_format.js", import.meta.url),
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
const dateFormatWithoutExports = dateFormatSource.replace(
  /^export /gm,
  "",
)
const combinedSource = `${geometrySource}\n${dateFormatWithoutExports}\n${withoutImports}`
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

test("pointsToGeoJSON carries numeric latitude and longitude in properties", () => {
  const geojson = pointsToGeoJSON([
    point(1, 52.520001, 13.405001, 1_700_000_000),
  ])
  const props = geojson.features[0].properties

  assert.equal(props.latitude, 52.520001)
  assert.equal(props.longitude, 13.405001)
})

test("parseTimestamp accepts unix seconds and rejects invalid values", () => {
  const date = parseTimestamp(1_700_000_000)
  assert.equal(date?.toISOString(), "2023-11-14T22:13:20.000Z")
  assert.equal(parseTimestamp(null), null)
  assert.equal(parseTimestamp(""), null)
})

test("formatDateTimeRange shortens end time on the same day", () => {
  const start = new Date("2026-07-05T09:00:00Z")
  const end = new Date("2026-07-05T18:30:00Z")

  assert.equal(
    formatDateTimeRange(start, end, "UTC"),
    "2026-07-05 09:00 - 18:30",
  )
})

test("formatDateTimeRange repeats full end label across days", () => {
  const start = new Date("2026-07-05T09:00:00Z")
  const end = new Date("2026-07-06T18:30:00Z")

  assert.equal(
    formatDateTimeRange(start, end, "UTC"),
    "2026-07-05 09:00 - 2026-07-06 18:30",
  )
})
