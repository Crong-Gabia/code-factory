# Cua/Lume 파일럿 (기본 개발환경 후보 평가)

목표
- **온보딩 단순화**: 누구나 동일한 macOS VM 환경에서 시작
- **에이전트 안전 격리**: 위험한 작업은 VM 안에서 수행

구성
- OpenCode Web UI: **호스트에서 실행** (브라우저로 `localhost:4096` 접속)
- 대상 환경: **Lume macOS VM**

## 1) 한 번에 세팅 (호스트)

> 첫 실행은 **IPSW(~15GB) 다운로드 + VM 생성** 때문에 시간이 걸릴 수 있습니다.

```bash
cd tools/cua-pilot

# 실행 권한이 없으면(필요시)
chmod +x ./run.command

# 더블클릭 또는 터미널 실행
./run.command
```

이 스크립트가 하는 일
- 호스트 사전 체크(Apple Silicon, macOS >= 13, 디스크/메모리)
- Lume 설치(없으면)
- Golden VM 생성(무인 설정) + 2개 VM 클론
- OpenCode Web UI 실행(`tools/opencode-web/run.command` 호출)

생성되는 VM 이름
- `opencode-cua-golden`
- `opencode-cua-dev-1`
- `opencode-cua-dev-2`

## 2) VM 실행 / 접속

```bash
# VM 실행
lume run opencode-cua-dev-1

# SSH (단일 명령 실행)
lume ssh opencode-cua-dev-1 "whoami"
```

무인 설정(unattended)로 생성되며 SSH가 기본 활성화됩니다.
- user: `lume`
- password: `lume`

## 3) (선택) VM 내부 부트스트랩

VM 안에서 최소 툴체인을 설치하려면:

```bash
bash /path/to/repo/tools/cua-pilot/vm-bootstrap.sh
```

주의
- 이 파일럿에서는 **비밀정보(SSH key, 토큰 등)를 Golden VM에 절대 포함하지 않습니다.**

## 리셋 / 정리

```bash
lume stop opencode-cua-dev-1 || true
lume stop opencode-cua-dev-2 || true

lume delete opencode-cua-dev-1
lume delete opencode-cua-dev-2

# Golden까지 삭제하려면
lume delete opencode-cua-golden
```

OpenCode Web UI 중지

```bash
cd tools/opencode-web
docker compose -f compose.yml down
```
