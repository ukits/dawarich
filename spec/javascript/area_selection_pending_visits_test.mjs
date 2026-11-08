import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"
import test from "node:test"

globalThis.requestAnimationFrame = () => {}

async function load(relativePath, stubs = "") {
  let source = await readFile(new URL(relativePath, import.meta.url), "utf8")
  source = source.replace(/^import[\s\S]*?from "[^"]+"\n/gm, "")
  return import(
    `data:text/javascript;base64,${Buffer.from(stubs + source).toString("base64")}`
  )
}

const { PendingVisitCard } = await load(
  "../../app/javascript/maps_maplibre/components/pending_visit_card.js",
  `
    const translate = (key, params = {}) => key + JSON.stringify(params)
    const formatDate = (value) => new Date(value).toISOString().slice(0, 10)
    const formatTime = (value) => new Date(value).toISOString().slice(11, 16)
    const escapeAttribute = (value) => String(value)
  `,
)

const { AreaSelectionManager } = await load(
  "../../app/javascript/controllers/maps/maplibre/area_selection_manager.js",
  `
    const translate = (key, params = {}) => key + JSON.stringify(params)
    const Toast = { info() {}, success() {}, warning() {}, error() {} }
    const pointsToGeoJSON = () => ({ type: "FeatureCollection", features: [] })
    const anomaliesVisible = () => false
    const formatDateTimeRange = (start, end) =>
      start.toISOString().slice(0, 16) + "/" + end.toISOString().slice(0, 16)
    const VisitCard = { create: (visit) => '<div data-visit-card="' + visit.id + '"></div>' }
    const PendingVisitCard = {
      create: (group) => '<div data-visit-pending-group="' + group.groupKey + '"></div>',
      displayRange: (range) => ({ start: range.start, end: range.end }),
    }
  `,
)

function group(overrides = {}) {
  return {
    groupKey: "none",
    trackId: null,
    timeRange: {
      start: new Date("2026-11-07T08:00:00Z"),
      end: new Date("2026-11-07T09:30:00Z"),
    },
    centroid: { lat: 37.5, lng: 127.0 },
    pointCount: 12,
    ...overrides,
  }
}

test("a pending card shows the stay's range and a create button for its group", () => {
  const html = PendingVisitCard.create(group({ groupKey: "11", trackId: 11 }))

  assert.match(html, /data-visit-pending-group="11"/)
  assert.match(html, /data-visit-create-from-points="11"/)
  assert.match(html, /08:00 - 09:30/)
  assert.match(html, /visits\.track_id\{"id":11\}/)
  assert.match(html, /selection\.points\{"count":12\}/)
})

test("a pending card for a stay without a track omits the track line", () => {
  assert.doesNotMatch(PendingVisitCard.create(group()), /visits\.track_id/)
})

test("a pending card for a single instant still spans a positive duration", () => {
  const instant = new Date("2026-11-07T08:00:00Z")
  const html = PendingVisitCard.create(
    group({ timeRange: { start: instant, end: instant } }),
  )

  assert.match(html, /08:00 - 08:01/)
})

test("a pending card without a time range renders nothing", () => {
  assert.equal(PendingVisitCard.create(group({ timeRange: null })), "")
})

function buildManager({ groups, timeRange = null }) {
  const opened = []
  const toasts = []
  const controller = {
    map: {},
    timezoneValue: "Asia/Seoul",
    hasSelectedVisitsContainerTarget: true,
    selectedVisitsContainerTarget: {
      innerHTML: "",
      classList: { add() {}, remove() {} },
    },
    element: { querySelectorAll: () => [] },
    visitsManager: {
      openVisitCreationModal: (lat, lng, draft) => {
        opened.push({ lat, lng, draft })
        return "form"
      },
    },
  }
  const manager = new AreaSelectionManager(controller)
  manager.selectedPointsLayer = {
    getTrackGroups: () => groups,
    getTimeRange: () => timeRange,
  }
  manager.updateBulkActions = () => {}
  return { manager, controller, opened, toasts }
}

test("rendering the area lists a pending card for every stay before the visits", () => {
  const { manager, controller } = buildManager({
    groups: [group({ groupKey: "11", trackId: 11 }), group()],
  })

  manager.renderVisitsInArea([{ id: 5 }])

  const html = controller.selectedVisitsContainerTarget.innerHTML
  assert.equal(html.match(/data-visit-pending-group=/g).length, 2)
  assert.ok(
    html.indexOf("data-visit-pending-group") < html.indexOf("data-visit-card"),
  )
})

test("rendering an area with points but no visits still shows the pending cards", () => {
  const { manager, controller } = buildManager({ groups: [group()] })

  manager.renderVisitsInArea([])

  assert.match(
    controller.selectedVisitsContainerTarget.innerHTML,
    /data-visit-pending-group="none"/,
  )
})

test("rendering an area with neither points nor visits empties the panel", () => {
  const { manager, controller } = buildManager({ groups: [] })
  controller.selectedVisitsContainerTarget.innerHTML = "stale"

  manager.renderVisitsInArea([])

  assert.equal(controller.selectedVisitsContainerTarget.innerHTML, "")
})

test("creating from a pending card opens the form with that stay's draft", () => {
  const { manager, opened } = buildManager({
    groups: [
      group({ groupKey: "11", trackId: 11 }),
      group({
        groupKey: "none",
        centroid: { lat: 36.1, lng: 128.2 },
        timeRange: {
          start: new Date("2026-11-07T12:00:00Z"),
          end: new Date("2026-11-07T13:00:00Z"),
        },
      }),
    ],
  })

  manager.createVisitFromSelectedPoints("none")

  assert.deepEqual(opened, [
    {
      lat: 36.1,
      lng: 128.2,
      draft: {
        lat: 36.1,
        lng: 128.2,
        startedAt: "2026-11-07T12:00:00.000Z",
        endedAt: "2026-11-07T13:00:00.000Z",
      },
    },
  ])
})

test("the delete label carries the point count and the selection's time range", () => {
  const { manager } = buildManager({
    groups: [],
    timeRange: {
      start: new Date("2026-11-07T08:00:00Z"),
      end: new Date("2026-11-07T18:30:00Z"),
    },
  })

  assert.equal(
    manager.formatDeletePointsButtonText(3),
    'selection.delete_points{"count":3} (2026-11-07T08:00/2026-11-07T18:30)',
  )
})

test("the delete label is just the count when no time range is known", () => {
  const { manager } = buildManager({ groups: [], timeRange: null })

  assert.equal(
    manager.formatDeletePointsButtonText(3),
    'selection.delete_points{"count":3}',
  )
})
