import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/extraction_result.dart';
import '../services/photo_service.dart';

/// 메타데이터 추출 작업의 상태를 관리한다.
/// Screen은 이 Controller를 구독하고 진행 상황을 UI에 반영한다.
class ExtractionController extends ChangeNotifier {
  // ─── 상태 ─────────────────────────────────────────────────────────────────

  bool _isExtracting = false;
  int _progress = 0;
  int _total = 0;
  ExtractionResult? _result;
  String? _errorMessage;

  // ─── Getters ──────────────────────────────────────────────────────────────

  bool get isExtracting => _isExtracting;
  int get progress => _progress;
  int get total => _total;
  ExtractionResult? get result => _result;
  String? get errorMessage => _errorMessage;

  /// 0.0 ~ 1.0 진행률 (위젯 ProgressIndicator에 그대로 전달)
  double get progressRatio => _total > 0 ? _progress / _total : 0.0;

  String get progressText => '$_progress / $_total';

  // ─── 추출 실행 ────────────────────────────────────────────────────────────

  Future<void> extract(List<AssetEntity> assets) async {
    if (_isExtracting || assets.isEmpty) return;

    _isExtracting = true;
    _progress = 0;
    _total = assets.length;
    _result = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await PhotoService.extractMetadata(
        assets,
        onProgress: (current, total) {
          _progress = current;
          // total은 변하지 않지만 혹시 모를 업데이트 반영
          _total = total;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = '추출 중 오류가 발생했습니다: $e';
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  void reset() {
    _isExtracting = false;
    _progress = 0;
    _total = 0;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}
