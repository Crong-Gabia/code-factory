# Coder Workspace 생성 (UI)

1) 브라우저에서 `http://localhost:3001` 접속 후 로그인

2) 상단 메뉴에서 `Templates` 클릭

3) 방금 푸시한 템플릿(기본: `docker-dev-factory`) 선택

4) `Create Workspace` 클릭

5) Workspace 이름 입력 후 `Create Workspace` 클릭

6) Workspace가 `Running` 상태가 되면, `Terminal`을 열어 아래를 실행

```bash
cd /workspace/boilerplate
docker compose up --build -d
curl -fsS http://localhost:3000/health
docker compose run --rm api npm run verify
```
