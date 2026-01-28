# Coder / Template / Workspace가 이 레포에서 하는 일

이 문서는 `code-factory` 레포에서 “Coder를 띄우고(template/workspace 올려두는)” 흐름이 왜 필요한지, 그리고 템플릿(`coder-template/`)이 무엇을 반영/프로비저닝하는지 구조적으로 설명합니다.

근거 파일(대표):
- `README.md`
- `docs/LOCAL_CODER_QUICKSTART.ko.md`
- `scripts/start-coder.sh`
- `scripts/setup-template.sh`
- `scripts/create-workspace.md`
- `coder-template/main.tf`
- `coder-template/build/Dockerfile`
- `boilerplate/docker-compose.yml`
- `boilerplate/Dockerfile`
- `scripts/workspace/setup-opencode.sh`
- `.github/workflows/opencode-init-plan.yml`
- `.github/workflows/opencode-run-roadmap.yml`

## 1) 한 줄 요약

이 레포의 Coder 설정은 “내 로컬(macOS)에서 **개발환경을 재현 가능한 형태로 찍어내는 설계도(Template)**를 등록해두고, 그 설계도로 **작업장(Workspace)** 을 만들어서 `boilerplate/`를 실제로 구동/검증하는 데모”를 위한 것입니다. (`README.md`, `docs/LOCAL_CODER_QUICKSTART.ko.md`)

## 2) 용어를 이 레포 기준으로 번역하기

### Coder Server

- 역할: 템플릿을 저장하고, 템플릿로 워크스페이스를 생성/관리하는 UI/API(컨트롤 플레인)
- 이 레포에서는 로컬 바이너리로 `http://localhost:3001`에 띄움
  - `scripts/start-coder.sh`
  - `scripts/demo-e2e.sh`
  - `docs/LOCAL_CODER_QUICKSTART.ko.md`

### Template

- 역할: 워크스페이스를 어떤 “인프라/컨테이너 구성”으로 만들지 정의한 설계도
- 이 레포에서는 Terraform 템플릿이 설계도이며 핵심은 `coder-template/main.tf`

### Workspace

- 역할: 템플릿(설계도)로 실제 만들어진 1개의 개발환경 인스턴스
- 이 레포에서는 “workspace 컨테이너(터미널 접속 대상)” + “dind 컨테이너(Docker daemon)” 조합으로 구성됨 (`coder-template/main.tf`)

## 3) 왜 `coder templates push`(template push)를 하는가?

`coder templates push`는 “템플릿(설계도)을 Coder Server에 등록/버전업”하는 동작입니다.

- 템플릿이 Coder 서버에 등록되어야 UI의 Templates 목록에서 선택할 수 있고, 그 템플릿로 workspace를 생성할 수 있음
- 이 레포 스크립트:
  - `scripts/setup-template.sh`
  - 실행 내용(요지):
    - 템플릿 디렉토리: `coder-template`
    - 템플릿 이름(기본): `docker-dev-factory`
    - 변수 전달: `repo_path=<호스트의 레포 절대경로>`

## 4) 템플릿이 반영하는 내용: “무엇을 만들고, 왜 그렇게 연결하나?”

템플릿의 실체는 `coder-template/main.tf`이며 Docker provider를 이용해 로컬 Docker 위에 리소스를 프로비저닝합니다.

### 4.1 템플릿 입력값(variables)

- `repo_path` (`coder-template/main.tf`)
  - 의미: 호스트(macOS)에 있는 이 레포의 **절대경로**
  - 목적: workspace 안에서 레포를 `/workspace`로 마운트하기 위해 필요
  - 실제 사용: dind 컨테이너와 workspace 컨테이너 둘 다 `repo_path -> /workspace`로 마운트함 (`coder-template/main.tf`)

- `ca_cert_pem`, `ca_cert_pem_b64` (`coder-template/main.tf`, `docs/LOCAL_CODER_QUICKSTART.ko.md`)
  - 의미: 사내망/프록시 환경에서 발생하는 TLS 검증 문제를 우회하기 위한 CA 번들
  - 목적:
    - dind(Docker daemon)가 Docker Hub 이미지를 pull할 때 `x509` 에러가 나지 않게
    - `boilerplate` 이미지 빌드 중 Prisma 엔진 바이너리 다운로드가 사내 TLS로 막히지 않게
  - 이 레포에서는 `CA_CERT_PEM`/`CA_CERT_PEM_B64`를 env로 주입해서 컨테이너 내부에 CA를 설치함:
    - dind: `coder-template/main.tf`
    - workspace: `coder-template/main.tf`
    - boilerplate build: `boilerplate/Dockerfile`에서 `ARG CA_CERT_PEM_B64` 처리

### 4.2 템플릿이 만드는 리소스(핵심만)

- `coder_agent.main` (`coder-template/main.tf`)
  - workspace 컨테이너에서 Coder agent가 올라오도록 init/startup 스크립트를 제공
  - startup에서 하는 대표 작업:
    - `localhost:3000` 포워딩(아래 5번 참조)
    - OpenCode 자동 설치/설정(있으면): `/workspace/scripts/workspace/setup-opencode.sh`

