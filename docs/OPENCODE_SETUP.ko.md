# OpenCode / Oh My OpenCode 설정 (로컬 + Coder + GitHub Actions)

목표: 사람이 개입하지 않아도 동일한 에이전트/모델 설정으로 `opencode`가 실행되도록, 설정의 “정본(canonical)”을 레포에 두고 로컬/CI에서 공통으로 사용합니다.

## 1) 설정 파일 구조

- 정본(커밋됨, secrets 없음): `config/opencode/oh-my-opencode.json`
  - 에이전트 이름 -> 모델 매핑을 정의합니다.
- 로컬 오버라이드(커밋 금지, gitignored): `.coder/opencode/oh-my-opencode.json`
  - 개인별로 모델/에이전트를 바꿔 테스트하고 싶을 때 사용합니다.

우선순위:

- Coder workspace: `.coder/opencode/oh-my-opencode.json` (있으면) -> `config/opencode/oh-my-opencode.json`
  - 적용 로직: `scripts/workspace/setup-opencode.sh`
- GitHub Actions: 항상 `config/opencode/oh-my-opencode.json`
  - 워크플로우: `.github/workflows/opencode-init-plan.yml`, `.github/workflows/opencode-run-roadmap.yml`

## 2) 로컬(macOS)에서 필요한 것

### 2.1 OpenCode CLI

설치 방법은 환경에 따라 다르지만, 이 레포 기준으로는 workspace/CI에서도 쓰는 스크립트가 있습니다:

- `scripts/install-opencode.sh`

설치 후 PATH에 `opencode`가 잡혀야 합니다.

### 2.2 Oh My OpenCode

workspace 기준 설치/적용 스크립트:

- `scripts/workspace/setup-opencode.sh`

로컬에서도 동일하게 `oh-my-opencode`를 설치하고 `~/.config/opencode/oh-my-opencode.json`을 정본과 같게 맞추면 됩니다.

### 2.3 API 키 (secrets)

로컬에서는 쉘 환경변수로 주입합니다(파일로 커밋 금지).

- `OPENAI_API_KEY` (OpenAI 계열 모델 사용 시)
- `GEMINI_API_KEY` (Gemini 계열 모델 사용 시)
- `ANTHROPIC_API_KEY` / `OPENROUTER_API_KEY` (사용하는 모델에 따라)

## 3) GitHub Actions에서 필요한 것

Settings -> Secrets and variables -> Actions

### 3.1 Variables

- `OPENCODE_AGENT`
  - 예: `sisyphus`

- `OPENCODE_MODEL` (선택)
  - 설정하면 `opencode run --model ...`로 전달됩니다.
  - 권장: `config/opencode/oh-my-opencode.json`의 모델과 동일하게 유지하거나, 비워두고(미설정) 정본 설정이 모델을 결정하게 두세요.

### 3.2 Secrets

정본 설정(`config/opencode/oh-my-opencode.json`)에 사용되는 모델의 provider 키를 넣습니다.

- `OPENAI_API_KEY`
- `GEMINI_API_KEY`
- `ANTHROPIC_API_KEY`
- `OPENROUTER_API_KEY`

워크플로우는 실행 시점에 `config/opencode/oh-my-opencode.json`을 `~/.config/opencode/oh-my-opencode.json`으로 복사하고, `oh-my-opencode install`을 실행합니다.

## 4) 로컬 오버라이드 사용법(선택)

개인 설정 파일을 레포의 gitignored 경로로 복사:

- `scripts/sync-oh-my-opencode-config.sh`

예:

```bash
bash scripts/sync-oh-my-opencode-config.sh "$HOME/.config/opencode/oh-my-opencode.json"
```

그 다음 Coder workspace에서 다음이 실행되면 오버라이드가 적용됩니다:

```bash
bash /workspace/scripts/workspace/setup-opencode.sh
```
