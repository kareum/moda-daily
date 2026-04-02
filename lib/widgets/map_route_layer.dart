import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 여행 경로 폴리라인 레이어.
/// [routePoints]를 capturedAt 순서대로 선으로 연결한다.
/// 포인트가 2개 미만이면 아무것도 렌더링하지 않는다.
class MapRouteLayer extends StatelessWidget {
  final List<LatLng> routePoints;

  const MapRouteLayer({super.key, required this.routePoints});

  @override
  Widget build(BuildContext context) {
    if (routePoints.length < 2) return const SizedBox.shrink();

    final color = Theme.of(context).colorScheme.primary;

    return PolylineLayer(
      polylines: [
        // 외곽선 (두꺼운 흰 선으로 가독성 확보)
        Polyline(
          points: routePoints,
          color: Colors.white.withAlpha(180),
          strokeWidth: 5.0,
        ),
        // 실제 경로선
        Polyline(
          points: routePoints,
          color: color,
          strokeWidth: 3.0,
        ),
      ],
    );
  }
}
