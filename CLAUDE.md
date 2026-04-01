# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

이 파일은 이 저장소에서 작업하는 Claude Code(claude.ai/code)에게 안내를 제공합니다.

## 명령어

```bash
npm run dev     # 핫리로드 개발 서버 시작 (babel-node + nodemon, 포트 3000)
npm run build   # src/ → build/ Babel 트랜스파일
npm start       # 빌드 후 컴파일된 서버 실행
```

포트는 기본값 `3000`이며, `PORT` 환경 변수로 변경 가능합니다. 테스트 스위트는 없습니다.

## 아키텍처

**test-svc**는 Node.js/Express와 LokiJS(인메모리 JSON 데이터베이스)로 구축된 다중 사용자 할일 목록 REST API입니다.

**소스는 `src/`의 ES6 모듈이며, Babel이 `build/`에 CommonJS로 컴파일합니다.**

### 주요 파일

- `src/index.js` — Express 앱 설정: CORS, EJS, 캐시 헤더, 중앙 에러 핸들러, 서버 시작
- `src/routes.js` — 모든 라우트 핸들러; 각 엔드포인트에는 1초 지연을 추가하는 `_long` 변형 존재 (느린 응답 테스트용)
- `src/tododao.js` — LokiJS 데이터 접근 레이어; 시작 시 `gdhong`과 `mrlee` 사용자의 샘플 할일 데이터로 초기화

### API 구조

모든 할일 엔드포인트는 소유자 범위: `/todolist/:owner/...`

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/todolist/:owner` | 모든 할일 조회 |
| GET | `/todolist/:owner/:id` | 단일 할일 조회 |
| POST | `/todolist/:owner` | 할일 생성 (`{todo, desc}`) |
| PUT | `/todolist/:owner/:id` | 할일 수정 (`{todo, done, desc}`) |
| PUT | `/todolist/:owner/:id/done` | 완료 상태 토글 |
| DELETE | `/todolist/:owner/:id` | 할일 삭제 |
| GET | `/todolist/:owner/create` | 새 소유자에게 샘플 데이터 초기화 |
| GET | `/users/:id` | 데모 사용자 엔드포인트 (3초 인위적 지연) |
| GET | `/` | 인터랙티브 API 문서 렌더링 (`views/index.ejs`) |

### 데이터 모델

```js
{ owner: string, id: number, todo: string, desc: string, done: boolean }
```

ID는 타임스탬프 기반(`new Date().getTime()`)입니다. `cleanTodoItem()`은 응답 전 LokiJS 내부 메타데이터를 제거합니다. 모든 응답에는 `status` 필드(`"success"` 또는 `"fail"`)가 포함됩니다.

## 코드 스타일

- 간단한 코드에는 주석을 달지 않는다. 복잡한 로직이나 의도가 명확하지 않은 코드에만 주석을 부여한다.

### 참고사항

- 주석과 일부 UI 텍스트는 한국어로 작성되어 있습니다 (할일 = todo/task)
- `sample.db`는 LokiJS 영속성 파일이며, 실제 데이터는 인메모리에서 동작하고 매 시작 시 새로 초기화됩니다
- `public/`은 `/`에서 제공되는 정적 자산을 포함하며, `views/index.ejs`가 유일한 템플릿입니다
