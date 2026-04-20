import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:photo_manager/photo_manager.dart';

import '../controllers/photo_selection_controller.dart';

/// 사진 선택 화면 ViewModel이 View에 노출하는 계약.
abstract class IPhotoSelectionViewModel implements Listenable {
  // ── 상태 ──────────────────────────────────────────────────────────────────

  PermissionStatus get permissionStatus;
  List<AssetPathEntity> get albums;
  AssetPathEntity? get currentAlbum;
  List<AssetEntity> get assets;
  Set<String> get selectedIds;
  DateTimeRange? get dateFilter;
  bool get isLoadingAlbums;
  bool get isLoadingPhotos;
  bool get hasMorePhotos;
  String? get errorMessage;

  // ── 파생 값 ───────────────────────────────────────────────────────────────

  int get selectedCount;
  bool isSelected(String id);

  /// 선택된 에셋 목록 (추출 플로우 전달용)
  List<AssetEntity> get selectedAssets;

  // ── 액션 ──────────────────────────────────────────────────────────────────

  Future<void> initialize();
  Future<void> selectAlbum(AssetPathEntity album);
  void toggleSelection(String assetId);
  void selectAll();
  void clearSelection();
  Future<void> applyDateFilter(DateTimeRange? range);
  Future<void> loadMore();

  /// 앱 시스템 설정 열기 (권한 거부 후 사용자 안내용)
  Future<void> openAppSettings();
}
