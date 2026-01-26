# macOS 로컬 Coder Quickstart (로컬 바이너리 + Docker 기반 Workspace)

이 문서는 “사람이 그대로 따라해서” 로컬 macOS에서 Coder 서버를 띄우고, Docker 기반 workspace를 실행한 뒤, workspace 안에서 이 레포의 개발공장(boilerplate)을 실제로 구동/검증하는 흐름을 제공합니다.

## 최종 성공 기준

호스트(macOS):
- Coder 서버가 로컬 바이너리로 실행됨
- 브라우저에서 `http://localhost:3001` 접속 가능
- `coder templates push`로 템플릿 등록 성공

Workspace 내부:
- workspace 생성/실행 성공
- `/workspace/boilerplate`에서 아래가 모두 성공
  - `docker compose up --build -d`
  - `curl -fsS http://localhost:3000/health` -> 200
  - `docker compose run --rm api npm run verify` -> 통과

## 0) 준비물

- macOS
- Docker Desktop (실행 중)
- Coder CLI (없으면 스크립트가 설치 시도)
- 포트:
  - Coder 서버: 3001
  - boilerplate API(Workspace 내부): 3000

## 1) End-to-end 데모 실행 (권장)

아래 스크립트는 다음을 자동으로 수행합니다.
- Docker Desktop 기동 시도 및 대기
- Coder CLI 설치(없으면)
- Coder 서버를 `http://localhost:3001`로 기동
- 이후 템플릿 push / workspace 생성 안내 출력

```bash
bash scripts/demo-e2e.sh
```

### 자주 발생한 삽질/장애 기록 (해결 포함)

#### 1) Apple Silicon(arm64)에서 Coder server가 바로 종료됨

증상:
- `http://localhost:3001` 접속 안 됨
- 로그에 Postgres 연결 실패가 보임

원인:
- Apple Silicon에서는 Coder server가 외부 PostgreSQL이 필요

해결:
- 이 레포는 Homebrew 설치 대신 Docker로 Postgres를 자동 기동함

```bash
bash scripts/start-postgres.sh
cat .coder/postgres.env
```

#### 2) `coder templates push`가 `You are signed out`로 실패

원인:
- 브라우저 로그인과 CLI 로그인은 별개

해결:

```bash
coder login http://localhost:3001
bash scripts/setup-template.sh
```

#### 3) `coder templates push`가 `error: EOF`로 실패

원인:
- CLI가 `Upload ...? (yes/no)` 같은 프롬프트를 띄우는데, 스크립트/비TTY 환경에서 입력이 끊겨 EOF가 날 수 있음

해결:
- `scripts/setup-template.sh`는 `--yes`로 비대화형 실행하도록 구성됨

#### 4) 템플릿 파싱 에러: `Extra characters after interpolation expression (main.tf:48)`

원인:
- Terraform이 bash의 `${VAR:-}` 문법을 Terraform 보간으로 오해

해결:
- `${...}`를 `$${...}`로 이스케이프하여 문자열로 처리

#### 5) Workspace 생성 후 Terminal이 `Trying to connect...`에서 멈춤 (502)

원인:
- Workspace 컨테이너 내부에서 agent가 `localhost/127.0.0.1`로 Coder server에 붙으려 해서 실패

해결:
- 템플릿에서 agent init script의 호스트를 `host.docker.internal`로 치환
- Linux 엔진에서도 동작하도록 `host-gateway` 매핑 추가

조치:
- 템플릿을 다시 push 한 뒤 workspace를 재시작(또는 새로 생성)

```bash
bash scripts/setup-template.sh
```

#### 6) Workspace 이미지 빌드 실패: `docker-compose-plugin` not found / TLS self-signed

원인:
- Ubuntu 24.04(arm64)에서 `docker-compose-plugin` 패키지가 없거나,
- 외부 HTTPS 다운로드(NodeSource 등)가 사내 TLS(자체서명 체인) 때문에 실패할 수 있음

해결:
- 템플릿 Dockerfile에서 `docker-compose-v2`를 사용
- Node는 외부 다운로드 대신 `node:20-bookworm-slim`에서 바이너리를 복사하여 설치

출력된 URL(`http://localhost:3001`)로 접속해서 초기 계정 생성/로그인까지 완료합니다.

## 2) 수동 실행 (단계별)

### 2.1 사전 점검

```bash
bash scripts/check-prereqs.sh
```

### 2.2 Coder 서버 실행

```bash
bash scripts/start-coder.sh
```

브라우저에서:

- `http://localhost:3001`

Apple Silicon(arm64) 주의:
- Coder는 외부 PostgreSQL이 필요합니다.
- 이 레포는 Homebrew 설치 대신 Docker로 Postgres를 띄웁니다: `scripts/start-postgres.sh`

### 2.3 CLI 로그인

```bash
coder login http://localhost:3001
```

### 2.4 템플릿 등록

```bash
bash scripts/setup-template.sh
```

### 2.5 Workspace 생성(UI)

`scripts/create-workspace.md`를 참고하세요.

### 2.6 Workspace 내부에서 검증

Workspace 터미널에서:

```bash
cd /workspace/boilerplate
docker compose up --build -d
curl -fsS http://localhost:3000/health
docker compose run --rm api npm run verify
```

추가 확인(ingress 헤더 기반 사용자 컨텍스트):

```bash
curl -fsS \
  -H 'x-user-id: 123' \
  -H 'x-user-email: a@b.com' \
  -H 'x-user-roles: admin,dev' \
  http://localhost:3000/me
```

