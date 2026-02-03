# OpenCode Web UI (macOS) - 빠른 실행

## 준비물

- Docker Desktop
- 공용 키(팀에서 공유)
  - `OPENAI_API_KEY`
  - `GEMINI_API_KEY`

> 키는 절대 git에 커밋하지 마세요.

## 보안 주의 (중요)

- 이 구성은 **로컬 전용(localhost only)** 사용을 전제로 합니다.
- Web UI는 `127.0.0.1:4096`으로만 바인딩되어 기본적으로 외부에서 접근할 수 없습니다.
- 다만 브라우저 환경 특성상, 로컬에서 동작하는 서비스도 공격 표면이 될 수 있으므로(예: 잘못된 링크/스크립트 실행),
  **공용 API 키를 사용하는 경우 특히 주의**하세요.
- 필요 시(사내망 공유 등)에는 반드시 인증 계층(Basic Auth 등)을 추가한 뒤 사용하세요.

## 실행

```bash
cd tools/opencode-web

./run.command

# (선택) 이미 환경변수로 주입하고 싶으면(키체인 대신)
# export OPENAI_API_KEY="..."
# export GEMINI_API_KEY="..."
# ./run.command

# (선택) OpenRouter 사용 시
# export OPENROUTER_API_KEY="..."

# (선택) 작업할 프로젝트 디렉토리(호스트 경로)
export PROJECT_DIR="$HOME/work/my-repo"

chmod +x run.command
```

- 접속: http://localhost:4096

## 구성 설명

- `compose.yml`은 Dockerfile 기반 이미지를 빌드해서 Web UI를 띄웁니다.
- Web UI는 `127.0.0.1:4096`으로만 바인딩되어 로컬에서만 접근됩니다.
- OpenCode 설정/세션은 Docker volume(`opencode_config`)에 저장되어 재시작해도 유지됩니다.

## 업데이트(최신 버전 반영)

최신 `opencode@latest`, `oh-my-opencode@latest`를 다시 받아오려면 이미지를 재빌드하세요.

```bash
cd tools/opencode-web
docker compose -f compose.yml build --pull --no-cache
docker compose -f compose.yml up -d
```

## 프로젝트 마운트(선택)

특정 프로젝트를 Web UI에서 바로 다루고 싶으면 `PROJECT_DIR`을 지정하세요.

```bash
export PROJECT_DIR="$HOME/work/my-repo"
```

> 컨테이너는 호스트 파일 시스템을 기본적으로 볼 수 없어서, 작업할 프로젝트는 마운트로 넘겨줘야 합니다.

## OpenCode 설정(팀 기본값 + 개인 오버라이드)

우선순위는 아래 순서로 적용됩니다.

1) **개인 오버라이드(추천)**: `tools/opencode-web/user-config/oh-my-opencode.json`
2) 레포 기본 설정: `config/opencode/oh-my-opencode.json`
3) `oh-my-opencode install`로 생성된 기본 설정

개인 오버라이드를 쓰려면:

```bash
mkdir -p tools/opencode-web/user-config
# 개인 설정 파일을 여기에 두세요(커밋 금지)
```

## 종료

```bash
cd tools/opencode-web
docker compose -f compose.yml down
```

## Keychain 기반 무입력 실행(권장)

`run.command`는 기본적으로 macOS Keychain을 사용합니다.

- 처음 1회 실행 시, 키가 없으면 터미널에서 키를 입력받아 Keychain에 저장합니다.
- 이후에는 키 입력 없이 `./run.command`만 실행하면 됩니다.

Keychain 저장 키 이름:

- `code-factory.opencode.OPENAI_API_KEY`
- `code-factory.opencode.GEMINI_API_KEY`

Keychain 초기화(키 삭제) 예시:

```bash
security delete-generic-password -a "$USER" -s "code-factory.opencode.OPENAI_API_KEY" || true
security delete-generic-password -a "$USER" -s "code-factory.opencode.GEMINI_API_KEY" || true
```
