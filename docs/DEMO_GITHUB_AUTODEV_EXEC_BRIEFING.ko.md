# GitHub 기반 자동 개발공정 데모 브리핑 (임원/CTO용)

이 문서는 `code-factory` 레포의 “문서 기반(ROADMAP) 자동 개발공정”을 GitHub에서 데모하기 위한 설명/스크립트입니다.

핵심 메시지:

- 사람(관리자)은 **기획/룰/작업계획 문서만 편집**한다.
- 시스템은 **PR 생성(계획/구현) + 검증(verify 게이트)**을 자동으로 수행한다.
- 결과는 **PR/Checks**로만 확인한다(사람이 IDE/서버에 접속해서 코딩하지 않는다).

---

## 1) 데모에서 보여줄 것(1분 요약)

1) `project_description.md` 수정 → 시스템이 계획 문서(`GEMINI.md`, `AGENTS.md`, `RULER.md`, `ROADMAP.md`)를 생성하고 PR로 올림
2) PR을 머지(= 계획 확정) → 시스템이 `ROADMAP.md`의 `(IN_PROGRESS)` 단계만 구현하여 또 PR로 올림
3) 시스템이 `verify`(룰+린트+테스트)를 통과해야만 PR이 merge 가능하도록 강제

근거/실행 흐름:

- `docs/GITHUB_ACTIONS_AUTOMATION.md`
- `.github/workflows/opencode-init-plan.yml`
- `.github/workflows/opencode-run-roadmap.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/branch-policy.yml`
- 품질 게이트: `boilerplate/package.json`의 `npm run verify`

---

## 2) 시스템 구성(현재 데모 기준)

### 역할

- 공장 관리자(개발 PM): 문서 편집 + PR 리뷰/머지(결과 확인)
- 작업자(에이전트): OpenCode(opencode)로 코드/문서를 변경하여 PR 생성
- 검증 시스템: `npm run verify` + CI 체크로 규칙 위반/테스트 실패를 차단

### 데이터 흐름(텍스트 다이어그램)

`develop` 브랜치에 문서 변경 push
-> GitHub Actions Workflow 실행
-> opencode 실행(에이전트가 변경 생성)
-> PR 생성
-> CI(verify) 통과
-> 머지

---

## 3) 데모 준비물(사전에 1회 세팅)

### 3.1 브랜치/PR 정책

이 레포는 다음 정책을 강제합니다.

- 기본 브랜치: `develop`
- 작업 브랜치: `feature/*` 또는 `fix/*`
- PR base: 반드시 `develop`
- required checks: `ci` + `branch-policy`

근거:

- `.github/workflows/branch-policy.yml`
- GitHub branch protection (develop)

### 3.2 GitHub Actions 설정(반드시 필요)

Settings -> Secrets and variables -> Actions

Variables:

- `OPENCODE_AGENT` (예: `sisyphus`)
- `OPENCODE_MODEL` (선택, 예: `openai/gpt-5.2`)

Secrets:

- 사용하는 provider에 맞는 키를 최소 1개 이상 설정
  - `OPENAI_API_KEY`
  - `GEMINI_API_KEY`
  - `ANTHROPIC_API_KEY`
  - `OPENROUTER_API_KEY`

주의:

- 키/토큰은 절대 git에 커밋하지 않는다.
- 이 레포는 secret scanning이 활성화되어 있다(유출 방지).

### 3.3 OpenCode 설정을 로컬/CI에서 동일하게 맞추는 방식

원칙: “설정의 정본(canonical)”은 레포에 커밋하고, secrets는 env/Secrets로만 주입.

- 정본(커밋됨): `config/opencode/oh-my-opencode.json`
- 로컬 오버라이드(커밋 금지): `.coder/opencode/oh-my-opencode.json`

GitHub Actions는 매 실행마다 정본을 `~/.config/opencode/oh-my-opencode.json`로 복사해서 적용합니다:

- `.github/workflows/opencode-init-plan.yml`
- `.github/workflows/opencode-run-roadmap.yml`

Coder workspace는 오버라이드를 우선 적용하고, 없으면 정본을 적용합니다:

- `scripts/workspace/setup-opencode.sh`

추가 문서:

- `docs/OPENCODE_SETUP.ko.md`

---

## 4) 라이브 데모 진행 순서(임원진 앞에서 그대로 읽어도 되는 스크립트)

### 4.1 “계획 생성” 데모

목표: PM이 `project_description.md`만 바꿨는데, 시스템이 계획 문서를 생성해 PR로 올리는 것을 보여준다.

