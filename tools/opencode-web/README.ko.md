# OpenCode Web UI (macOS) - 빠른 실행

## 준비물

- Docker Desktop
- 공용 키(팀에서 공유)
  - `OPENAI_API_KEY`
  - `GEMINI_API_KEY`

> 키는 절대 git에 커밋하지 마세요.

## 실행

```bash
cd tools/opencode-web

export OPENAI_API_KEY="..."
export GEMINI_API_KEY="..."

# (선택) 작업할 프로젝트 디렉토리(호스트 경로)
export PROJECT_DIR="$HOME/work/my-repo"

chmod +x run.command
./run.command
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

## 종료

```bash
cd tools/opencode-web
docker compose -f compose.yml down
```
