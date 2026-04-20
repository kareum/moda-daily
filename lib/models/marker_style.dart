import 'package:flutter/material.dart';

enum MarkerStyleType {
  thumbnail,  // 사진 썸네일 (기본)
  icon,       // 아이콘
  userPhoto,  // 사용자 지정 이미지 (추후 확장)
}

/// 지도 마커의 시각적 스타일을 정의한다.
///
/// [MarkerStyleType.thumbnail] → 사진 썸네일 표시 (기본값)
/// [MarkerStyleType.icon]      → 아이콘 + 색상으로 표시
/// [MarkerStyleType.userPhoto] → 사용자 지정 이미지 (추후)
class MarkerStyle {
  final MarkerStyleType type;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String? userPhotoPath; // userPhoto 타입일 때 사용

  const MarkerStyle({
    this.type = MarkerStyleType.thumbnail,
    this.icon = Icons.sentiment_satisfied_alt_outlined,
    this.iconColor = const Color(0xFF00897B),
    this.backgroundColor = const Color(0xFFE0F2F1),
    this.userPhotoPath,
  });

  /// 기본 썸네일 스타일
  static const MarkerStyle thumbnail = MarkerStyle(
    type: MarkerStyleType.thumbnail,
  );

  /// 스마일 아이콘 스타일
  static const MarkerStyle smile = MarkerStyle(
    type: MarkerStyleType.icon,
    icon: Icons.sentiment_satisfied_alt_outlined,
    iconColor: Color(0xFF00897B),
    backgroundColor: Color(0xFFE0F2F1),
  );

  /// 핀 아이콘 스타일
  static const MarkerStyle pin = MarkerStyle(
    type: MarkerStyleType.icon,
    icon: Icons.location_on,
    iconColor: Color(0xFFE53935),
    backgroundColor: Color(0xFFFFEBEE),
  );

  /// 카메라 아이콘 스타일
  static const MarkerStyle camera = MarkerStyle(
    type: MarkerStyleType.icon,
    icon: Icons.photo_camera_outlined,
    iconColor: Color(0xFF1565C0),
    backgroundColor: Color(0xFFE3F2FD),
  );

  /// 스타 아이콘 스타일
  static const MarkerStyle star = MarkerStyle(
    type: MarkerStyleType.icon,
    icon: Icons.star_outline,
    iconColor: Color(0xFFF57F17),
    backgroundColor: Color(0xFFFFFDE7),
  );

  /// 사용자 정의 아이콘으로 생성
  factory MarkerStyle.withIcon({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) =>
      MarkerStyle(
        type: MarkerStyleType.icon,
        icon: icon,
        iconColor: iconColor,
        backgroundColor: backgroundColor,
      );

  MarkerStyle copyWith({
    MarkerStyleType? type,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    String? userPhotoPath,
  }) =>
      MarkerStyle(
        type: type ?? this.type,
        icon: icon ?? this.icon,
        iconColor: iconColor ?? this.iconColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        userPhotoPath: userPhotoPath ?? this.userPhotoPath,
      );
}

/// 프리셋 마커 스타일 목록 (설정 UI에서 사용)
const List<({String label, MarkerStyle style})> kMarkerStylePresets = [
  (label: '사진', style: MarkerStyle.thumbnail),
  (label: '스마일', style: MarkerStyle.smile),
  (label: '핀', style: MarkerStyle.pin),
  (label: '카메라', style: MarkerStyle.camera),
  (label: '별', style: MarkerStyle.star),
];
