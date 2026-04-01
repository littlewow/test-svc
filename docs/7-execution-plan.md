# 실행 계획 (Execution Plan)

## 1. 환경 설정 및 초기화

### 1.1 PostgreSQL 설치 및 기본 설정
**예상 시간:** 0.5시간
**담당자:** BE 리드

**완료 조건:**
- [x] PostgreSQL 설치 완료 (v17.9)
- [x] `postgres` 유저로 접속 확인
- [x] `todolist_app` 데이터베이스 생성
- [x] `users`, `refresh_tokens`, `todos` 테이블 생성 (PRD 7절 스키마 기준)
- [x] 인덱스 생성 (`idx_todos_owner_id`, `idx_todos_owner_due_date`)

**의존성:**
- 없음

---

## 2. 백엔드 태스크 (BE-001 ~ BE-017)

### BE-001: 백엔드 프로젝트 초기화
**예상 시간:** 0.5시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `todolist-app/` 디렉토리에 Node.js 프로젝트 초기화 (`npm init`)
- [ ] `.gitignore` 생성 (node_modules, .env 포함)
- [ ] `nodemon` + `babel` 또는 `tsx`로 개발 서버 실행 확인
- [ ] `package.json` scripts 정의 (`dev`, `build`, `start`)

**의존성:**
- 없음

---

### BE-002: 의존성 설치
**예상 시간:** 0.5시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `package.json`에 주요 라이브러리 등록 및 설치:
  - `express` 4.x
  - `pg` 8.x
  - `bcryptjs` 2.x
  - `jsonwebtoken` 9.x
  - `dotenv` 16.x
  - `cors` 2.x
- [ ] 개발 의존성: `nodemon`, `@types/*` (또는 TypeScript 설정)
- [ ] `npm install` 완료 및 lock 파일 생성

**의존성:**
- BE-001

---

### BE-003: 프로젝트 디렉토리 구조 설정
**예상 시간:** 0.5시간
**담당자:** BE 리드

**완료 조건:**
- [ ] 다음 디렉토리 구조 생성:
  - `src/config/` (db.js, env.js)
  - `src/middlewares/` (authenticate.js, errorHandler.js)
  - `src/features/auth/` (repository, service, controller, routes)
  - `src/features/todos/` (repository, service, controller, routes)
  - `src/features/users/` (repository, service, controller, routes)
- [ ] `src/app.js` (Express 앱 설정)
- [ ] `src/index.js` (서버 진입점)

**의존성:**
- BE-002

---

### BE-004: DB 연결 설정
**예상 시간:** 0.5시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `src/config/db.js`에 `pg.Pool` 단일 인스턴스 생성
- [ ] 환경변수(`DATABASE_URL` 또는 개별 변수)로 연결 정보 관리
- [ ] 연결 테스트 쿼리 (`SELECT 1`) 성공 확인
- [ ] 연결 실패 시 서버 시작 중단 처리

**의존성:**
- BE-003
- 1.1 (PostgreSQL 설정 완료)

---

### BE-005: 환경변수 설정
**예상 시간:** 0.5시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `.env.example` 파일 생성:
  - `PORT`, `DATABASE_URL`
  - `JWT_SECRET`, `JWT_REFRESH_SECRET`
  - `CORS_ALLOWED_ORIGINS`
- [ ] `.env` 파일 생성 (로컬 개발용, gitignore 대상)
- [ ] `src/config/env.js`에서 환경변수 로드 및 필수값 검증

**의존성:**
- BE-003

---

### BE-006: Express 앱 기본 설정
**예상 시간:** 1시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `src/app.js` 구현:
  - `express.json()` 미들웨어
  - CORS 설정 (`CORS_ALLOWED_ORIGINS` 환경변수 기반)
  - `/api/auth`, `/api/todos`, `/api/users` 라우트 연결
- [ ] `GET /` 헬스체크 엔드포인트 (`{ status: "ok" }`)
- [ ] 개발 서버 정상 실행 확인 (포트 3000)

**의존성:**
- BE-005

---

