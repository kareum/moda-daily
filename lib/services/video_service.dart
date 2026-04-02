/// 영상 내보내기 진행률 콜백 타입 (0.0 ~ 1.0)
typedef VideoProgressCallback = void Function(double progress);

/// FFmpeg 기반 영상 렌더링 서비스 (F-3에서 구현).
/// 지도 애니메이션 + 사진 슬라이드쇼 → MP4 합성을 담당한다.
class VideoService {
  VideoService._();

  /// 선택된 사진 에셋 ID 목록을 받아 숏폼 영상(9:16)을 생성한다.
  /// 반환값: 저장된 MP4 파일 경로.
  /// MVP 이후 구현 예정 — 현재는 NotImplementedError.
  static Future<String> exportVideo({
    required List<String> assetIds,
    int durationSeconds = 30,
    VideoProgressCallback? onProgress,
  }) async {
    // TODO(F-3): ffmpeg_kit_flutter 연동
    throw UnimplementedError('F-3 단계에서 구현 예정');
  }
}
