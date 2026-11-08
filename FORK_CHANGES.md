# Fork 변경 카탈로그 (FORK_CHANGES)

이 문서는 **ukits/dawarich가 upstream(Freika/dawarich) 대비 유지하는 기능·정책**의 장기 카탈로그다.

- **의도(무엇을/왜)** 가 1급 정보다. 커밋 해시는 참고용이며, upstream 동기화 때마다 cherry-pick 대상이 아니다.
- upstream이 올라갈 때마다 [docs/upstream-sync/PROCESS.md](docs/upstream-sync/PROCESS.md)에 따라 이 목록을 **기능 단위로 재검토**하고, 결과는 **사이클 로그에 누적**한다.
- 시간순 서술·사용자 관점 릴리즈 노트는 [HISTORY.md](HISTORY.md)를 본다.

| 문서 | 역할 |
|------|------|
| **이 파일** | 살아있는 기능 목록 (ID 고정, 상태·이력 갱신) |
| [PROCESS.md](docs/upstream-sync/PROCESS.md) | 반복 사용 동기화 절차 |
| [cycles/](docs/upstream-sync/cycles/) | 사이클별 분석·결정·진행 로그 (이력 축적) |
| [HISTORY.md](HISTORY.md) | 날짜별 서술형 변경 히스토리 |

---

## 메타

| 항목 | 값 |
|------|-----|
| 최초 fork 기준 | `7b877f9` — upstream **1.9.2** (2026-06-25) |
| 작성자 | BYUN, SungUk |
| 현재 기능 베이스 | `sync/1.14.0` @ `9ffd211` — upstream **1.14.0** 위 이식 (참고) |
| 작업 중 베이스 | `sync/1.22.0` — upstream **1.22.0** (`0ac68e183`) |
| 최근 닫힌 사이클 | [2026-08 · 1.9.2 → 1.14.0](docs/upstream-sync/cycles/2026-08-1.9.2-to-1.14.0.md) |
| 열린 동기화 사이클 | [2026-11 · 1.14.0 → 1.22.0](docs/upstream-sync/cycles/2026-11-1.14.0-to-1.22.0.md) |

### 상태 값

| 상태 | 의미 |
|------|------|
| `live` | 현재 fork 메인라인에 존재·유지 중 |
| `pending` | 열린 sync 사이클에서 재검토·재이식 대기 |
| `adapted` | 최신 upstream 위에 **변형**해 이식 완료 |
| `ported` | 최신 upstream 위에 의도 그대로 이식 완료 |
| `dropped` | 의식적으로 포기 |
| `superseded` | upstream이 동등/대체 기능을 제공해 **코드 이식 불필요** (대체 버전을 상태/사이클에 기록). 사이클에서는 **검증·테스트는 수행** |
| `defer` | 이번 사이클에서 나중으로 미룸 |

새 fork 기능을 넣을 때: 아래 표에 **새 ID** 행을 추가하고 `live`로 둔다.
sync 사이클을 열면 해당 기능들을 `pending`으로 두고, 끝나면 `ported`/`adapted`/`dropped`/`superseded`로 갱신한다.

---

## 기능 목록

ID는 바꾸지 않는다. 폐기해도 행은 남기고 상태만 `dropped`/`superseded`로 둔다.
「원본 커밋」은 최초 fork 구현 참고, 「이식 커밋」은 `sync/1.14.0` 기준이다.

### 개발 환경

| ID | 제목 | 의도 | 상태 | 주요 경로 (힌트) | 원본 / 이식 |
|----|------|------|------|------------------|-------------|
| F01 | Dev Container · Ruby · vendor | 로컬/컨테이너에서 빌드·실행 가능하게 | `defer` | `.devcontainer/`, `.ruby-version`, `vendor/` | `7b917e0`… / — |

### 지도 · Timeline · Route UI

| ID | 제목 | 의도 | 상태 | 주요 경로 (힌트) | 원본 / 이식 |
|----|------|------|------|------------------|-------------|
| F02 | Point 크기 설정 | 지도 포인트 반경을 설정으로 조절 | `adapted` | `maps_maplibre` MVT / settings | `07b4fbd` / `849bd45` → 1.22: 0457290c9 |
| F03 | Timeline 1열 레이아웃 | ≥1024px에서도 Timeline 1열 | `adapted` | timeline CSS / panel | `7fe3789` / `358c003` → 1.22: 0d8e7887b |
| F04 | Timeline 달력 padding | 달력 여백 | `adapted` | timeline calendar styles | `b2fedf0` / (F03 묶음) → 1.22: 0d8e7887b |
| F05 | 시간 표시 `YYYY-MM-DD hh:mm:ss` | 일시 포맷 통일 | `superseded` @1.18.0 | Settings date/time prefs | `38443a4`… / — (검증) |
| F06 | 달력 일요일 시작 | week start = Sunday | `superseded` @1.18.0 | Settings `first_day_of_week` | `050850e` / — (검증) |
| F07 | Route 구간 시작·끝 시간 | 구간 열에 시각 표시 | `ported` | tracks/segments views·helpers | `108ac89` / `639724a` → 1.22: 6b1c59f32 |

