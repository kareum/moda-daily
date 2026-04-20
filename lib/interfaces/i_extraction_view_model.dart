import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/extraction_result.dart';

/// 메타데이터 추출 ViewModel이 View에 노출하는 계약.
abstract class IExtractionViewModel implements Listenable {
  // ── 상태 ──────────────────────────────────────────────────────────────────

  bool get isExtracting;
  int get progress;
  int get total;
  double get progressRatio;
  String get progressText;
  ExtractionResult? get result;
  String? get errorMessage;

  // ── 액션 ──────────────────────────────────────────────────────────────────

  Future<void> extract(List<AssetEntity> assets);
  void reset();
}
