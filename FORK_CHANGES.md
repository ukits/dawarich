# Fork 변경 이력 (Fork Changes)

이 문서는 upstream(원본) Dawarich를 **fork 해온 이후 직접 수정한 사항**을 추적하기 위한 문서입니다.
새로운 커밋을 추가할 때마다 이 문서도 함께 갱신하는 것을 권장합니다.

## 기준 정보

- **Fork 기준 커밋**: `7b877f9` (`clone: from github.com:ukits/dawarich.git`)
- **현재 HEAD**: `e9111da` (`master`)
- **작성자**: BYUN, SungUk
- **총 변경 커밋 수**: 25개

> 참고: 아래 파일 경로는 커밋 메시지와 현재 코드베이스를 대조해 정리한 것입니다.
> 정확한 diff는 `git log 7b877f9..HEAD --stat` 또는 `git show <hash>` 로 확인하세요.

---

## 1. 개발 환경 · 빌드 세팅

fork 직후 로컬/컨테이너 개발 환경을 맞추기 위한 초기 세팅 작업입니다.

| 커밋 | 내용 |
|------|------|
| `7b917e0` | devcontainer 세팅 |
| `ac63a44` | Ruby 버전 및 패키지 맞춤 |
| `69e360c` | vendor 패키지 업데이트 |
| `7318732` | vendor 패키지 업데이트 |
| `ced265a` | yarn 패키지 업데이트 |

---

## 2. 지도 · Timeline UI 개선

지도 및 Timeline 화면의 표시/레이아웃 관련 개선입니다.

| 커밋 | 내용 |
|------|------|
| `07b4fbd` | 지도에 표시되는 Point 크기를 설정에서 조절할 수 있도록 추가 |
| `7fe3789` | 1024px 이상 너비에서도 Timeline 창이 2열이 아닌 1열로 보이도록 레이아웃 수정 |
| `b2fedf0` | Timeline 달력에 padding 부여 |
| `38443a4` | 시간 표시를 `YYYY-MM-DD hh:mm:ss` 형태로 변경 |
| `2ec38e1` | `38443a4` 시간 표시 변경 시 발생한 frontend 에러 보정 |
| `050850e` | Timeline 달력의 요일이 **일요일부터** 시작하도록 수정 |
| `108ac89` | 경로(Route)의 구간 열에 시작 시간 · 끝 시간 표시 |

---

## 3. Places(장소) 관리 개선

장소 목록과 편집 UI의 사용성 개선입니다.

| 커밋 | 내용 |
|------|------|
| `1f5d8ae` | Places 목록을 시간 역순으로 정렬하고 visits 개수 표시 |
| `d93f8dd` | Edit Place 레이어에 삭제 버튼 추가 |
| `7492f10` | 장소 목록에 일괄 삭제 · 검색 필터 · 마지막 방문 열 추가 |

관련 서비스: `app/services/visits/bulk_destroy.rb` (일괄 삭제, 최대 500건 / 50건 배치 처리)

---

## 4. Points 관리 개선

포인트 선택/목록 관련 기능 개선입니다.

| 커밋 | 내용 |
|------|------|
| `56adc8e` | Tools 레이어에서 Points 선택 시, Delete 버튼에 선택된 Points의 기간 표시 |
| `e9111da` | Points 목록에 ID · Visit/Track · 고도 표시 및 필터 추가 |

---

## 5. Visits(방문) 생성 · 관리 로직 (핵심 변경)

이 fork에서 가장 크게 손댄 영역으로, **수동 방문 생성/삭제와 Track 계산 연동** 로직입니다.

| 커밋 | 내용 |
|------|------|
| `3c60668` | Tools 레이어에서 Points 선택 시, 새 Visit 추천 카드를 Track 별로 분리해 추천 |
| `2428b3e` | Select Area로 선택된 Points 기반 Visit 생성 시 위도/경도가 0으로 기입되던 버그 해결 |
| `b62179f` | Visit Card에 Place ID 표시 |
| `70e7bb0` | Visit 생성 시 포함 Point의 velocity를 `0.0`으로 만들어 Track 계산에서 의도적으로 제외 |
| `66fc9bb` | Visit 생성 시 좌표상 가장 가까운 Place를 자동 선택하지 않고, 범위 내 **이름이 같은** Place가 있으면 사용하고 없으면 새 Place 생성 |
| `5b9eb1c` | 수동 방문 생성 시 포함 포인트에 `visit_id` 할당 |
| `841bf68` | 방문 삭제 시 velocity 복원 및 `visit_id` 해제 |
| `17c7422` | Track에서 방문 포인트 제외 및 방문 경계에서 Track 분리 |

### 주요 관련 파일 및 동작 요약

- **`app/services/visits/create.rb`** — 수동 방문 생성
  - 범위 내(`SIMILARITY_RADIUS = 50m`) **이름이 같은** Place를 우선 사용, 없으면 `source: :manual` Place를 새로 생성 (`66fc9bb`)
  - 방문 시간 범위에 속하는 모든 Point에 `visit_id` 할당 (`5b9eb1c`)
- **`app/services/visits/side_effects.rb`** — 생성/삭제 부수효과
  - `on_create`: 방문 시간 범위 Point의 velocity를 `0.0`으로 만들고 Track/Stats 재계산 (`70e7bb0`, `17c7422`)
  - `on_destroy`: `raw_data.properties.speed` 기반으로 velocity 복원, `visit_id` 해제 후 Track/Stats 재계산 (`841bf68`)
- **`app/services/visits/place_finder.rb`** — 감지된 방문의 Place 매칭
  - 이름이 같은 후보 중 `manual` Place 우선, 그다음 거리순으로 선택
- **`app/services/visits/bulk_destroy.rb`** — 방문 일괄 삭제

---

## 변경 이력 갱신 방법

새 작업을 커밋한 뒤 아래 명령으로 최신 이력을 확인하고 표에 한 줄씩 추가하세요.

```bash
# fork 기준점 이후 모든 커밋 요약
git log --oneline 7b877f9..HEAD

# 특정 커밋의 상세 변경 파일 목록
git show --stat <commit-hash>
```
