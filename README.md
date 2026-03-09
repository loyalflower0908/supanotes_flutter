# 📝 SupaNotes

**SupaNotes**는 Flutter와 Supabase를 결합하여 제작된 크로스플랫폼 노트 애플리케이션입니다. 강력한 실시간 동기화 기능을 통해 언제 어디서나 끊김 없는 메모 경험을 제공합니다.

## 🚀 주요 특징

* **실시간 동기화 (Real-time Sync):** Supabase Realtime 기능을 활용하여 여러 기기 간에 데이터가 즉각적으로 동기화됩니다.
* **체계적인 폴더 관리:** 사용자 정의 폴더를 생성, 수정, 삭제하여 노트를 효율적으로 분류할 수 있습니다.
* **직관적인 UX/UX:** 스와이프를 통한 삭제, 탐색 드로어(Drawer)를 이용한 빠른 이동 등 모바일에 최적화된 인터페이스를 제공합니다.
* **스마트 필터링:** '모든 노트'와 '미분류 노트' 뷰를 통해 필요한 정보를 빠르게 찾아낼 수 있습니다.
* **강력한 백엔드:** Supabase의 안정적인 PostgreSQL 데이터베이스를 기반으로 데이터의 무결성을 보장합니다.

## 🛠 기술 스택

* **Frontend:** Flutter (Cross-platform framework)
* **State Management:** Provider
* **Backend/Database:** Supabase (PostgreSQL & Realtime)
* **Language:** Dart

---

## 🏁 시작하기 (Getting Started)

이 프로젝트를 로컬 환경에서 실행하기 위한 단계별 안내입니다.

### 1단계: 사전 준비

* [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (최신 안정 버전 권장)
* [Supabase](https://supabase.com/) 계정 생성 및 새 프로젝트 생성

### 2단계: Supabase 프로젝트 설정

1. Supabase 대시보드에서 **SQL Editor**로 이동합니다.
2. 아래의 SQL 쿼리를 실행하여 테이블 스키마를 생성하고 실시간 기능을 활성화합니다.

```sql
-- folders 테이블 생성
CREATE TABLE folders (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- notes 테이블 생성
CREATE TABLE notes (
  id SERIAL PRIMARY KEY,
  folder_id INTEGER REFERENCES folders(id) ON DELETE CASCADE,
  title TEXT,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 실시간 기능을 위해 테이블 활성화
ALTER PUBLICATION supabase_realtime ADD TABLE folders, notes;

```

3. **Project Settings > API** 섹션에서 `Project URL`과 `anon public key`를 복사하여 안전한 곳에 보관하세요.

### 3단계: 애플리케이션 실행

1. 저장소를 클론합니다.
```bash
git clone https://github.com/your-username/SupaNotes.git
cd SupaNotes

```


2. 의존성 패키지를 설치합니다.
```bash
flutter pub get

```


3. 복사해둔 API 정보를 포함하여 앱을 실행합니다.
```bash
flutter run --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY

```



---

## 📁 프로젝트 구조 (Project Structure)

```text
lib/
├── models/         # 데이터 모델 (Note, Folder)
├── providers/      # 상태 관리 logic (Provider)
├── services/       # Supabase API 통신 서비스
├── screens/        # UI 화면 (Home, Edit, List)
└── widgets/        # 재사용 가능한 UI 컴포넌트

```

## ⚖️ 라이선스 (License)

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](https://www.google.com/search?q=LICENSE) 파일을 참조하세요.

---

**SupaNotes**를 통해 더 생산적인 기록 습관을 만들어 보세요! 추가로 구현하고 싶은 기능이나 궁금한 점이 있다면 언제든 문의해 주세요.

---
## 📚 느낀점

해당 프로젝트는 윈도우, 맥 PC를 번갈아가면서 쓰다가 모든 플랫폼에서 공유되는 개인 노트 앱을 가지고 싶어서 제작하였다.

---

## 🕐 개발 기간 🕐

2026.02.03 ~ 2026.02.24
