import 'package:flutter/foundation.dart';

import '../controllers/archive_controller.dart';
import '../core/database/app_database.dart';
import '../models/photo_caption.dart';
import '../models/photo_metadata.dart';
import '../services/video_service.dart';

/// 영상 아카이브 ViewModel이 View에 노출하는 계약.
///
/// UI 컴포넌트는 [ArchiveController] 구체 클래스가 아니라
/// 이 인터페이스에만 의존한다.
///
/// Flutter에서 Custom Hook의 반환 타입에 해당한다.
abstract class IArchiveViewModel implements Listenable {
  // ── 상태 ──────────────────────────────────────────────────────────────────

  /// 생성/편집/완료/오류 sealed 상태
  ArchiveState get state;

  /// 저장된 아카이브 목록 (최신순)
  List<VideoArchive> get archives;

  // ── 읽기 ──────────────────────────────────────────────────────────────────

  /// 특정 아카이브의 GPS 포인트 (VideoDetailScreen 전용)
  Future<List<VideoGpsPoint>> getGpsPoints(int archiveId);

  /// 특정 아카이브의 편집 이력 로드 (최신순)
  Future<List<VideoEditHistoryData>> loadEditHistory(int archiveId);

  // ── 쓰기 ──────────────────────────────────────────────────────────────────

  /// 사진으로 영상을 생성하고 DB + 갤러리에 저장한다.
  Future<void> create({
    required List<dynamic> assets,        // AssetEntity (photo_manager)
    required List<PhotoMetadata> metadataList,
    required String title,
    double durationPerPhoto,
    Map<String, PhotoCaption>? captions,
  });

  /// 기존 영상에 편집 옵션을 적용한다.
  Future<void> applyEdit({
    required int archiveId,
    required VideoEditConfig config,
  });

  /// 특정 버전으로 롤백한다.
  Future<void> rollback(int archiveId, int version);

  /// 아카이브를 삭제한다.
  Future<void> delete(int archiveId);

  /// 상태를 idle로 초기화한다.
  void resetState();
}
