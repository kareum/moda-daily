class PhotoMetadata {
  final String assetId;
  final String? fileName;
  final DateTime capturedAt;
  final double latitude;
  final double longitude;
  final double? altitude; // 해발고도 (m)
  final String? cameraMake;
  final String? cameraModel;
  final double? imageDirection; // 촬영 방향 0~360°

  const PhotoMetadata({
    required this.assetId,
    this.fileName,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.cameraMake,
    this.cameraModel,
    this.imageDirection,
  });

  String get cameraInfo {
    final make = cameraMake?.trim();
    final model = cameraModel?.trim();
    if (make != null && model != null) {
      if (model.toLowerCase().startsWith(make.toLowerCase())) return model;
      return '$make $model';
    }
    return model ?? make ?? '알 수 없음';
  }

  String get coordinateText =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get altitudeText =>
      altitude != null ? '${altitude!.toStringAsFixed(1)}m' : '-';

  String get directionText {
    if (imageDirection == null) return '-';
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((imageDirection! + 22.5) / 45).floor() % 8;
    return '${imageDirection!.toStringAsFixed(1)}° ${labels[idx]}';
  }
}
