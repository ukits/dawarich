import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"
import test from "node:test"

async function loadModule(relativePath, dependencies = "") {
  const source = await readFile(new URL(relativePath, import.meta.url), "utf8")
  const withoutImports = source.replace(/^import[\s\S]*?from "[^"]+"\n/gm, "")
  const url = `data:text/javascript;base64,${Buffer.from(
    `${dependencies}\n${withoutImports}`,
  ).toString("base64")}`

  return import(url)
}

const { SelectedPointsLayer } = await loadModule(
  "../../app/javascript/maps_maplibre/layers/selected_points_layer.js",
  `
    class BaseLayer {}
    function parseTimestamp(timestamp) {
      if (timestamp == null || timestamp === "") return null
      const date = new Date(timestamp)
      return Number.isNaN(date.getTime()) ? null : date
    }
  `,
)

function feature(id, timestamp, trackId, visitId = null) {
  return {
    type: "Feature",
    geometry: { type: "Point", coordinates: [127.0, 37.5] },
    properties: { id, timestamp, track_id: trackId, visit_id: visitId },
  }
}

function groupsFrom(features) {
  const layer = Object.create(SelectedPointsLayer.prototype)
  layer.data = { type: "FeatureCollection", features }
  return layer.getTrackGroups()
}

function label(group) {
  const fmt = (date) => date.toISOString().slice(11, 16)
  return `${group.groupKey}:${group.trackId}:${fmt(group.timeRange.start)}-${fmt(group.timeRange.end)}:${group.pointCount}`
}

test("non-track stays on either side of a track stay separate groups", () => {
  const groups = groupsFrom([
    feature(1, "2026-11-07T23:47:00Z", null),
    feature(2, "2026-11-07T08:00:00Z", 11),
    feature(3, "2026-11-07T00:01:00Z", null),
    feature(4, "2026-11-07T18:00:00Z", 22),
    feature(5, "2026-11-07T12:30:00Z", null),
  ])

  assert.deepEqual(groups.map(label), [
    "none-0:null:00:01-00:01:1",
    "11:11:08:00-08:00:1",
    "none-1:null:12:30-12:30:1",
    "22:22:18:00-18:00:1",
    "none-2:null:23:47-23:47:1",
  ])
})

test("separate home visits stay apart, and a long gap inside one visit does not", () => {
  const groups = groupsFrom([
    feature(1, "2026-11-07T00:01:00Z", null, 16196),
    feature(2, "2026-11-07T09:59:00Z", null, 16196),
    feature(3, "2026-11-07T11:56:00Z", null, 16196),
    feature(4, "2026-11-07T12:50:00Z", null, 16198),
    feature(5, "2026-11-07T18:42:00Z", null, 16198),
    feature(6, "2026-11-07T19:50:00Z", 79984, null),
    feature(7, "2026-11-07T21:39:00Z", null, 16200),
    feature(8, "2026-11-07T23:47:00Z", null, 16200),
  ])

  assert.deepEqual(groups.map(label), [
    "none-0:null:00:01-11:56:3",
    "none-1:null:12:50-18:42:2",
    "79984:79984:19:50-19:50:1",
    "none-2:null:21:39-23:47:2",
  ])
})

test("points of one track stay a single group around a non-track stay", () => {
  const groups = groupsFrom([
    feature(1, "2026-11-07T18:00:00Z", 11),
    feature(2, "2026-11-07T08:00:00Z", 11),
    feature(3, "2026-11-07T12:30:00Z", null),
  ])

  assert.deepEqual(groups.map(label), [
    "11:11:08:00-18:00:2",
    "none:null:12:30-12:30:1",
  ])
})
