# 프로젝트 구조 설계 원칙: todolist-app

> 버전: 1.0 | 작성일: 2026-04-01 | 기반 문서: PRD v1.0, 도메인 정의서 v0.4

---

## 1. 최상위 공통 원칙

FE/BE를 막론하고 모든 코드에 적용되는 불변 원칙이다.

### 1.1 단일 책임

하나의 모듈(파일, 함수, 클래스)은 하나의 이유로만 변경된다. 인증 로직과 할일 비즈니스 로직은 동일 파일에 공존하지 않는다.

### 1.2 명시적 의존성

암묵적 전역 상태나 사이드 이펙트에 의존하지 않는다. 모든 의존성은 임포트 또는 함수 인자로 명시한다.

### 1.3 레이어 경계 준수

각 레이어는 정해진 방향으로만 의존한다. 하위 레이어가 상위 레이어를 알아서는 안 된다 (섹션 2 참조).

### 1.4 도메인 용어 일관성

코드 전반에서 도메인 정의서의 용어를 그대로 사용한다.

| 도메인 용어 | 코드 식별자 |
|------------|------------|
| 할일 | `todo` / `Todo` |
| 시작일 | `startDate` / `start_date` |
| 종료일 | `dueDate` / `due_date` |
| 완료 여부 | `done` |
| 상태 | `status` / `TodoStatus` |
| 회원 | `user` / `User` |
| 소유자 | `ownerId` / `owner_id` |

### 1.5 상태는 계산값

`status`는 저장하지 않는다. 할일 조회 시 서버 UTC 날짜 기준으로 BR-S01~BR-S05 규칙에 따라 동적 계산하여 응답에 포함한다. FE는 서버가 내려준 `status`를 그대로 표시하며 클라이언트에서 재계산하지 않는다.

### 1.6 UTC 기준 날짜 처리

모든 날짜 비교는 서버 UTC 날짜(일 단위)를 기준으로 수행한다. `start_date`, `due_date`는 `DATE` 타입(`YYYY-MM-DD`)으로 저장한다. 타임스탬프(`created_at`, `updated_at`)는 `TIMESTAMPTZ`로 저장한다.

---

## 2. 의존성 / 레이어 원칙

### 2.1 프론트엔드 레이어

```
Pages / Screens
    ↓
Features (도메인별 컴포넌트 + 훅)
    ↓
Shared (공통 컴포넌트, 유틸, 타입)
    ↓
Infrastructure (API 클라이언트, 스토어, 라우터)
```

| 레이어 | 역할 | 허용 의존 방향 |
|--------|------|--------------|
| Pages | 라우팅 단위 화면. 레이아웃 조합만 담당 | Features, Shared |
| Features | 도메인별 UI 컴포넌트, TanStack Query 훅, Zustand 슬라이스 | Shared, Infrastructure |
| Shared | 재사용 컴포넌트, 공통 타입, 유틸 함수 | Infrastructure |
| Infrastructure | axios 인스턴스, Zustand 스토어 초기화, 라우터 설정 | 외부 라이브러리만 |

- Pages는 API를 직접 호출하지 않는다. 반드시 Features의 TanStack Query 훅을 경유한다.
- Shared 컴포넌트는 도메인 타입(`Todo`, `User`)을 직접 임포트하지 않는다. Props는 원시 타입 또는 공통 인터페이스로 정의한다.

### 2.2 백엔드 레이어

```
Routes (Express 라우터)
    ↓
Controllers (요청/응답 처리)
    ↓
Services (비즈니스 로직)
    ↓
Repositories (SQL 쿼리)
    ↓
Database (PostgreSQL via pg)
```

| 레이어 | 역할 | 허용 의존 방향 |
|--------|------|--------------|
| Routes | URL 매핑, 미들웨어 체인 구성 | Controllers, Middlewares |
| Controllers | req/res 처리, 입력 유효성 검증, 응답 직렬화 | Services |
| Services | 비즈니스 규칙(BR-*) 적용, 상태 계산, 트랜잭션 조율 | Repositories |
| Repositories | pg를 통한 raw SQL 실행, 결과 매핑 | pg pool |
| Middlewares | 인증(JWT 검증), 에러 핸들링, 공통 처리 | Services (인증 미들웨어만 예외) |

- Controllers는 SQL을 직접 실행하지 않는다.
- Services는 `req`, `res` 객체를 알지 못한다.
- Repositories는 비즈니스 규칙을 포함하지 않는다.
- 상태(Status) 계산 로직은 Services 레이어에 위치한다.

### 2.3 레이어 위반 금지 규칙

- Routes에서 pg pool을 직접 사용하는 것 금지
- Controllers에서 다른 Controllers를 직접 호출하는 것 금지
- Repositories에서 HTTP 상태 코드나 오류 코드(`AUTH_*`, `TODO_*`)를 반환하는 것 금지
- 오류 코드는 Services 또는 Controllers에서만 throw한다