- `docker_container.dind` (`coder-template/main.tf`)
  - 역할: Docker daemon(dockerd). 실제 컨테이너 생성/네트워크/포트 바인딩이 여기서 일어남
  - workspace 컨테이너는 `DOCKER_HOST=tcp://dind:2375`로 이 daemon에 붙음 (`coder-template/main.tf`)
  - 주의: docker compose가 절대경로(`/workspace/...`)로 bind mount를 요청하기 때문에, dind에도 동일한 `/workspace` 마운트가 필요함 (`coder-template/main.tf`)

- `docker_image.workspace` + `docker_container.workspace` (`coder-template/main.tf`)
  - 개발자가 터미널로 접속하는 “작업장”
  - 이미지 빌드 소스: `coder-template/build/Dockerfile`
    - Ubuntu + docker cli/compose + node 20(외부 다운로드 없이 복사) 구성
  - 레포 마운트: `repo_path -> /workspace`

## 5) workspace에서 `curl localhost:3000`이 되는 이유 (dind 구조 이해)

workspace 안에서 `docker compose up`을 실행하면 실제로는:

1) 명령어 실행 위치: workspace 컨테이너 터미널 (`scripts/create-workspace.md`, `docs/LOCAL_CODER_QUICKSTART.ko.md`)
2) 컨테이너가 실제로 뜨는 위치: dind 컨테이너의 Docker daemon (`coder-template/main.tf`)

그래서 `boilerplate/docker-compose.yml`의 `ports: "3000:3000"`도 “dind 컨테이너의 네트워크/포트”에 붙습니다. (`boilerplate/docker-compose.yml`)

이 문제를 사용자가 신경 쓰지 않도록, 템플릿은 workspace startup에서 socat으로 포워딩을 겁니다:

- workspace 컨테이너의 `localhost:3000` → dind 컨테이너의 `:3000`로 TCP 포워딩 (`coder-template/main.tf`)

결과적으로 아래 검증이 workspace 터미널에서 그대로 동작합니다:

- `curl -fsS http://localhost:3000/health` (`README.md`, `scripts/create-workspace.md`, `docs/LOCAL_CODER_QUICKSTART.ko.md`)

## 6) 이 레포의 “boilerplate”는 무엇이며 workspace에서 왜 돌리나?

`boilerplate/`는 “workspace 안에서 실제로 돌아가는지 확인할 수 있는 최소한의 API+DB 스택”입니다.

- 구성: Express + MySQL 8 + Prisma (`boilerplate/README.md`, `boilerplate/package.json`, `boilerplate/docker-compose.yml`)
- 실행/검증 루틴(핵심):
  - `docker compose up --build -d`
  - `curl -fsS http://localhost:3000/health`
  - `docker compose run --rm api npm run verify`
  - 근거: `README.md`, `boilerplate/README.md`, `scripts/create-workspace.md`

## 7) OpenCode / 문서 기반 프로세스 데모는 어디에 붙어있나?

이 레포는 단순 실행 뿐 아니라 “문서(ROADMAP) → 작업 실행 → 검증(verify) 게이트” 흐름도 데모합니다.

- 로컬(워크스페이스)에서 문서 기반 트리거:
  - `npm run process` / `npm run process:watch` (`boilerplate/README.md`, `boilerplate/scripts/process.sh`, `boilerplate/scripts/watch-roadmap.sh`)

- OpenCode CLI(opencode) 기반 실행:
  - `npm run ai:init-plan`: `project_description.md`로 계획 문서 생성 (`boilerplate/scripts/ai/init-plan.sh`)
  - `npm run ai:run`: `(IN_PROGRESS)` 스텝 구현 실행 (`boilerplate/scripts/ai/run-opencode.sh`)

- workspace에서 opencode 설치/설정 자동화:
  - 템플릿 startup에서 `/workspace/scripts/workspace/setup-opencode.sh`를 호출(있으면) (`coder-template/main.tf`)
  - 실제 스크립트는 opencode + oh-my-opencode 설치 및 레포 설정 적용을 수행 (`scripts/workspace/setup-opencode.sh`, `scripts/install-opencode.sh`)

- GitHub Actions 데모(선택):
  - `boilerplate/project_description.md` 변경 → 계획 문서 PR 생성 (`.github/workflows/opencode-init-plan.yml`, `docs/GITHUB_ACTIONS_AUTOMATION.md`)
  - `boilerplate/ROADMAP.md` 변경 → 구현 PR 생성 + docker compose up + verify (`.github/workflows/opencode-run-roadmap.yml`, `docs/GITHUB_ACTIONS_AUTOMATION.md`)

## 8) 자주 헷갈리는 포인트 체크

- “workspace 안에서 docker compose를 돌렸는데 포트가 왜 안 뜨지?”
  - docker daemon이 dind 쪽이라서 포트 바인딩도 dind에 걸림. 이 템플릿은 socat 포워딩으로 `localhost:3000`을 맞춰줌 (`coder-template/main.tf`, `boilerplate/docker-compose.yml`).

- “왜 굳이 Coder를 써?”
  - 이 레포의 목적은 ‘내 로컬에 특정 개발환경을 깔끔히 재현’이 아니라, “템플릿 기반으로 작업장을 찍어내고(workspace), 그 안에서 boilerplate를 검증하고, (옵션) 문서 기반 자동화까지 보여주는” 흐름을 구성하는 것임. (`README.md`, `docs/LOCAL_CODER_QUICKSTART.ko.md`)