### BE-007: 에러 핸들링 미들웨어
**예상 시간:** 1시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `src/middlewares/errorHandler.js` 구현:
  - `AppError` 클래스 정의 (`code`, `message`, `statusCode`)
  - Express 4-arg 에러 핸들러 (`err, req, res, next`)
  - 응답 형식: `{ code, message }` (PRD 6절 오류 응답 형식)
- [ ] 404 핸들러 등록 (정의되지 않은 라우트)
- [ ] `AUTH_*`, `TODO_*`, `USER_*` 에러 코드 상수 정의

**의존성:**
- BE-006

---

### BE-008: JWT 인증 미들웨어
**예상 시간:** 1시간
**담당자:** BE 리드

**완료 조건:**
- [ ] `src/middlewares/authenticate.js` 구현:
  - `Authorization: Bearer <token>` 헤더 파싱
  - `jsonwebtoken.verify()`로 액세스 토큰 검증
  - 검증 성공 시 `req.user = { id, email }` 설정
  - 토큰 없음/만료/변조 시 `AUTH_001` 에러 throw
- [ ] 보호 라우트에 미들웨어 적용 확인

**의존성:**
- BE-007

---

### BE-009: User Repository 구현
**예상 시간:** 1시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/users/repository.js` 구현:
  - `findByEmail(email)`: 이메일로 유저 조회
  - `findById(id)`: ID로 유저 조회
  - `create({ email, password, name })`: 유저 생성
  - `updateById(id, fields)`: 이름/비밀번호 수정
  - `deleteById(id)`: 유저 삭제

**의존성:**
- BE-004

---

### BE-010: Auth Service 구현
**예상 시간:** 2시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/auth/service.js` 구현:
  - `register({ email, password, name })`: 비밀번호 정책 검증, bcrypt 해싱, 유저 생성
  - `login({ email, password })`: 이메일 조회, bcrypt 비교, 액세스/리프레시 토큰 발급
  - `logout(refreshToken)`: refresh_tokens 테이블에서 토큰 삭제
  - `refresh(refreshToken)`: 토큰 검증 후 새 액세스 토큰 발급
- [ ] 액세스 토큰 1시간, 리프레시 토큰 7일 만료 설정

**의존성:**
- BE-009

---

