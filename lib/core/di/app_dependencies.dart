import '../../controllers/archive_controller.dart';
import '../../controllers/caption_controller.dart';
import '../../controllers/extraction_controller.dart';
import '../../controllers/photo_selection_controller.dart';
import '../../repositories/archive_repository.dart';
import '../../repositories/caption_repository.dart';
import '../database/app_database.dart';

/// 앱 전역 의존성 컨테이너 (Singleton).
///
/// - AppDatabase / Repository는 앱 생명주기 동안 단일 인스턴스를 공유한다.
/// - Controller는 화면 생명주기에 맞게 팩토리 메서드로 생성한다.
///   (ChangeNotifier이므로 화면 dispose 시 직접 dispose 필요)
///
/// 사용법:
/// ```dart
/// final ctrl = AppDependencies.instance.createArchiveController();
/// ```
class AppDependencies {
  AppDependencies._();
  static final AppDependencies instance = AppDependencies._();

  // ── 싱글톤 DB · Repository ─────────────────────────────────────────────────

  final AppDatabase _db = AppDatabase();

  late final ArchiveRepository archiveRepository =
      ArchiveRepository(_db);

  late final CaptionRepository captionRepository =
      CaptionRepository(_db);

  // ── Controller 팩토리 (화면마다 새 인스턴스) ──────────────────────────────────

  /// 영상 아카이브 Controller.
  /// 반환된 인스턴스는 화면 dispose 시 dispose() 호출 필요.
  ArchiveController createArchiveController() =>
      ArchiveController(archiveRepository)..init();

  /// 캡션 Controller.
  CaptionController createCaptionController() =>
      CaptionController(captionRepository);

  /// 사진 선택 Controller.
  PhotoSelectionController createPhotoSelectionController() =>
      PhotoSelectionController();

  /// 메타데이터 추출 Controller.
  ExtractionController createExtractionController() =>
      ExtractionController();
}
