# Fork 변경 히스토리 (HISTORY)

이 문서는 **ukits/dawarich** fork에서 upstream 대비 무엇이, 언제, 왜 바뀌었는지를 **시간순 릴리즈 노트** 형식으로 정리한 것입니다.

| 관련 문서 | 역할 |
|-----------|------|
| [FORK_CHANGES.md](./FORK_CHANGES.md) | 기능 ID 카탈로그 (장기, 상태 갱신) |
| [docs/upstream-sync/](./docs/upstream-sync/) | upstream 동기화 **반복 절차** + **사이클별 이력** |

upstream을 올릴 때마다 새 사이클 파일을 `docs/upstream-sync/cycles/`에 추가하고, 이 HISTORY에도 동기화 완료 시 섹션을 한 블록 덧붙인다.

---

## 개요

| 항목 | 내용 |
|------|------|
| Fork 기준 (upstream) | `7b877f9` — Dawarich **1.9.2** (2026-06-25) |
| Fork 시작 | 2026-07-05 |
| 현재 HEAD | `e9111da` (2026-07-19) |
| Fork 이후 커밋 수 | 25개 |
| 작성자 | BYUN, SungUk |

### 한 줄 요약

개발 환경을 맞춘 뒤, **지도·Timeline UI**를 손보고, **Places / Points 목록** 사용성을 높였습니다. 가장 큰 변화는 **수동 Visit 생성·삭제와 Track 계산이 일관되게 연동**되도록 방문(Visit) 도메인 전반을 재정비한 것입니다.

---

## 2026-06-25 — Fork 기준점

**Upstream: Dawarich 1.9.2** (`7b877f9`)

이 시점의 upstream에는 Map v2 개선, AirTrail 연동, 공개 위치 공유, Lite/Pro 플랜 등이 포함되어 있습니다.  
이 fork는 그 위에 **개인 사용·자체 호스팅 환경에 맞춘 UI/워크플로우 개선**을 쌓아 올린 상태입니다.

---

## 2026-07-05 — 개발 환경 구축 & UI 1차 개선

Fork 직후 하루에 개발 환경 정비와 지도·Timeline·Places·Tools 화면의 1차 개선이 이루어졌습니다.

### 개발 환경

- **Dev Container** 설정 추가 — WSL/VS Code에서 컨테이너 기반 개발 가능
- **Ruby 버전 및 gem** 정렬
- **vendor / yarn** 패키지 업데이트

### 지도 · Timeline

- **Point 크기 설정** — 지도에 표시되는 포인트 크기를 사용자 설정에서 조절 가능
- **Timeline 1열 레이아웃** — 1024px 이상 너비에서도 Timeline 패널이 2열이 아닌 1열로 표시
- **Timeline 달력** — padding 추가, **요일을 일요일 시작**으로 변경
- **시간 표시 형식** — `YYYY-MM-DD hh:mm:ss` 형태로 통일

### Places · Tools · 경로

- **Places 목록** — 최신순 정렬, 각 장소의 visits 개수 표시
- **Tools — Points 선택** — Delete 버튼에 선택 구간의 **기간(날짜 범위)** 표시
- **Tools — Visit 추천** — 선택한 Points에 대해 **Track별로 분리된 Visit 추천 카드** 표시
- **경로(Route) 테이블** — 구간 열에 **시작·종료 시간** 표시
- **Edit Place** — 레이어에 **삭제 버튼** 추가

> 관련 커밋: `7b917e0` ~ `d93f8dd` (14개)

---

## 2026-07-07 — Visit 워크플로우 1차 & Place 매칭 정책

Timeline 시간 표시 변경(`38443a4`) 직후 프론트엔드 오류가 발생해 당일 보정했고, Visit 생성·표시와 관련된 핵심 로직이 들어갔습니다.

### 버그 수정

- **시간 표시 변경 후 frontend 오류** 보정 (`2ec38e1`)
- **Select Area → Visit 생성** 시 위·경도가 `0`으로 저장되던 버그 수정 (`2428b3e`)

### Visit · Place

- **Visit Card**에 **Place ID** 표시 (`b62179fb`)
- **Visit 생성 시 Track 제외** — 방문에 포함된 Point의 `velocity`를 `0.0`으로 설정해 Track 계산에서 의도적으로 제외. 해당 날짜 Track 삭제 후 재계산. Visit 삭제 시 velocity 복구 및 재계산 (`70e7bb0`)
- **Place 자동 매칭 정책 변경** — 좌표상 가장 가까운 Place를 무조건 고르지 않음. 반경(50m) 내 **이름이 같은** Place가 있으면 사용하고, 없으면 Visit 이름과 같은 **새 Place**를 생성 (`66fc9bb`)

> 이 시점부터 “머물렀던 장소”를 수동으로 기록할 때, **이름 기준 Place 정책**과 **Track에서 정지 구간 제외**라는 두 축이 fork의 핵심 방향으로 자리 잡기 시작했습니다.

---