포트 참고:
- `http://localhost:3001` = Coder 서버(UI)
- `http://localhost:3000` = boilerplate API(Workspace 내부)

## 3) 문서 기반 관리 데모 (ROADMAP 트리거)

이 레포의 데모 포인트는 “문서(ROADMAP.md) 변경이 공정(process)을 트리거한다”는 흐름입니다.

Workspace 내부에서:

```bash
cd /workspace/boilerplate

# ROADMAP.md에서 (IN_PROGRESS) 상태를 하나로 유지하도록 편집
docker compose run --rm api npm run process

# 변경 감지해서 자동으로 process를 실행하려면
docker compose run --rm api npm run process:watch
```

## 3.5) (MVP) OpenCode 작업자(코딩 에이전트) 실행 흐름

이 단계는 “공장 관리자(사람)가 문서(ROADMAP)를 바꾸면, 작업자가 그 단계를 구현하고 verify 게이트를 통과한다”는 데모를 위한 수동 흐름입니다.

1) 현재 ROADMAP의 `(IN_PROGRESS)` 단계를 기반으로 OpenCode 프롬프트 생성:

```bash
cd /workspace/boilerplate
docker compose run --rm api npm run ai:prompt
```

프롬프트 파일:
- `boilerplate/.ai/opencode-prompt.md`

2) OpenCode(opencode)에서 위 프롬프트 내용을 붙여넣어 작업 수행

OpenCode가 workspace에 없다면 먼저 설치:

```bash
cd /workspace
bash scripts/install-opencode.sh

# PATH 반영이 필요하면
export PATH="$HOME/.opencode/bin:$PATH"
opencode --version
```

Oh My OpenCode 설정을 workspace에도 동일하게 적용하려면(권장):

호스트(macOS)에서:

```bash
bash scripts/sync-oh-my-opencode-config.sh "$HOME/.config/opencode/oh-my-opencode.json"
```

그 다음 workspace를 새로 만들거나 업데이트하면, workspace startup에서 자동으로 설치/적용을 시도합니다.

Workspace 안에서 수동으로 적용하려면:

```bash
bash /workspace/scripts/workspace/setup-opencode.sh
```

3) 작업 후 품질 게이트 실행(반드시 통과):

```bash
docker compose run --rm api npm run verify
```

## 4) Self-signed certificate 에러 대응

Node 기반 도구에서 아래 에러가 날 수 있습니다.

`self signed certificate in certificate chain`

### 임시 해결 (비권장)

```bash
NODE_TLS_REJECT_UNAUTHORIZED=0 npm install
```

### 정석 해결 (권장)

1) 사내 CA를 PEM 파일로 준비 (예: `~/corp-ca.pem`)
2) Node 실행 시 CA 번들을 지정

```bash
export NODE_EXTRA_CA_CERTS="$HOME/corp-ca.pem"
node -e "https=require('https');https.get('https://example.com',r=>console.log(r.statusCode))"
```

### macOS Keychain Always Trust

1) `Keychain Access` 열기
2) CA 인증서를 `System` keychain에 import
3) 인증서 열어서 `Trust` -> `Always Trust`
4) 터미널 재시작 후 재시도

## Docker pull 에러 (Workspace): `x509: certificate signed by unknown authority`

증상:
- Workspace 터미널에서 `docker compose up` 실행 시 Docker Hub 이미지 pull이 실패

예:
`tls: failed to verify certificate: x509: certificate signed by unknown authority`

원인:
- 사내망/프록시에서 TLS 가로채기(자체 서명/사내 CA)로 인해, Workspace의 Docker daemon(dind)이 Docker Hub 인증서를 신뢰하지 못함

해결(권장): 템플릿에 사내 CA를 주입

1) 사내 CA를 PEM으로 준비 (예: Keychain에서 Export 후 PEM 변환)
2) 템플릿 push 시 `ca_cert_pem_b64` 변수를 같이 전달 (권장)

예시(권장: base64 한 줄 변수로 전달):

```bash
CERT_PATH="/Users/crong/Desktop/Crong(조희권)/Gabia Inc..cer"

# CER(DER) -> PEM -> base64(1-line)
CA_B64="$(openssl x509 -in "$CERT_PATH" -inform DER -outform PEM | base64 | tr -d '\n')"

coder templates push docker-dev-factory -d coder-template \
  --variable repo_path="/Users/crong/WebstormProjects/code-factory" \
  --variable ca_cert_pem_b64="$CA_B64" \
  --yes --ignore-lockfile
```

3) workspace를 새로 만들거나, 기존 workspace를 업데이트/재시작

```bash
coder update <workspace-name>
```

참고:
- 이 레포 템플릿은 `ca_cert_pem`이 제공되면
  - dind(Docker daemon) 컨테이너에 CA를 설치하고
  - workspace 컨테이너에도 CA를 설치하여
  Docker pull 및 내부 HTTPS 접근을 안정화함

## Prisma generate 빌드 실패 (Workspace): self-signed certificate

증상:
- `docker compose up --build` 중 `prisma generate` 단계에서
  `self-signed certificate in certificate chain`로 실패

원인:
- Prisma 엔진 바이너리 다운로드(`binaries.prisma.sh`)가 사내 TLS로 인해 신뢰 실패

해결:
- 이 레포의 `Dockerfile`은 `CA_CERT_PEM_B64` build-arg를 받아 CA를 설치하도록 구성됨
- 템플릿이 `CA_CERT_PEM_B64`를 workspace env로 주입하므로, 템플릿에 CA를 넣고 workspace를 업데이트하면 해결
