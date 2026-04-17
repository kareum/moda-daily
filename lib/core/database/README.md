# core/database

drift 기반 로컬 SQLite DB. 앱의 영구 저장소 레이어.

---

## 파일

| 파일 | 설명 |
|---|---|
| `app_database.dart` | 테이블 정의 + `AppDatabase` 클래스 |
| `app_database.g.dart` | drift 코드 생성 결과 (직접 수정 금지) |

---

## 테이블 구조

### VideoArchives

생성/편집된 숏폼 영상 아카이브 1건.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | int PK | auto-increment |
| `title` | text | 영상 제목 |
| `videoPath` | text | 현재(최신) MP4 파일 경로 |
| `originalVideoPath` | text | 최초 생성 원본 경로 — 편집 후에도 유지 |
| `thumbnailPath` | text? | 첫 프레임 썸네일 경로 |
| `createdAt` | datetime | 최초 생성 시각 |
| `updatedAt` | datetime | 마지막 수정 시각 |
| `durationSeconds` | int | 영상 길이 (초) |
| `gpsPointCount` | int | 연결된 GPS 포인트 수 (편의 집계) |
| `editCount` | int | 편집 횟수 (0 = 원본) |
| `lastEditConfigJson` | text? | 마지막 편집 설정 JSON |

---

### VideoGpsPoints

영상과 1:N으로 연결된 GPS 포인트. 영상 재생 경로를 구성한다.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | int PK | auto-increment |
| `archiveId` | int FK | `VideoArchives.id` |
| `latitude` | real | 위도 |
| `longitude` | real | 경도 |
| `altitude` | real? | 고도 (m) |
| `capturedAt` | datetime | 사진 촬영 시각 |
| `photoAssetId` | text | photo_manager `AssetEntity.id` |
| `orderIndex` | int | 영상 내 재생 순서 (0-based) |

---

### VideoEditHistory

편집할 때마다 1행 추가되는 이력 테이블. 버전 롤백에 사용.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | int PK | auto-increment |
| `archiveId` | int FK | `VideoArchives.id` |
| `videoPath` | text | 이 편집 버전의 MP4 경로 |
| `editConfigJson` | text | 적용된 편집 설정 JSON |
| `editedAt` | datetime | 편집 시각 |
| `version` | int | 편집 버전 번호 (1부터) |

---

## 관계 다이어그램

```
VideoArchives (1)
    ├── VideoGpsPoints (N)   — 영상 재생 경로
    └── VideoEditHistory (N) — 편집 버전 이력
```

---

## 사용법

```dart
// DB 싱글턴 생성
final db = AppDatabase();

// Repository를 통해서만 접근 (직접 쿼리 금지)
final repo = ArchiveRepository(db);

// 저장
final id = await repo.insert(title: '제주 여행', videoPath: '/path/to/video.mp4', ...);

// 조회 (실시간 스트림)
repo.watchAll().listen((archives) { ... });

// 편집 저장 (이력 자동 추가)
await repo.saveEdit(archiveId: id, newVideoPath: '/path/to/edited.mp4', editConfigJson: '{"bgm":"track1"}');

// 롤백
await repo.rollbackToVersion(archiveId: id, version: 1);
```

---

## 코드 재생성

스키마 변경 후 반드시 실행:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> `schemaVersion`을 올리고 `MigrationStrategy`를 `app_database.dart`에 추가해야 기존 설치 앱에서 데이터가 유지된다.