1) `develop`에 `boilerplate/project_description.md`를 수정해서 push
2) Actions 탭에서 `opencode-init-plan` 실행 확인
3) PR이 자동으로 생성되는지 확인
   - PR 제목 예: `chore: init plan from project_description`
4) PR diff에서 생성/갱신된 문서 확인
   - `boilerplate/GEMINI.md`
   - `boilerplate/AGENTS.md`
   - `boilerplate/RULER.md`
   - `boilerplate/ROADMAP.md`
5) Checks에서 `ci`와 `branch-policy`가 통과하는지 확인

의미(임원진 포인트):

- “작업계획이 코드/레포에 남는다(감사 추적 가능)”
- “규칙(RULER)과 품질게이트(verify)가 자동으로 붙는다”

### 4.2 “구현 PR 생성” 데모

목표: ROADMAP의 현재 단계(IN_PROGRESS)만 자동으로 구현하고, verify 통과까지 확인한다.

1) 4.1에서 만들어진 PR을 merge해서 `boilerplate/ROADMAP.md`가 `develop`에 반영되게 한다
2) Actions 탭에서 `opencode-run-roadmap` 실행 확인
3) PR이 자동으로 생성되는지 확인
   - PR 제목 예: `feat: implement ROADMAP IN_PROGRESS step`
4) PR diff 확인(코드/테스트 변경)
5) Checks에서 최소 아래가 통과해야 함
   - `ci / boilerplate`
   - `branch-policy / enforce`

의미(임원진 포인트):

- “사람이 코드를 직접 만지지 않아도 PR 단위 결과물이 나온다”
- “품질 게이트를 통과하지 못하면 합쳐지지 않는다(자동화가 난사하지 않음)”

---

## 5) 아직 확정되지 않은 것(중요: ‘에이전트 스펙’)

현재 레포에는 임시로 OpenCode/Oh My OpenCode 설정이 들어가 있지만, 이는 ‘정책 결정 전’ 시범 구성입니다.

### 5.1 지금은 무엇이 ‘임의’인가?

- 에이전트 이름/역할과 모델 매핑이 임의로 정의되어 있음
  - `config/opencode/oh-my-opencode.json`
- GitHub Actions에서 `OPENCODE_AGENT`/`OPENCODE_MODEL`을 변수로 넘겨 실행함
  - `.github/workflows/opencode-init-plan.yml`
  - `.github/workflows/opencode-run-roadmap.yml`

즉, “어떤 모델을 어떤 단계에 쓸지(비용/보안/품질)”은 아직 정책으로 확정된 게 아닙니다.

### 5.2 임원/CTO 관점에서 결정해야 하는 항목(체크리스트)

- 모델 선택 정책
  - 플랜 생성(문서): 저비용/고속 모델 vs 고품질 모델
  - 구현/수정(코드): 고품질 모델(비용↑) vs 중간 품질
- 데이터 정책
  - 소스코드/로그가 외부 모델에 전송되는 범위
  - PII/비밀정보 차단(프롬프트/로그/레포) 원칙
- 실행 인프라 정책
  - GitHub-hosted runner 사용 vs self-hosted runner(k8s/온프레)
  - 네트워크 egress 제한/감사 로깅
- 비용/한도 정책
  - 일일/월간 실행 한도, 실패 시 재시도 정책, 동시 실행 제한
- 안전장치(가드레일)
  - 규칙: `RULER.md` (예: 타입 억제 금지, 보안 가이드)
  - 게이트: `npm run verify` (룰+린트+테스트)
  - 브랜치 정책: `feature/*|fix/*`, base `develop`, required checks

### 5.3 이 레포가 이미 제공하는 안전장치(현재)

- 브랜치 정책 강제: `.github/workflows/branch-policy.yml`
- CI 품질게이트: `.github/workflows/ci.yml` + `boilerplate/package.json`의 `npm run verify`
- 문서 기반 작업 단위:
  - 계획: `boilerplate/project_description.md` -> 생성 문서 PR
  - 실행: `boilerplate/ROADMAP.md`의 `(IN_PROGRESS)` 1개만 구현

---

## 6) 데모 범위/한계(솔직하게 말할 포인트)

- 현재 데모는 “PR/Checks 자동화”에 초점을 둔 MVP이며, 배포/운영은 포함하지 않습니다.
- DB/외부 의존성이 있는 기능 구현은 정책 결정(테스트 전략/환경 구성) 이후가 적합합니다.

---

## 7) 다음 단계 제안(임원진 합의가 필요한 것)

1) 에이전트 스펙 확정(역할/모델/비용/보안)
2) self-hosted runner(k8s)로 이동 여부 결정(보안/비용/네트워크)
3) 배포 파이프라인(스테이징) + 통합테스트(예: Karate/Supertest) 추가
