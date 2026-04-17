import 'package:drift/drift.dart';

import '../core/database/app_database.dart';

/// VideoArchive + VideoGpsPoint CRUD.
/// DB 접근의 유일한 창구 — Service/Controller만 이 클래스를 사용한다.
///
/// 반환 타입은 drift가 생성한 [VideoArchive], [VideoGpsPoint] 데이터 클래스를 사용한다.
class ArchiveRepository {
  final AppDatabase _db;

  const ArchiveRepository(this._db);

  // ── VideoArchive ────────────────────────────────────────────────────────────

  /// 저장된 전체 아카이브를 최신순으로 반환 (실시간 스트림).
  Stream<List<VideoArchive>> watchAll() {
    return (_db.select(_db.videoArchives)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// ID로 단건 조회. 없으면 null.
  Future<VideoArchive?> findById(int id) {
    return (_db.select(_db.videoArchives)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 새 아카이브 저장. 저장된 레코드의 id를 반환.
  Future<int> insert({
    required String title,
    required String videoPath,
    String? thumbnailPath,
    required DateTime createdAt,
    required int durationSeconds,
    required int gpsPointCount,
  }) {
    final now = createdAt;
    return _db.into(_db.videoArchives).insert(
          VideoArchivesCompanion.insert(
            title: title,
            videoPath: videoPath,
            originalVideoPath: videoPath,
            thumbnailPath: Value(thumbnailPath),
            createdAt: now,
            updatedAt: now,
            durationSeconds: durationSeconds,
            gpsPointCount: Value(gpsPointCount),
          ),
        );
  }

  /// 아카이브 삭제 (연결된 GPS 포인트도 함께 삭제).
  Future<void> delete(int id) async {
    await (_db.delete(_db.videoGpsPoints)
          ..where((t) => t.archiveId.equals(id)))
        .go();
    await (_db.delete(_db.videoArchives)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // ── VideoGpsPoint ───────────────────────────────────────────────────────────

  /// 특정 아카이브의 GPS 포인트를 orderIndex 순으로 반환.
  Future<List<VideoGpsPoint>> getGpsPoints(int archiveId) {
    return (_db.select(_db.videoGpsPoints)
          ..where((t) => t.archiveId.equals(archiveId))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

    /// GPS 포인트 목록 일괄 삽입.
  Future<void> insertGpsPoints(
      int archiveId, List<GpsPointInput> points) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.videoGpsPoints,
        points.map(
          (p) => VideoGpsPointsCompanion.insert(
            archiveId: archiveId,
            latitude: p.latitude,
            longitude: p.longitude,
            altitude: Value(p.altitude),
            capturedAt: p.capturedAt,
            photoAssetId: p.photoAssetId,
            orderIndex: p.orderIndex,
          ),
        ),
      );
    });
  }

  // ── VideoEditHistory ────────────────────────────────────────────────────────

  /// 편집 이력 전체 조회 (최신순).
  Future<List<VideoEditHistoryData>> getEditHistory(int archiveId) {
    return (_db.select(_db.videoEditHistory)
          ..where((t) => t.archiveId.equals(archiveId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// 편집 결과 저장 — 이력 추가 + 아카이브 최신 경로 및 편집 수 갱신.
  Future<void> saveEdit({
    required int archiveId,
    required String newVideoPath,
    required String editConfigJson,
  }) async {
    await _db.transaction(() async {
      final archive = await findById(archiveId);
      if (archive == null) return;

      final nextVersion = archive.editCount + 1;

      // 이력 추가
      await _db.into(_db.videoEditHistory).insert(
            VideoEditHistoryCompanion.insert(
              archiveId: archiveId,
              videoPath: newVideoPath,
              editConfigJson: editConfigJson,
              editedAt: DateTime.now(),
              version: nextVersion,
            ),
          );

      // 아카이브 최신 상태 갱신
      await (_db.update(_db.videoArchives)
            ..where((t) => t.id.equals(archiveId)))
          .write(VideoArchivesCompanion(
            videoPath: Value(newVideoPath),
            updatedAt: Value(DateTime.now()),
            editCount: Value(nextVersion),
            lastEditConfigJson: Value(editConfigJson),
          ));
    });
  }

  /// 특정 버전으로 롤백 — 해당 이력의 videoPath를 현재 버전으로 복원.
  Future<void> rollbackToVersion(int archiveId, int version) async {
    final history = await (_db.select(_db.videoEditHistory)
          ..where((t) =>
              t.archiveId.equals(archiveId) & t.version.equals(version)))
        .getSingleOrNull();
    if (history == null) return;

    await (_db.update(_db.videoArchives)
          ..where((t) => t.id.equals(archiveId)))
        .write(VideoArchivesCompanion(
          videoPath: Value(history.videoPath),
          updatedAt: Value(DateTime.now()),
          lastEditConfigJson: Value(history.editConfigJson),
        ));
  }
}

/// GPS 포인트 삽입용 입력 데이터 클래스 (DB 타입과 분리).
class GpsPointInput {
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime capturedAt;
  final String photoAssetId;
  final int orderIndex;

  const GpsPointInput({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.capturedAt,
    required this.photoAssetId,
    required this.orderIndex,
  });
}