### BE-011: Auth Controller + Routes 구현
**예상 시간:** 1시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/auth/controller.js` 구현 (POST register, login, logout, refresh)
- [ ] `src/features/auth/routes.js`에 `/api/auth/*` 라우트 등록
- [ ] 입력값 유효성 검증 (필수 필드 누락 시 오류 반환)
- [ ] 성공 응답 형식 준수 (`{ data, message }`)

**의존성:**
- BE-010

---

### BE-012: Todo Repository 구현
**예상 시간:** 1.5시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/todos/repository.js` 구현:
  - `findAll({ ownerId, sortBy, order, page, limit })`: 필터·정렬·페이지네이션 지원
  - `findById(id)`: 단건 조회
  - `create({ ownerId, title, description, startDate, dueDate })`: 생성
  - `updateById(id, fields)`: 수정
  - `toggleDone(id)`: done 토글
  - `deleteById(id)`: 삭제
- [ ] 총 건수 반환 (페이지네이션용 `total`)

**의존성:**
- BE-004

---

### BE-013: Todo Service 구현
**예상 시간:** 2시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/todos/service.js` 구현:
  - 소유자 검증 (`TODO_003`), 존재 여부 검증 (`TODO_004`)
  - 날짜 검증: `dueDate >= startDate` (`TODO_002`)
  - `calculateStatus(todo, nowUtc)`: BR-S01~BR-S05 상태 계산 함수
  - 모든 조회 응답에 `status` 필드 포함
- [ ] 상태 계산은 서버 UTC 날짜(일 단위) 기준

**의존성:**
- BE-012

---

### BE-014: Todo Controller + Routes 구현
**예상 시간:** 1시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/todos/controller.js` 구현 (GET list, GET one, POST, PUT, PATCH done, DELETE)
- [ ] `src/features/todos/routes.js`에 `/api/todos/*` 라우트 등록 (authenticate 미들웨어 적용)
- [ ] 쿼리 파라미터 파싱 및 기본값 적용 (sortBy: dueDate, order: ASC, page: 1, limit: 20)
- [ ] limit 최대 100 제한 처리

**의존성:**
- BE-013
- BE-008

---

### BE-015: User Profile Service 구현
**예상 시간:** 1시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/users/service.js` 구현:
  - `getMe(userId)`: 내 정보 조회
  - `updateMe(userId, { name, currentPassword, newPassword })`: 이름/비밀번호 수정
  - `deleteMe(userId, password)`: 비밀번호 재확인 후 탈퇴
- [ ] 비밀번호 변경 시 현재 비밀번호 검증 (`AUTH_002`)
- [ ] 탈퇴 시 CASCADE로 todos·refresh_tokens 자동 삭제 확인

**의존성:**
- BE-009

---

### BE-016: User Profile Controller + Routes 구현
**예상 시간:** 0.5시간
**담당자:** BE 개발자

**완료 조건:**
- [ ] `src/features/users/controller.js` 구현 (GET me, PUT me, DELETE me)
- [ ] `src/features/users/routes.js`에 `/api/users/*` 라우트 등록 (authenticate 미들웨어 적용)
- [ ] 성공 응답 형식 준수

**의존성:**
- BE-015
- BE-008

---

### BE-017: 통합 검증 및 최종 확인
**예상 시간:** 1시간
**담당자:** BE 리드

**완료 조건:**
- [ ] 전체 API 엔드포인트 동작 확인 (PRD 6절 기준)
- [ ] 에러 코드 응답 형식 일관성 검증
- [ ] 인증 미들웨어 보호 라우트 접근 제어 확인
- [ ] CASCADE 삭제 동작 확인 (회원 탈퇴 시 todos 삭제)
- [ ] `.env.example` 최신화

**의존성:**
- BE-011
- BE-014
- BE-016

---

## 3. 프론트엔드 태스크 (FE-001 ~ FE-017)

### FE-001: 프론트엔드 프로젝트 초기화
**예상 시간:** 0.5시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] Vite를 통한 React 19 프로젝트 초기화 완료
- [ ] TypeScript 설정 완료 (tsconfig.json, vite.config.ts)
- [ ] 개발 서버 정상 실행 확인 (포트 5173)
- [ ] 기본 App.tsx 구조 생성

**의존성:**
- 없음

---

### FE-002: 의존성 설치 및 설정
**예상 시간:** 1시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] package.json에 모든 주요 라이브러리 등록
  - zustand 5.x
  - @tanstack/react-query 5.x
  - react-router-dom 6.x
  - axios 1.x
  - tailwindcss 3.x
- [ ] npm install 완료 및 lock 파일 생성
- [ ] 개발/프로덕션 빌드 스크립트 검증

**의존성:**
- FE-001

---

### FE-003: Tailwind CSS 설정
**예상 시간:** 1시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] tailwind.config.js 및 postcss.config.js 생성
- [ ] 디자인 시스템 컬러 정의 (primary, success, warning, error, gray scale)
- [ ] 타이포그래피 설정 (font-family, size scale)
- [ ] globals.css에서 Tailwind directives 임포트
- [ ] 기본 컴포넌트에서 Tailwind 클래스 적용 테스트 완료

**의존성:**
- FE-002

---

### FE-004: 디렉토리 구조 설정
**예상 시간:** 0.5시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] 다음 디렉토리 구조 생성:
  - `src/infrastructure/` (apiClient, queryClient)
  - `src/features/auth/` (api, hooks, store, components, types)
  - `src/features/todos/` (api, hooks, store, components, types)
  - `src/features/users/` (api, hooks, components, types)
  - `src/pages/` (로그인, 회원가입, 할일 목록, 할일 폼, 프로필)
  - `src/shared/` (components, types, utils)
- [ ] 각 디렉토리에 index.ts 파일 생성

**의존성:**
- FE-002

---

### FE-005: API 클라이언트 설정
**예상 시간:** 2시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] infrastructure/apiClient.ts 구현:
  - axios 인스턴스 생성 (baseURL 환경변수 사용)
  - 요청 인터셉터: Authorization 헤더에 accessToken 자동 첨부
  - 응답 인터셉터: 401 에러 시 토큰 갱신 후 원래 요청 재시도
  - 토큰 갱신 중 중복 요청 방지 (Promise 기반 큐잉)
- [ ] 에러 처리 로직 통일 (ApiError 타입 정의)
- [ ] 개발/프로덕션 환경별 baseURL 설정 검증

**의존성:**
- FE-002

---

### FE-006: TanStack Query 설정
**예상 시간:** 0.5시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] infrastructure/queryClient.ts 생성
- [ ] defaultOptions 설정:
  - queries: staleTime 5분, cacheTime 10분
  - mutations: retry 1회
- [ ] QueryClientProvider로 App 래핑
- [ ] 개발 모드에서 React Query DevTools 활성화

**의존성:**
- FE-005

---

### FE-007: 공통 타입 정의
**예상 시간:** 1시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] shared/types/api.ts 생성:
  - ApiResponse<T> 제네릭 타입 (status, data, message)
  - ErrorResponse 타입 (status, message, errors)
- [ ] features/auth/types.ts:
  - User, LoginRequest, RegisterRequest, LoginResponse 타입
- [ ] features/todos/types.ts:
  - Todo, CreateTodoRequest, UpdateTodoRequest 타입
  - TodoStatus enum (Pending, InProgress, Overdue, Completed, LateCompleted)
- [ ] features/users/types.ts:
  - UserProfile 타입

**의존성:**
- FE-004

---

### FE-008: Zustand 인증 스토어 구현
**예상 시간:** 1시간  
**담당자:** FE 리드

**완로 조건:**
- [ ] features/auth/store/authStore.ts 구현:
  - 상태: accessToken (string | null), user (User | null)
  - 액션: setAuth(token, user), clearAuth()
  - 선택자: isAuthenticated, getAccessToken, getUser
- [ ] 메모리 기반 저장소 (localStorage 사용 금지)
- [ ] 개발 중에 상태 추적 로그 활성화 가능

**의존성:**
- FE-007

---

### FE-009: Zustand 할일 필터 스토어 구현
**예상 시간:** 1시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] features/todos/store/todoFilterStore.ts 구현:
  - 상태: statusFilter (TodoStatus[]), sortBy (string), order ('asc'|'desc'), page (number)
  - 액션: setStatusFilter, setSortBy, setOrder, setPage, reset
- [ ] 필터 조건이 변경되면 자동으로 page를 1로 리셋
- [ ] 필터 상태 직렬화 가능 (테스트 용이)

**의존성:**
- FE-007

---

### FE-010: 공통 컴포넌트 구현
**예상 시간:** 3시간  
**담당자:** FE 컴포넌트 개발자

**완료 조건:**
- [ ] shared/components/Button.tsx
  - 프로퍼티: variant (primary, secondary, danger), size (sm, md, lg), disabled, loading, onClick
  - Tailwind 클래스 조합으로 스타일 적용
- [ ] shared/components/Input.tsx
  - 프로퍼티: label, type, placeholder, value, onChange, error, disabled
  - 에러 메시지 표시 영역
- [ ] shared/components/Modal.tsx
  - 프로퍼티: isOpen, title, children, onClose, footerActions
  - 오버레이 클릭 시 닫기
- [ ] shared/components/Pagination.tsx
  - 프로퍼티: currentPage, totalPages, onPageChange
  - 이전/다음 버튼 + 페이지 번호 표시
- [ ] shared/components/ErrorMessage.tsx
  - 프로퍼티: message, onRetry
  - 에러 아이콘 + 재시도 버튼

**의존성:**
- FE-003

---

### FE-011: 상태 배지 컴포넌트 구현
**예상 시간:** 1시간  
**담당자:** FE 컴포넌트 개발자

**완료 조건:**
- [ ] features/todos/components/StatusBadge.tsx 구현:
  - 입력: TodoStatus enum 값
  - 색상 매핑:
    - Pending: gray
    - InProgress: blue
    - Overdue: red
    - Completed: green
    - LateCompleted: orange
  - 배지 크기 및 텍스트 레이블 표시

**의존성:**
- FE-010

---

### FE-012: Auth API 함수 구현
**예상 시간:** 1시간  
**담당자:** FE 백엔드 연동 개발자

**완료 조건:**
- [ ] features/auth/api/authApi.ts 구현:
  - login(email, password): Promise<LoginResponse>
  - register(email, password, name): Promise<LoginResponse>
  - logout(): Promise<void>
  - refreshToken(token): Promise<{accessToken: string}>
- [ ] 각 함수는 apiClient를 사용하여 백엔드 엔드포인트 호출
- [ ] 에러 응답 형식 일관성 검증

**의존성:**
- FE-005

---

### FE-013: Auth hooks 구현
**예상 시간:** 1.5시간  
**담당자:** FE 훅 개발자

**완로 조건:**
- [ ] features/auth/hooks/useLogin.ts
  - 입력: email, password
  - useMutation으로 구현, 성공 시 authStore.setAuth() 호출
  - 반환: mutate, isLoading, error
- [ ] features/auth/hooks/useRegister.ts
  - 입력: email, password, name
  - 회원가입 후 자동 로그인 (또는 로그인 페이지로 리디렉트)
- [ ] features/auth/hooks/useLogout.ts
  - 로그아웃 시 authStore.clearAuth() 호출
  - 모든 쿼리 캐시 무효화

**의존성:**
- FE-012

---

### FE-014: Todo API 함수 구현
**예상 시간:** 1.5시간  
**담당자:** FE 백엔드 연동 개발자

**완료 조건:**
- [ ] features/todos/api/todoApi.ts 구현:
  - getTodoList(filters): Promise<{data: Todo[], total: number}>
  - getTodo(id): Promise<Todo>
  - createTodo(req): Promise<Todo>
  - updateTodo(id, req): Promise<Todo>
  - toggleDone(id): Promise<Todo>
  - deleteTodo(id): Promise<void>
- [ ] 각 함수는 apiClient 사용
- [ ] 필터 객체를 쿼리 파라미터로 변환

**의존성:**
- FE-005

---

### FE-015: Todo hooks 구현
**예상 시간:** 2시간  
**담당자:** FE 훅 개발자

**완료 조건:**
- [ ] features/todos/hooks/useTodoList.ts
  - 입력: todoFilterStore에서 필터 상태 읽음
  - useQuery로 getTodoList 호출, 필터 변경 시 자동 재호출
  - 반환: data, isLoading, error, isFetching
- [ ] features/todos/hooks/useTodo.ts
  - 입력: todoId
  - useQuery로 getTodo 호출
- [ ] features/todos/hooks/useCreateTodo.ts
  - useMutation, 성공 시 쿼리 캐시 무효화
- [ ] features/todos/hooks/useUpdateTodo.ts
  - useMutation, 낙관적 업데이트 구현 (선택)
- [ ] features/todos/hooks/useToggleDone.ts
  - useMutation, 빠른 반응
- [ ] features/todos/hooks/useDeleteTodo.ts
  - useMutation, 삭제 확인 로직 구현 (컴포넌트 레벨)

**의존성:**
- FE-014

---

### FE-016: 페이지 컴포넌트 구현
**예상 시간:** 4시간  
**담당자:** FE 페이지 개발자

**완료 조건:**
- [ ] pages/LoginPage.tsx
  - 이메일, 비밀번호 입력
  - useLogin 훅 사용
  - 회원가입 페이지 링크
  - 401 에러 시 명확한 메시지
- [ ] pages/RegisterPage.tsx
  - 이메일, 비밀번호, 이름 입력
  - 비밀번호 확인 필드 포함
  - useRegister 훅 사용
  - 가입 성공 시 로그인 페이지로 리디렉트
- [ ] pages/TodoListPage.tsx
  - useTodoList 훅으로 할일 목록 표시
  - StatusBadge 컴포넌트로 상태 표시
  - 필터 UI (상태별 탭 또는 드롭다운)
  - 정렬 옵션 (생성일, 마감일, 우선순위)
  - Pagination 컴포넌트
  - 새 할일 추가 버튼
  - 각 할일: 제목, 상태, 마감일, 수정/삭제/완료 버튼
- [ ] pages/TodoFormPage.tsx (생성 및 수정)
  - 생성 모드: 제목, 설명, 마감일 입력
  - 수정 모드: useTodo로 기존 데이터 로드 후 프리필 (prefill)
  - useCreateTodo/useUpdateTodo 훅 사용
  - 성공 시 할일 목록 페이지로 리디렉트
- [ ] pages/ProfilePage.tsx
  - 현재 사용자 정보 표시 (이메일, 이름)
  - 비밀번호 변경 폼 (선택 기능)
  - 로그아웃 버튼

**의존성:**
- FE-010
- FE-013
- FE-015

---

### FE-017: 라우팅 설정 및 보호 라우트 구현
**예상 시간:** 1.5시간  
**담당자:** FE 리드

**완료 조건:**
- [ ] App.tsx에서 react-router-dom v6 라우트 정의:
  - `/login` (공개)
  - `/register` (공개)
  - `/` (보호됨, 할일 목록)
  - `/todos/new` (보호됨, 할일 생성)
  - `/todos/:id/edit` (보호됨, 할일 수정)
  - `/profile` (보호됨, 프로필)
- [ ] ProtectedRoute 컴포넌트 구현:
  - 비인증 사용자는 `/login`으로 리디렉트
  - authStore.isAuthenticated 확인
- [ ] 레이아웃 구성 (헤더, 사이드바 선택)
  - 헤더: 로고, 프로필 링크, 로그아웃 버튼
  - 비인증 페이지: 단순 레이아웃
- [ ] 에러 바운더리 설정 (선택)
- [ ] 404 페이지 구현

**의존성:**
- FE-016

---

## 4. 통합 및 배포 태스크 (INT-001 ~ INT-007)

### INT-001: Vercel 프로젝트 생성
**예상 시간:** 0.5시간  
**담당자:** DevOps/배포 담당자

**완료 조건:**
- [ ] Vercel 계정 로그인 (또는 생성)
- [ ] GitHub 저장소에서 새 프로젝트 임포트
- [ ] 프로젝트명 및 기본 설정 확인
- [ ] Vercel 프로젝트 URL 확보

**의존성:**
- 없음

---

### INT-002: 환경변수 설정
**예상 시간:** 0.5시간  
**담당자:** DevOps/배포 담당자

**완로 조건:**
- [ ] Vercel 대시보드에서 Environment Variables 탭 접근
- [ ] 다음 변수 등록 (프로덕션 환경):
  - `DATABASE_URL` (PostgreSQL 연결 문자열)
  - `JWT_SECRET` (백엔드 JWT 서명 키)
  - `JWT_REFRESH_SECRET` (토큰 갱신용 시크릿)
  - `VITE_API_BASE_URL` (프론트엔드용 API 베이스 URL, 예: https://[project].vercel.app/api)
- [ ] 개발 환경 변수도 별도 등록 (선택)
- [ ] 환경변수 암호화 및 접근 권한 확인

**의존성:**
- INT-001

---

### INT-003: 백엔드 Vercel 배포 설정
**예상 시간:** 1.5시간  
**담당자:** DevOps/배포 담당자

**완료 조건:**
- [ ] vercel.json 파일 생성/수정:
  - buildCommand: Node.js 빌드 스크립트
  - outputDirectory: 빌드 결과물 디렉토리
- [ ] API 라우트 rewrites 설정:
  - `/api/*` → `api/` 함수 매핑
  - `/todolist/*` → Express 라우트 매핑 (또는 서버리스 함수)
- [ ] 대안: Vercel Functions으로 Express 앱 래핑
- [ ] 환경변수 참조 확인 (DATABASE_URL 등)
- [ ] 프로덕션 배포 전 스테이징 환경에서 테스트

**의존성:**
- BE-017 (백엔드 구현 완료)
- INT-002

---

### INT-004: 프론트엔드 Vercel 배포 설정
**예상 시간:** 1시간  
**담당자:** DevOps/배포 담당자

**완로 조건:**
- [ ] vercel.json 또는 Vercel 대시보드에서 설정:
  - buildCommand: `npm run build` (Vite)
  - outputDirectory: `dist/`
- [ ] SPA 라우팅 설정:
  - 모든 404 요청을 `index.html`로 리디렉트 (rewrites 사용)
- [ ] 환경변수 참조:
  - `VITE_API_BASE_URL` 프로덕션 값 적용
- [ ] 빌드 최적화:
  - Tree-shaking, 청크 분할 확인
  - 번들 크기 검증 (예: < 500KB)
- [ ] 프로덕션 배포 테스트

**의존성:**
- FE-017 (프론트엔드 구현 완료)
- INT-002

---

### INT-005: CORS 설정
**예상 시간:** 0.5시간  
**담당자:** 백엔드/DevOps 담당자

**완료 조건:**
- [ ] 백엔드에서 CORS 미들웨어 설정:
  - 프로덕션 허용 오리진: 환경변수 `CORS_ALLOWED_ORIGINS`에서 읽음
  - 예: `https://[project].vercel.app`
- [ ] 크레덴셜 포함 요청 허용 (`credentials: 'include'`)
- [ ] 프론트엔드 axioss 클라이언트와 호환성 확인
- [ ] 개발 환경: localhost:3000, localhost:5173 등 추가
- [ ] 크로스도메인 쿠키 사용 시 SameSite 속성 설정

**의존성:**
- INT-003

---

### INT-006: 통합 테스트
**예상 시간:** 3시간  
**담당자:** QA/테스트 담당자

**완료 조건:**
- [ ] 다음 전체 사용 사례 검증 (프로덕션 또는 스테이징 환경):
  - UC-01: 회원가입 → 이메일 검증 (선택) → 계정 생성
  - UC-02: 로그인 → JWT 토큰 획득 → 상태 저장
  - UC-03: 할일 목록 조회 → 상태 필터링 → 정렬 및 페이지네이션
  - UC-04: 새 할일 생성 → 유효성 검증 → 목록 갱신
  - UC-05: 할일 수정 → 필드 업데이트 → 즉시 반영
  - UC-06: 할일 완료 토글 → 상태 변경 → 뱃지 업데이트
  - UC-07: 할일 삭제 → 확인 다이얼로그 → 목록에서 제거
  - UC-08: 프로필 페이지 → 사용자 정보 표시 → 로그아웃
  - UC-09: 토큰 만료 → 자동 갱신 → 요청 재시도
  - UC-10: 네트워크 오류 → 재시도 버튼 표시 → 복구
- [ ] 모든 API 응답 형식 일관성 확인
- [ ] 에러 메시지 명확성 검증
- [ ] UI/UX 흐름 사용성 확인
- [ ] 성능 기준 충족 확인 (응답 시간 < 2초)

**의존성:**
- INT-005

---

### INT-007: 성능 최적화 및 모니터링
**예상 시간:** 1시간  
**담당자:** 성능 최적화/모니터링 담당자

**완료 조건:**
- [ ] Lighthouse 분석 (프로덕션):
  - Performance: 90점 이상
  - Accessibility: 85점 이상
  - Best Practices: 90점 이상
  - SEO: 80점 이상
- [ ] 번들 분석:
  - 주요 번들 크기 확인 (gzip 기준)
  - 불필요한 라이브러리 제거
- [ ] Vercel Analytics 활성화:
  - Core Web Vitals 모니터링
  - 지역별 성능 추적
- [ ] 에러 로깅 설정 (선택):
  - Sentry 또는 유사 서비스 통합
  - 프로덕션 에러 추적
- [ ] 캐싱 전략 확인:
  - 정적 자산 HTTP 캐시 헤더
  - API 응답 캐싱 (TanStack Query)
- [ ] 최종 배포 준비 완료

**의존성:**
- INT-006
