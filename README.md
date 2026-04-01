# test-svc

Node.js/Express와 LokiJS(인메모리 JSON 데이터베이스)로 구축된 다중 사용자 할일 목록 REST API입니다.

## 요구사항

- Node.js >= 22.0.0

## 시작하기

```bash
npm install
```

### 개발 서버

```bash
npm run dev
```

핫리로드가 적용된 개발 서버를 포트 3000에서 시작합니다 (babel-node + nodemon).

### 프로덕션 빌드 및 실행

```bash
npm run build   # src/ → build/ Babel 트랜스파일
npm start       # 빌드 후 컴파일된 서버 실행
```

### 포트 설정

기본 포트는 `3000`이며, 환경 변수로 변경할 수 있습니다.

```bash
PORT=8080 npm start
```

## API

브라우저에서 `http://localhost:3000/`을 열면 인터랙티브 API 문서를 확인할 수 있습니다.

모든 할일 엔드포인트는 `:owner`(사용자 식별자) 범위로 구분됩니다.

### 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/todolist/:owner` | 모든 할일 조회 |
| GET | `/todolist/:owner/:id` | 단일 할일 조회 |
| POST | `/todolist/:owner` | 할일 생성 |
| PUT | `/todolist/:owner/:id` | 할일 수정 |
| PUT | `/todolist/:owner/:id/done` | 완료 상태 토글 |
| DELETE | `/todolist/:owner/:id` | 할일 삭제 |
| GET | `/todolist/:owner/create` | 새 소유자에게 샘플 데이터 초기화 |
| GET | `/users/:id` | 데모 사용자 조회 (3초 지연) |
| GET | `/` | 인터랙티브 API 문서 |

각 엔드포인트는 `/todolist_long/...` 형태의 변형 경로도 지원하며, 1초 인위적 지연을 추가합니다 (느린 응답 테스트용).

### 요청/응답 예시

**할일 생성**

```
POST /todolist/gdhong
Content-Type: application/json

{ "todo": "Express 공부", "desc": "Express 프레임워크를 학습합니다" }
```

```json
{
  "status": "success",
  "message": "추가 성공",
  "item": { "id": 1711900000000, "todo": "Express 공부", "desc": "Express 프레임워크를 학습합니다" }
}
```

**할일 수정**

```
PUT /todolist/gdhong/:id
Content-Type: application/json

{ "todo": "수정된 제목", "done": true, "desc": "수정된 설명" }
```

모든 응답에는 `"success"` 또는 `"fail"` 값을 가진 `status` 필드가 포함됩니다.

### 데이터 모델

```js
{
  owner: string,   // 소유자 식별자
  id: number,      // 타임스탬프 기반 ID (new Date().getTime())
  todo: string,    // 할일 제목
  desc: string,    // 설명
  done: boolean    // 완료 여부
}
```

## 아키텍처

소스는 `src/`의 ES6 모듈이며, Babel이 `build/`에 CommonJS로 컴파일합니다.

| 파일 | 역할 |
|------|------|
| `src/index.js` | Express 앱 설정 (CORS, EJS, 캐시 헤더, 에러 핸들러, 서버 시작) |
| `src/routes.js` | 모든 라우트 핸들러 정의 |
| `src/tododao.js` | LokiJS 데이터 접근 레이어 |

### 데이터 초기화

서버 시작 시 `gdhong`과 `mrlee` 사용자의 샘플 데이터로 인메모리 DB가 초기화됩니다. 데이터는 재시작 시 초기화되며 영속되지 않습니다.