### Places

| ID | 제목 | 의도 | 상태 | 주요 경로 (힌트) | 원본 / 이식 |
|----|------|------|------|------------------|-------------|
| F08 | Places 정렬·visits 수 | 최신순 + 방문 횟수 | `superseded` @1.19.0 | Places list | `1f5d8ae` / — (검증) |
| F09 | Edit Place 삭제 버튼 | 편집 UI에서 삭제 | `superseded` @1.19.0 | map place editor | `d93f8dd` / — (검증) |
| F10 | Places 일괄삭제·검색·Last Visited | 목록 관리 강화 | `superseded` @1.19.0 | places index bulk | `7492f10` / — (검증) |

### Points · Tools (선택 UI)

| ID | 제목 | 의도 | 상태 | 주요 경로 (힌트) | 원본 / 이식 |
|----|------|------|------|------------------|-------------|
| F11 | Tools Delete에 선택 기간 표시 | 삭제 전 구간 확인 | `pending` | selected_points_layer, tools UI | `56adc8e` / `6b1e381` |
| F12 | Points 목록 컬럼·필터 | ID / Visit·Track / 고도 / 필터 | `adapted` | `points#index`, `_point` | `e9111da` / `a2c21d5` → 1.22: c94befc3e |

### Visits · Track (핵심 도메인)

| ID | 제목 | 의도 | 상태 | 주요 경로 (힌트) | 원본 / 이식 |
|----|------|------|------|------------------|-------------|
| F13 | Track별 Visit 추천 카드 | 선택 Points를 Track 단위로 분리 추천 | `pending` | area selection + 1.21 visit draft | `3c60668` / `44fb32e` |
| F14 | Select Area 좌표 0 버그 수정 | 선택 영역 Visit 생성 시 lat/lon 정상 | `superseded` @1.21.0 | `pointsToVisitDraft` | `2428b3e` / — (검증) |
| F15 | Visit Card Place ID 표시 | 카드에 place id | `adapted` | `visit_card.js`, timeline visit row | `b62179f` / `a5898f1` → 1.22: 2e015dfd7 |
| F16 | Place 이름 매칭 (수동 Create) | 50m 내 **동명** Place 재사용, 없으면 생성 | `pending` | `visits/create.rb`, `place_finder.rb` | `66fc9bb` / `c9c6eb6` |
| F17 | 수동 Visit에 `visit_id` 할당 | 시간 범위 Point에 visit_id | `pending` | `visits/create.rb` | `5b9eb1c` / `612afb1` |
| F18 | Visit SideEffects (velocity) | 생성 시 velocity 0, 삭제 시 복원 + Track/Stats 재계산 | `pending` | Visit callbacks / RebuildDay (팁) | `70e7bb0`… / `9ffd211` |
| F19 | Track에서 Visit Point 제외 | visit_id Point는 트랙 제외·경계 분리 | `superseded` @1.22.0 | `Tracks::StationaryStops` | `17c7422` / — (검증; 잔여 갭 defer) |

### 도메인 메모 (F16–F19)

수동 Visit과 Track이 한 세트로 동작하도록 묶인 정책이다.

- **1.14.0 사이클:** `F16 → F17 → F19` 이식. **F18은 defer** (velocity SideEffects — 폐기 아님; F19만으로 Track 분리 UX를 쓰며 필요성 재판단).
- UI 의존 `F13`은 Create 계약(F16/F17) + F14 좌표 인프라 이후 이식 완료.
- **1.22.0 사이클:** `F14`→1.21, `F19`→1.22로 **superseded** (코드 이식 없음, **검증 필수**). `F16`/`F17`/`F18`/`F13`은 보드 승인 후 이식.

핵심 파일(1.14 sync 기준):

- `app/services/visits/create.rb`
- `app/services/visits/place_finder.rb`
- `app/services/tracks/segmentation.rb`
- `app/javascript/maps_maplibre/…` (Select Area · VisitCard)

---

## 카탈로그 갱신 규칙

### fork에 새 기능을 넣을 때

1. 새 ID 행 추가 (`F20`…), 상태 `live`
2. [HISTORY.md](HISTORY.md)에 날짜 섹션 한 블록
3. 커밋 메시지에 `Fxx`를 넣으면 추적이 쉽다

### upstream sync 사이클을 열 때

1. [PROCESS.md](docs/upstream-sync/PROCESS.md)의 「사이클 시작」
2. `docs/upstream-sync/cycles/<주기>.md` 파일 생성
3. 이 카탈로그에서 유지할 기능을 `pending`으로 표시
4. 기능 단위로 리뷰 → 사이클 로그에 결정 기록 → 상태 갱신

### 기능을 버릴 때

- 행 삭제 금지. 상태 `dropped` 또는 `superseded`, 사이클 로그에 이유 남김.

```bash
# 참고: 최초 fork 이후 커밋 (히스토리 조사용)
git log --oneline 7b877f9..master

git show --stat <commit-hash>
```