## 2026-07-18 — Visit ↔ Track 완전 연동 & Places 대량 관리

약 10일간의 공백 뒤, Visit·Track·Place 도메인을 **데이터 일관성** 관점에서 마무리하는 작업이 집중되었습니다.

### Visit · Track (핵심)

1. **`visit_id` 할당** (`5b9eb1c`)  
   수동 Visit 생성 시 Visit 레코드만 만들고 Point와 연결하지 않던 문제를 수정. 방문 시간 범위 내 모든 Point에 `visit_id`를 할당하여, velocity `0` 처리·Track 제외 대상과 **동일한 Point 집합**을 사용.

2. **Visit 삭제 시 정리** (`841bf68`)  
   삭제 시 `raw_data.properties.speed` 기준으로 velocity 복원, `visit_id` 해제, Track/Stats 재계산.

3. **Track 세그먼트 분리** (`17c7422`)  
   방문에 속한 Point는 Track에 포함되지 않도록 Ruby(`Tracks::Segmentation`)와 SQL(`Track.segment_points_in_sql`) 경로 모두 수정.  
   - 시간·거리 간격과 무관하게 Track이 **방문 직전에 종료**, 방문 이후 첫 비-방문 Point에서 **새 Track 시작**
   - 방문으로 나뉜 Track이 다시 병합되지 않도록 가드 추가
   - 오펀 Point 재흡수 시에도 방문 Point 제외

> **사용자 관점:** 지도에서 “정지(방문)” 구간과 “이동(경로)” 구간이 명확히 분리되어, 수동으로 기록한 Visit이 경로선에 끼어들지 않습니다.

### Places 목록

- **일괄 삭제** — 체크박스 + `bulk_destroy` (최대 500건, 50건 배치, `Visits::BulkDestroy` 패턴)
- **Last Visited** 열 — 장소별 최근 방문 일자
- **Source** 열 및 Name/Source **검색 필터**
- 좌표 **소수점 6자리 zerofill** 표시

> 관련 커밋: `5b9eb1c`, `841bf68`, `17c7422`, `7492f10`

---

## 2026-07-19 — Points 목록 강화

Points 관리 화면을 Visit/Track 디버깅·정리에 쓰기 쉽게 확장했습니다.

### Points 목록 (`e9111da`)

- **ID** 열 추가 (체크박스와 Address 사이)
- **Visit ID**, **Track ID** 열 추가 (Speed 앞)
- **고도(Alt)** 표시, 좌표 6자리 zerofill
- 검색 필터에 **Visit ID**, **Track ID** 추가 (정렬·삭제 후에도 유지)

> Visit/Track 연동 작업(7/18)의 후속으로, “이 Point가 어느 Visit/Track에 속하는지”를 목록에서 바로 확인·필터링할 수 있게 되었습니다.

---

## 주제별 요약 (기능 관점)

| 주제 | 주요 변화 | 기간 |
|------|-----------|------|
| 개발 환경 | Dev Container, Ruby/gem, yarn/vendor | 2026-07-05 |
| 지도 · Timeline | Point 크기, 1열 레이아웃, 달력·시간 표시 | 2026-07-05 ~ 07-07 |
| Places | 정렬·visits 수, 삭제, 일괄 삭제·검색·Last Visited | 2026-07-05 ~ 07-18 |
| Points | Delete 기간 표시, ID·Visit/Track·고도·필터 | 2026-07-05, 07-19 |
| Visit · Track | 수동 생성/삭제, velocity·visit_id, Track 분리, Place 이름 매칭 | 2026-07-07 ~ 07-18 |
| Tools | Track별 Visit 추천, Select Area 버그 수정 | 2026-07-05 ~ 07-07 |

---

## 주요 서비스 · 파일 (참고)

Visit/Track 연동과 관련된 핵심 코드:

| 파일 | 역할 |
|------|------|
| `app/services/visits/create.rb` | 수동 Visit 생성, Place 매칭, `visit_id` 할당 |
| `app/services/visits/side_effects.rb` | 생성/삭제 시 velocity·Track·Stats 부수효과 |
| `app/services/visits/place_finder.rb` | 감지 Visit의 Place 매칭 (manual Place 우선) |
| `app/services/visits/bulk_destroy.rb` | Visit/Place 일괄 삭제 |
| `app/services/tracks/segmentation.rb` | Track 세그먼트 — 방문 Point 제외·경계 분리 |

---

## 문서 갱신 방법

새 커밋을 push한 뒤:

1. [FORK_CHANGES.md](./FORK_CHANGES.md) — 커밋·파일 단위 대조표 갱신
2. **이 문서 (HISTORY.md)** — 해당 날짜 섹션에 릴리즈 노트 항목 추가

```bash
# fork 이후 커밋 확인 (시간순)
git log --reverse --date=short --format='%ad %h %s' 7b877f9..HEAD

# 특정 커밋 상세
git show --stat <commit-hash>
```

---

*마지막 갱신: 2026-07-19 (HEAD `e9111da`)*
