import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ── 테이블 정의 ────────────────────────────────────────────────────────────────

/// 생성/편집된 숏폼 영상 아카이브.
class VideoArchives extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// 최종 저장된 MP4 경로 (camera roll 또는 앱 내부 경로)
  TextColumn get videoPath => text()();

  /// 첫 프레임 썸네일 경로
  TextColumn get thumbnailPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get durationSeconds => integer()();
  IntColumn get gpsPointCount => integer().withDefault(const Constant(0))();

  // ── 편집 메타 ────────────────────────────────────────────────────────────
  // 편집 시 덮어쓰지 않고 이력을 남길 수 있도록 원본 경로를 보존한다.

  /// 최초 생성된 원본 MP4 경로 (편집 후에도 유지)
  TextColumn get originalVideoPath => text()();

  /// 편집 횟수 (0 = 원본 그대로)
  IntColumn get editCount => integer().withDefault(const Constant(0))();

  /// 마지막으로 적용된 편집 설정 JSON (bgm, speed, filter 등)
  /// null이면 편집 이력 없음
  TextColumn get lastEditConfigJson => text().nullable()();
}

/// 영상에 연결된 GPS 포인트 (영상 재생 경로).
class VideoGpsPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get archiveId => integer().references(VideoArchives, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get photoAssetId => text()();

  /// 영상 내 재생 순서 (0-based)
  IntColumn get orderIndex => integer()();
}

/// 영상 편집 이력 — 편집할 때마다 1행 추가.
/// 이전 버전으로 롤백하거나 편집 흐름을 추적할 때 사용.
class VideoEditHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get archiveId => integer().references(VideoArchives, #id)();

  /// 이 편집 버전의 MP4 경로 (원본 덮어쓰지 않고 별도 파일)
  TextColumn get videoPath => text()();

  /// 적용된 편집 설정 JSON (bgm, speed, trimStart, trimEnd, filter 등)
  TextColumn get editConfigJson => text()();

  DateTimeColumn get editedAt => dateTime()();

  /// 편집 버전 번호 (1부터 시작)
  IntColumn get version => integer()();
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [VideoArchives, VideoGpsPoints, VideoEditHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'travel_map_archiver');
  }
}
