# Upstream 동기화 절차 (PROCESS)

버전과 무관하게 **매 sync 사이클마다** 이 절차를 따른다.  
사이클별 수치·브랜치명·진행 로그는 `cycles/` 아래 해당 파일에만 적는다.

---

## 0. 용어

| 용어 | 의미 |
|------|------|
| **카탈로그** | 루트 [FORK_CHANGES.md](../../FORK_CHANGES.md) — 기능 ID `Fxx` |
| **사이클** | 한 번의 upstream 점프 (예: 1.9.2 → 1.14.0) |
| **작업 브랜치** | `sync/<target>` — `upstream/master`(또는 태그)에서 분기 |
| **참고 브랜치** | sync 직전 fork 메인라인 (보통 `master`) — diff·의도 확인용 |

---

## 1. 사이클 시작

1. `git fetch upstream --tags`
2. 목표 버전 확정: 태그 또는 `upstream/master` SHA
3. 작업 브랜치 생성:
   ```bash
   bash bin/setup_upstream_sync.sh <target-label>
   # 예: bash bin/setup_upstream_sync.sh 1.14.0
   # → branch sync/1.14.0 from upstream/master (또는 해당 태그)
   ```
4. `docs/upstream-sync/cycles/`에 새 파일 복사·작성  
   이름 권장: `YYYY-MM-<from>-to-<to>.md`  
   템플릿: 아래 [사이클 파일 템플릿](#사이클-파일-템플릿)
5. [FORK_CHANGES.md](../../FORK_CHANGES.md)에서 유지할 기능을 `판단 대기`로 표시하고, 열린 사이클 링크를 갱신
6. (선택) upstream CHANGELOG에서 **fork 도메인과 겹칠 만한 항목**만 사이클 파일 「Upstream 쪽지」에 메모 — 전체 릴리즈를 다 읽을 필요는 없음

**비목표:** upstream-only로 장시간 제품 검증. 충돌은 기능 이식 리뷰 중에 다룬다.

---

## 2. 기능 처리 순서

카탈로그 ID 기준. 의존이 있으면 순서를 지킨다.

**권장 기본 순서**

1. 개발환경 (F01) — 필요 시만  
2. 순수 UI (F02–F12, F14–F15)  
3. Visit/Track 핵심 (F16 → F17 → F18 → F19)  
4. Create에 의존하는 Tools UI (F13)  
5. 사이클 종료 시 카탈로그·HISTORY 정리

사이클 파일의 「이번 사이클 큐」표에서 순서를 고정해도 된다.

---

## 3. 기능당 체크리스트 (매번 동일)

### 3.1 리뷰 (코드 변경 전)

1. 카탈로그에서 **의도** 한 줄 확인 (`Fxx`)
2. 참고 브랜치에서 구현 확인: `git show <ref>:<path>`, `git log -p -- <path>`
3. 작업 브랜치(upstream 베이스)에서 같은 관심사 코드 확인
4. 충돌 유형 표시 (복수 가능):
   - `없음` / `경로이동` / `계약변경` / `대체됨` / `폐기후보`
5. 결정: `그대로 반영` / `고쳐 반영` / `포기` / `업스트림에 맡김` / `미룸`. 뜻은 [FORK_CHANGES.md](../../FORK_CHANGES.md) 상태 값 표.
6. 완료 기준 1~3개 (수동 확인)

→ 여기까지를 사이클 로그에 적은 뒤, **승인 후** 구현.

### 3.2 구현

- 커밋 메시지: `sync(Fxx): …` 또는 `sync(Fxx,Fyy): …`
- 가능하면 spec을 같은 커밋에 포함
- 한 커밋(또는 짧은 커밋 묶음) = 한 의도

### 3.3 기록

- 사이클 파일 진행 로그 한 줄
- `고쳐 반영` / `포기` / `업스트림에 맡김`이면 결정 기록 단락
- [FORK_CHANGES.md](../../FORK_CHANGES.md) 상태 컬럼 갱신

---

## 4. 사이클 종료

1. 남은 `판단 대기`가 없으면(또는 명시적 `미룸`만 남으면) 작업 브랜치를 메인라인으로 통합할지 결정
2. 카탈로그 메타의 「열린 동기화 사이클」을 닫힘/다음으로 갱신
3. [HISTORY.md](../../HISTORY.md)에 「upstream \<to\> 동기화」섹션 추가
4. 다음 sync까지 새 fork 기능은 카탈로그에 `유지 중`으로 추가

---

## 5. Git 치트시트

```bash
git fetch upstream --tags

# 작업 브랜치
git switch sync/<target>

# 참고(직전 fork) vs 작업 브랜치 파일
git show master:path/to/file
git show HEAD:path/to/file

# 카탈로그 원본 구간 (최초 fork 이후) — 조사용
git log --oneline 7b877f9..master -- path/to/file
```

---

## 6. 에이전트 협업 프롬프트

```text
upstream sync: 사이클 <파일명>, 기능 F__ .
1) FORK_CHANGES 의도 확인
2) 참고 브랜치 vs sync 브랜치 코드 대조
3) 충돌 유형·결정안 제안
4) 승인 후 구현·테스트·커밋
5) 사이클 로그 + FORK_CHANGES 상태 갱신
한 기능만. 승인 전 구현 금지.
```

---

## 사이클 파일 템플릿

`cycles/YYYY-MM-<from>-to-<to>.md` 에 복사:

```markdown
# Sync cycle: <from> → <to>

| 항목 | 값 |
|------|-----|
| 시작일 | YYYY-MM-DD |
| From | \<tag/sha\> |
| To | \<tag/sha\> |
| 작업 브랜치 | `sync/<to>` |
| 참고 브랜치 | `master` @ \<sha\> |
| 상태 | open / closed |
| 원본 대화(참고) | (있으면 링크; 본문은 이 파일에 이관) |

## Upstream 쪽지 (겹침만)
- …

## 이번 사이클 큐
| 순 | ID | 결정 | 커밋 | 비고 |
|----|----|------|------|------|
| 1 | F02 | | | |

## 진행 로그
| 날짜 | ID | 결정 | 커밋 | 비고 |
|------|----|------|------|------|

## 결정 기록
### Fxx
- …
```
