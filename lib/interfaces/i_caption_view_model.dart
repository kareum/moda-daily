import 'package:flutter/foundation.dart';

import '../models/caption_style.dart';
import '../models/photo_caption.dart';

/// 캡션 ViewModel이 View에 노출하는 계약.
abstract class ICaptionViewModel implements Listenable {
  // ── 상태 ──────────────────────────────────────────────────────────────────

  /// 캡션이 저장된 에셋 수
  int get captionCount;

  // ── 읽기 ──────────────────────────────────────────────────────────────────

  /// 특정 에셋의 캡션. 없으면 null.
  PhotoCaption? getCaption(String assetId);

  /// 영상 생성용: 주어진 assetId 목록 중 캡션이 있는 것만 반환.
  Map<String, PhotoCaption> captionsFor(List<String> assetIds);

  // ── 쓰기 ──────────────────────────────────────────────────────────────────

  /// 주어진 에셋 목록의 캡션을 DB에서 로드한다.
  Future<void> loadCaptions(List<String> assetIds);

  /// 캡션을 저장(upsert)한다.
  Future<void> setCaption({
    required String assetId,
    required String text,
    CaptionStyle style,
  });

  /// 캡션 스타일만 변경한다.
  Future<void> updateStyle(String assetId, CaptionStyle style);

  /// 캡션을 삭제한다.
  Future<void> removeCaption(String assetId);
}