### 2.4 외부 의존성 관리

- 외부 라이브러리는 Infrastructure 레이어(FE) 또는 `config/` 레이어(BE)에서만 초기화한다.
- pg 연결 풀은 단일 모듈(`src/config/db.js`)에서 생성하고 Repositories에 주입한다.
- axios 인스턴스는 단일 모듈(`src/infrastructure/apiClient.ts`)에서 생성한다. 인터셉터에서 JWT 액세스 토큰 첨부 및 401 응답 시 토큰 갱신 재시도를 처리한다.

---

## 3. 코드 / 네이밍 원칙

### 3.1 파일 및 디렉토리

| 대상 | 규칙 | 예시 |
|------|------|------|
| FE 컴포넌트 파일 | PascalCase | `TodoCard.tsx`, `LoginPage.tsx` |
| FE 훅 파일 | camelCase, `use` 접두사 | `useTodoList.ts`, `useAuth.ts` |
| FE 유틸/서비스 파일 | camelCase | `dateUtils.ts`, `authStore.ts` |
| BE 파일 | camelCase | `todoController.js`, `userService.js` |
| 디렉토리 | camelCase | `controllers/`, `features/` |

### 3.2 함수 및 변수

| 대상 | 규칙 | 예시 |
|------|------|------|
| 함수 | 동사 + 명사 | `createTodo`, `getUserById`, `calculateStatus` |
| 불리언 변수 | `is`, `has`, `can` 접두사 | `isDone`, `isAuthenticated`, `hasNextPage` |
| 이벤트 핸들러(FE) | `handle` 접두사 | `handleSubmit`, `handleToggleDone` |
| TanStack Query 훅 | `use` + 대상 + 동작 | `useTodoList`, `useCreateTodo`, `useToggleDone` |
| Zustand 슬라이스 | 도메인 + `Store` | `authStore`, `todoFilterStore` |

### 3.3 TypeScript 타입 네이밍 (FE)

| 대상 | 규칙 | 예시 |
|------|------|------|
| 엔티티 타입 | PascalCase | `Todo`, `User` |
| 상태 enum | PascalCase | `TodoStatus` |
| API 요청 타입 | `{동작}{엔티티}Request` | `CreateTodoRequest`, `LoginRequest` |
| API 응답 타입 | `{동작}{엔티티}Response` | `TodoListResponse`, `LoginResponse` |
| Props 타입 | `{컴포넌트명}Props` | `TodoCardProps`, `StatusBadgeProps` |
| 공통 응답 래퍼 | `ApiResponse<T>` | `ApiResponse<Todo>` |

상태 enum 값은 도메인 정의서의 영문명을 그대로 사용한다.

```typescript
enum TodoStatus {
  Pending = 'Pending',
  InProgress = 'InProgress',
  Overdue = 'Overdue',
  Completed = 'Completed',
  LateCompleted = 'LateCompleted',
}
```

### 3.4 DB 컬럼 네이밍

PostgreSQL 컬럼명은 snake_case. 도메인 정의서의 camelCase 속성명을 변환한다.

| 도메인 속성 | DB 컬럼 |
|------------|---------|
| `ownerId` | `owner_id` |
| `startDate` | `start_date` |
| `dueDate` | `due_date` |
| `createdAt` | `created_at` |
| `updatedAt` | `updated_at` |

Repositories에서 DB 결과를 JS 객체로 매핑할 때 snake_case → camelCase로 변환하여 반환한다.

### 3.5 API 경로

