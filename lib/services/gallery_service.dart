import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

/// 생성된 영상/이미지를 기기 카메라 롤(갤러리)에 저장하는 서비스.
///
/// photo_manager를 사용해 iOS 포토 라이브러리 / Android MediaStore에 저장한다.
/// 파일 I/O만 담당하며 DB 기록은 [ArchiveRepository]가 처리한다.
class GalleryService {
  GalleryService._();

  /// MP4 파일을 카메라 롤에 저장한다.
  ///
  /// [filePath]: 저장할 MP4 파일의 로컬 절대 경로
  /// [albumName]: 저장될 앨범 이름 (기본값: 'TravelMap ArchiVer')
  ///
  /// 반환값: 저장된 [AssetEntity].
  /// 권한이 없거나 저장 실패 시 예외를 던진다.
  static Future<AssetEntity> saveVideoToGallery(
    String filePath, {
    String albumName = 'TravelMap ArchiVer',
  }) async {
    await _ensurePermission();

    final asset = await PhotoManager.editor.saveVideo(
      File(filePath),
      title: _titleFromPath(filePath),
    );

    await _moveToAlbum(asset, albumName);
    return asset;
  }

  /// 이미지 파일(썸네일 등)을 갤러리에 저장한다.
  static Future<AssetEntity> saveImageToGallery(
    String filePath, {
    String albumName = 'TravelMap ArchiVer',
  }) async {
    await _ensurePermission();

    final asset = await PhotoManager.editor.saveImageWithPath(
      filePath,
      title: _titleFromPath(filePath),
    );

    await _moveToAlbum(asset, albumName);
    return asset;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  static Future<void> _ensurePermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    if (!state.isAuth) {
      throw Exception('갤러리 권한이 없습니다. 설정에서 허용해 주세요.');
    }
  }

  static Future<void> _moveToAlbum(AssetEntity asset, String albumName) async {
    // iOS/macOS 전용 앨범 분류 (Android는 MediaStore 폴더로 자동 분류됨)
    if (!Platform.isIOS && !Platform.isMacOS) return;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
    AssetPathEntity? target;
    for (final album in albums) {
      if (album.name == albumName) {
        target = album;
        break;
      }
    }

    target ??= await PhotoManager.editor.darwin.createAlbum(albumName);
    if (target != null) {
      await PhotoManager.editor.copyAssetToPath(
        asset: asset,
        pathEntity: target,
      );
    }
  }

  static String _titleFromPath(String path) {
    final name = path.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(0, dotIndex) : name;
  }
}
