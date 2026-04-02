/// Geocoding API 통신 서비스 (F-4에서 구현).
/// GPS 좌표 → 실제 장소명 변환을 담당한다.
class MapService {
  MapService._();

  // TODO(F-4): Google Maps Geocoding API 키를 환경 변수로 주입
  // static const _apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  /// 위경도 → 장소명 변환 (예: '프랑스 파리 에펠탑')
  /// MVP 이후 구현 예정 — 현재는 좌표 문자열 반환.
  static Future<String> reverseGeocode(double lat, double lng) async {
    // TODO(F-4): HTTP 호출로 교체
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }
}