소문자 kebab-case, 명사 복수형. 버전 프리픽스: `/api` (MVP에서는 버전 없음).

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
GET    /api/users/me
PUT    /api/users/me
DELETE /api/users/me
GET    /api/todos
POST   /api/todos
GET    /api/todos/:id
PUT    /api/todos/:id
PATCH  /api/todos/:id/done
DELETE /api/todos/:id
```

### 3.6 오류 코드

도메인 정의서의 오류 코드를 그대로 사용한다. 새 코드 추가 시 `{도메인}_{번호}` 형식을 따른다.

| 도메인 | 접두사 | 범위 |
|--------|--------|------|
| 인증 | `AUTH_` | AUTH_001 ~ AUTH_005 |
| 할일 | `TODO_` | TODO_001 ~ TODO_004 |
| 사용자 | `USER_` | USER_001 |

---

## 4. 테스트 / 품질 원칙

### 4.1 테스트 전략

| 단계 | 대상 | 도구 | 범위 |
|------|------|------|------|
| 단위 테스트 | BE Services (상태 계산, 유효성 검증) | Jest | 비즈니스 규칙(BR-*) 전체 |
| 단위 테스트 | FE 유틸 함수 | Vitest | 날짜 처리, 포맷 함수 |
| 통합 테스트 | BE API 엔드포인트 | Jest + supertest | 주요 UC 성공/실패 경로 |
| E2E | 주요 사용자 흐름 | Playwright | UC-01, UC-02, UC-03, UC-04 |

### 4.2 우선순위 (MVP 3일 기준)

1. BE Services 단위 테스트: 상태 계산(BR-S01~S05) 경계값 검증 **필수**
2. BE 통합 테스트: 인증 흐름(UC-01, UC-02, UC-08) 및 소유권 검증(TODO_003)
3. FE/E2E: MVP 이후 보완

### 4.3 커버리지 목표

| 레이어 | 목표 |
|--------|------|
| BE Services — 상태 계산 | 100% (경계값 포함) |
| BE Services — 전체 | 80% 이상 |
| BE Controllers | 60% 이상 |
| FE 유틸 | 80% 이상 |

### 4.4 PR 기준

- TypeScript 컴파일 + ESLint 통과 필수
- 새 비즈니스 규칙 추가 시 해당 규칙의 단위 테스트 포함 필수
- PR 1개 = 하나의 논리적 변경 단위

---

## 5. 설정 / 보안 / 운영 원칙

### 5.1 환경변수 관리

**BE 필수 환경변수**

| 변수명 | 설명 |
|--------|------|
| `DATABASE_URL` | PostgreSQL 연결 문자열 |
| `JWT_ACCESS_SECRET` | 액세스 토큰 서명 키 (HS256) |
| `JWT_REFRESH_SECRET` | 리프레시 토큰 서명 키 (HS256, ACCESS와 다른 값) |
| `JWT_ACCESS_EXPIRES_IN` | 액세스 토큰 만료 (기본: `1h`) |
| `JWT_REFRESH_EXPIRES_IN` | 리프레시 토큰 만료 (기본: `7d`) |
| `PORT` | 서버 포트 (기본: `3000`) |
| `NODE_ENV` | `development` / `production` |

**FE 환경변수**

| 변수명 | 설명 |
|--------|------|
| `VITE_API_BASE_URL` | BE API 기본 URL |

- `.env`는 `.gitignore`에 포함, `.env.example`을 저장소에 커밋한다.

### 5.2 보안 규칙

**SQL 인젝션 방지**
- raw SQL 작성 시 반드시 pg 파라미터화 쿼리(`$1`, `$2`, ...) 사용
- 정렬 기준(`sortBy`, `order`)처럼 사용자 입력이 컬럼명/방향에 영향을 주는 경우, allowlist 검증 후 사용

**인증 및 권한**
- 모든 인증 필요 엔드포인트는 `authenticate` 미들웨어를 통과한다
- 할일 조회/수정/삭제 시 `owner_id = $userId` 조건을 SQL WHERE 절에 포함 — 앱 레이어 단독 검증은 불충분
- bcrypt cost factor 12 사용 (BR-U02)
- 비밀번호는 응답에 절대 포함하지 않는다

**CORS**
- 허용 오리진은 환경변수로 관리. `production`에서 `*` 사용 금지

**XSS**
- FE에서 `dangerouslySetInnerHTML` 사용 금지
- 액세스 토큰은 메모리(Zustand store)에 보관

### 5.3 로깅 원칙

배포 환경은 **Vercel**로 확정. Vercel은 `stdout`/`stderr`를 자동 수집하므로 `console` 함수로 로깅한다.

| 수준 | 함수 | 대상 |
|------|------|------|
| `info` | `console.log('[INFO] ...')` | 서버 시작, 요청 수신 (메서드, 경로, 상태코드, 소요시간) |
| `warn` | `console.warn('[WARN] ...')` | 인증 실패(AUTH_001, AUTH_002), 소유권 위반(TODO_003) |
| `error` | `console.error('[ERROR] ...')` | 예기치 않은 서버 에러 (스택 트레이스 포함) |

- 로그에 비밀번호, JWT 토큰 전체 값 포함 금지
- `NODE_ENV=production`에서 클라이언트에 스택 트레이스 노출 금지
- 중앙화된 에러 핸들러에서 일관된 응답 형식 반환

```json
{ "code": "TODO_002", "message": "dueDate must be >= startDate" }
```

---

## 6. 프론트엔드 디렉토리 구조

```
frontend/
├── public/
├── src/
│   ├── main.tsx                        # 앱 진입점
│   ├── App.tsx                         # 라우터 설정
│   ├── infrastructure/
│   │   ├── apiClient.ts                # axios 인스턴스 + JWT 인터셉터 (토큰 갱신 포함)
│   │   └── queryClient.ts             # TanStack Query 전역 설정
│   ├── features/
│   │   ├── auth/
│   │   │   ├── api/authApi.ts          # login, register, logout, refresh 호출 함수
│   │   │   ├── hooks/
│   │   │   │   ├── useLogin.ts
│   │   │   │   ├── useRegister.ts
│   │   │   │   └── useLogout.ts
│   │   │   ├── store/authStore.ts      # 액세스 토큰, 유저 정보 (메모리 상태)
│   │   │   ├── components/
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   └── RegisterForm.tsx
│   │   │   └── types.ts
│   │   ├── todos/
│   │   │   ├── api/todoApi.ts          # CRUD + 완료 토글 호출 함수
│   │   │   ├── hooks/
│   │   │   │   ├── useTodoList.ts      # 필터·정렬·페이지네이션 포함
│   │   │   │   ├── useTodo.ts
│   │   │   │   ├── useCreateTodo.ts
│   │   │   │   ├── useUpdateTodo.ts
│   │   │   │   ├── useToggleDone.ts
│   │   │   │   └── useDeleteTodo.ts
│   │   │   ├── store/todoFilterStore.ts # 필터·정렬 UI 상태 (Zustand)
│   │   │   ├── components/
│   │   │   │   ├── TodoList.tsx
│   │   │   │   ├── TodoCard.tsx
│   │   │   │   ├── TodoForm.tsx
│   │   │   │   ├── StatusBadge.tsx     # TodoStatus enum → UI 표시
│   │   │   │   ├── StatusFilter.tsx
│   │   │   │   └── SortControl.tsx
│   │   │   └── types.ts               # Todo, TodoStatus, CreateTodoRequest 등
│   │   └── users/
│   │       ├── api/userApi.ts
│   │       ├── hooks/
│   │       │   ├── useUpdateProfile.ts
│   │       │   └── useDeleteAccount.ts
│   │       ├── components/ProfileForm.tsx
│   │       └── types.ts
│   ├── pages/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── TodoListPage.tsx
│   │   ├── TodoFormPage.tsx           # 생성 / 수정 겸용
│   │   └── ProfilePage.tsx
│   └── shared/
│       ├── components/
│       │   ├── Button.tsx
│       │   ├── Input.tsx
│       │   ├── Modal.tsx
│       │   ├── Pagination.tsx
│       │   └── ErrorMessage.tsx
│       ├── types/api.ts               # ApiResponse<T>, ErrorResponse
│       └── utils/dateUtils.ts         # UTC 날짜 포맷 유틸
├── .env.example
├── index.html
├── vite.config.ts
└── tsconfig.json
```

---

## 7. 백엔드 디렉토리 구조

```
backend/
├── src/
│   ├── index.js                        # 서버 시작, 포트 바인딩
│   ├── app.js                          # Express 앱 설정 (CORS, JSON, 라우터, 에러핸들러)
│   ├── config/
│   │   ├── db.js                       # pg Pool 생성 및 export (단일 인스턴스)
│   │   └── env.js                      # 환경변수 유효성 검증 및 export
│   ├── routes/
│   │   ├── index.js                    # 전체 라우터 통합
│   │   ├── authRoutes.js               # /api/auth/*
│   │   ├── userRoutes.js               # /api/users/*
│   │   └── todoRoutes.js               # /api/todos/*
│   ├── middlewares/
│   │   ├── authenticate.js             # JWT 검증, req.user 주입
│   │   ├── errorHandler.js             # AppError → JSON 응답 변환
│   │   └── validate.js                 # 요청 바디 유효성 검증
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── userController.js
│   │   └── todoController.js
│   ├── services/
│   │   ├── authService.js              # 회원가입, 로그인, 토큰 갱신 로직
│   │   ├── userService.js              # 정보수정, 탈퇴 로직
│   │   └── todoService.js             # CRUD + 상태 계산 (BR-S01~S05)
│   ├── repositories/
│   │   ├── userRepository.js           # users, refresh_tokens 쿼리
│   │   └── todoRepository.js          # todos 쿼리 (snake_case → camelCase 변환)
│   └── utils/
│       ├── statusCalculator.js         # calculateStatus(todo, today) 순수 함수
│       ├── passwordUtils.js            # bcrypt hash / compare
│       ├── jwtUtils.js                 # sign / verify accessToken, refreshToken
│       └── errors.js                   # AppError 클래스 정의
├── migrations/
│   └── 001_initial_schema.sql          # users, refresh_tokens, todos 테이블
├── .env.example
└── package.json
```

**`AppError` 활용 패턴**

Services에서 비즈니스 규칙 위반 시 `AppError`를 throw. 중앙 에러 핸들러가 HTTP 상태코드와 응답 바디를 결정한다.

```javascript
// services/todoService.js
if (todo.ownerId !== userId) {
  throw new AppError('TODO_003', 403, 'forbidden');
}

// utils/errors.js
class AppError extends Error {
  constructor(code, httpStatus, message) {
    super(message);
    this.code = code;
    this.httpStatus = httpStatus;
  }
}
```
