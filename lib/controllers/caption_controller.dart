import 'package:flutter/foundation.dart';

import '../interfaces/i_caption_view_model.dart';
import '../models/caption_style.dart';
import '../models/photo_caption.dart';
import '../repositories/caption_repository.dart';

/// 사진별 캡션 문구를 관리한다.
///
/// UI는 [ICaptionViewModel] 인터페이스만 통해 이 Controller와 상호작용한다.
class CaptionController extends ChangeNotifier implements ICaptionViewModel {
  final CaptionRepository _repo;

  /// assetId → PhotoCaption 인메모리 캐시
  final Map<String, PhotoCaption> _captions = {};

  CaptionController(this._repo);

  // ── Getters ──────────────────────────────────────────────────────────────────

  /// 특정 에셋의 캡션. 없으면 null.
  PhotoCaption? getCaption(String assetId) => _captions[assetId];

  /// 캡션이 있는 에셋 수
  int get captionCount => _captions.length;

  // ── 로드 ─────────────────────────────────────────────────────────────────────

  /// 지도 화면 진입 시 호출 — 주어진 assetId들의 캡션을 DB에서 일괄 로드.
  Future<void> loadCaptions(List<String> assetIds) async {
    final map = await _repo.findByAssetIds(assetIds);
    _captions
      ..clear()
      ..addAll(map);
    notifyListeners();
  }

  // ── 쓰기 ─────────────────────────────────────────────────────────────────────

  /// 캡션 저장 (없으면 insert, 있으면 update).
  Future<void> setCaption({
    required String assetId,
    required String text,
    CaptionStyle style = CaptionStyle.modern,
  }) async {
    final caption = PhotoCaption(assetId: assetId, text: text, style: style);
    await _repo.upsert(caption);
    _captions[assetId] = caption;
    notifyListeners();
  }

  /// 캡션 스타일만 변경.
  Future<void> updateStyle(String assetId, CaptionStyle style) async {
    final existing = _captions[assetId];
    if (existing == null) return;
    final updated = existing.copyWith(style: style);
    await _repo.upsert(updated);
    _captions[assetId] = updated;
    notifyListeners();
  }

  /// 캡션 삭제.
  Future<void> removeCaption(String assetId) async {
    await _repo.delete(assetId);
    _captions.remove(assetId);
    notifyListeners();
  }

  // ── 영상 생성용 ──────────────────────────────────────────────────────────────

  /// 주어진 assetId 목록 중 캡션이 있는 것만 반환.
  /// [VideoService.exportVideo] 에 전달한다.
  Map<String, PhotoCaption> captionsFor(List<String> assetIds) {
    return {
      for (final id in assetIds)
        if (_captions.containsKey(id)) id: _captions[id]!,
    };
  }
}
