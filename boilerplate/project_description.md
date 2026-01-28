# Project Description

## Purpose

- What problem does this service solve?
- Express + MySQL + Prisma 기반 API 보일러플레이트를 자동으로 발전시키기 위한 데모입니다.
- 문서 변경을 트리거로 비대화형 에이전트(OpenCode)가 실행되고, 결과를 PR로 남기는 흐름을 검증합니다.

## Scope

- In scope:
- 최소 API: `GET /health`
- 사용자 기능: `POST /users`, `GET /users` (이메일 유니크)
- DB 스키마/마이그레이션: Prisma (MySQL)
- 검증: `docker compose run --rm api npm run verify`가 항상 통과해야 함
- Out of scope:
- 인증/권한
- 외부 연동(메일/결제 등)

## Non-functional Requirements

- Availability:
- Performance:
- Security:
- Observability:

## Interfaces

- HTTP endpoints:
- `GET /health` -> 200 + JSON
- `POST /users` -> 201 + JSON
- `GET /users` -> 200 + JSON
- Dependencies (DB/queues/external APIs):
- MySQL
