import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/photo_service.dart';

enum PermissionStatus { initial, granted, limited, denied }

/// 사진 선택 화면의 상태를 관리한다.
/// Screen은 이 Controller를 구독(ListenableBuilder)하고,
/// 직접 PhotoService를 호출하지 않는다.
class PhotoSelectionController extends ChangeNotifier {
  // ─── 상태 ─────────────────────────────────────────────────────────────────

  PermissionStatus _permissionStatus = PermissionStatus.initial;
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  List<AssetEntity> _assets = [];
  final Set<String> _selectedIds = {};
  DateTimeRange? _dateFilter;

  bool _isLoadingAlbums = false;
  bool _isLoadingPhotos = false;
  bool _hasMorePhotos = true;
  int _currentPage = 0;
  String? _errorMessage;

  static const _pageSize = 80;

  // ─── Getters (Screen/Widget이 읽는 공개 인터페이스) ─────────────────────

  PermissionStatus get permissionStatus => _permissionStatus;
  List<AssetPathEntity> get albums => List.unmodifiable(_albums);
  AssetPathEntity? get currentAlbum => _currentAlbum;
  List<AssetEntity> get assets => List.unmodifiable(_assets);
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);
  DateTimeRange? get dateFilter => _dateFilter;
  bool get isLoadingAlbums => _isLoadingAlbums;
  bool get isLoadingPhotos => _isLoadingPhotos;
  bool get hasMorePhotos => _hasMorePhotos;
  String? get errorMessage => _errorMessage;

  int get selectedCount => _selectedIds.length;
  bool isSelected(String id) => _selectedIds.contains(id);

  /// 현재 로드된 에셋 중 선택된 것만 반환 (메타데이터 추출 전달용)
  List<AssetEntity> get selectedAssets =>
      _assets.where((a) => _selectedIds.contains(a.id)).toList();

  // ─── 초기화 ───────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // ACCESS_MEDIA_LOCATION 포함 권한 요청
    // Android 10+에서 이 권한 없이 파일 읽으면 GPS EXIF가 자동 제거됨
    PhotoManager.setIgnorePermissionCheck(false);
    final state = await PhotoService.requestPermission();
    _permissionStatus = switch (state) {
      PermissionState.authorized => PermissionStatus.granted,
      PermissionState.limited => PermissionStatus.limited,
      _ => PermissionStatus.denied,
    };
    notifyListeners();

    if (_permissionStatus != PermissionStatus.denied) {
      await _loadAlbums();
    }
  }

  Future<void> openAppSettings() => PhotoService.openSettings();

  // ─── 앨범 로드 ────────────────────────────────────────────────────────────

  Future<void> _loadAlbums() async {
    _isLoadingAlbums = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _albums = await PhotoService.getAlbums();
      if (_albums.isNotEmpty) {
        _currentAlbum = _albums.first;
        await _loadPhotos(reset: true);
      }
    } catch (e) {
      _errorMessage = '앨범을 불러오지 못했습니다: $e';
    } finally {
      _isLoadingAlbums = false;
      notifyListeners();
    }
  }

  // ─── 앨범 / 날짜 필터 변경 ──────────────────────────────────────────────

  Future<void> selectAlbum(AssetPathEntity album) async {
    if (_currentAlbum?.id == album.id) return;
    _currentAlbum = album;
    _dateFilter = null;
    clearSelection();
    await _loadPhotos(reset: true);
  }

  Future<void> applyDateFilter(DateTimeRange? range) async {
    _dateFilter = range;
    clearSelection();
    await _loadPhotos(reset: true);
  }

  // ─── 사진 로드 (페이지네이션) ────────────────────────────────────────────

  Future<void> _loadPhotos({bool reset = false}) async {
    if (_currentAlbum == null) return;
    if (_isLoadingPhotos) return;

    if (reset) {
      _currentPage = 0;
      _assets = [];
      _hasMorePhotos = true;
    }

    _isLoadingPhotos = true;
    notifyListeners();

    try {
      final List<AssetEntity> fetched;
      if (_dateFilter != null) {
        fetched = await PhotoService.getPhotosByDateRange(
          _currentAlbum!,
          _dateFilter!,
          page: _currentPage,
          pageSize: _pageSize,
        );
      } else {
        fetched = await PhotoService.getPhotos(
          _currentAlbum!,
          page: _currentPage,
          pageSize: _pageSize,
        );
      }

      _assets = reset ? fetched : [..._assets, ...fetched];
      _hasMorePhotos = fetched.length >= _pageSize;
      _currentPage++;
    } catch (e) {
      _errorMessage = '사진을 불러오지 못했습니다: $e';
    } finally {
      _isLoadingPhotos = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePhotos() async {
    if (!_hasMorePhotos || _isLoadingPhotos) return;
    await _loadPhotos();
  }

  // ─── 선택 관리 ────────────────────────────────────────────────────────────

  void toggleSelection(String assetId) {
    if (_selectedIds.contains(assetId)) {
      _selectedIds.remove(assetId);
    } else {
      _selectedIds.add(assetId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.addAll(_assets.map((a) => a.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }
}
