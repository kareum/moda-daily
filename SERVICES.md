# Services 레이어 명세

외부 환경(디바이스 갤러리, OS API, 외부 HTTP API)과 통신하는 유일한 창구.  
**상태를 보유하지 않으며**, Controller가 결과를 받아 상태를 관리한다.

---

## photo_service.dart

**책임**: 디바이스 사진첩 접근 + EXIF 메타데이터 추출.  
`photo_manager` (갤러리 I/O) + `exif` (바이트 파싱)를 이 파일 안에서만 사용한다.

### 공개 API

```dart
class PhotoService {
  PhotoService._(); // 인스턴스화 불가 — 모든 메서드가 static
}
```

---

#### `requestPermission()`

```dart
static Future<PermissionState> requestPermission()
```

| 항목 | 내용 |
|------|------|
| 반환 | `PermissionState` (authorized / limited / denied / restricted) |
| 동작 | `PhotoManager.requestPermissionExtend()` 호출. OS 권한 다이얼로그 표시. |
| 호출처 | `PhotoSelectionController.initialize()` |

**Android 권한 매핑**:

| Android 버전 | 필요 권한 |
|-------------|---------|
| ~12 (API 32) | `READ_EXTERNAL_STORAGE` |
| 13+ (API 33) | `READ_MEDIA_IMAGES` |
| 10+ (API 29) | `ACCESS_MEDIA_LOCATION` (GPS EXIF 접근) |

---

#### `openSettings()`

```dart
static Future<void> openSettings()
```

권한 거부 시 사용자를 OS 설정 앱으로 보낸다. `PhotoManager.openSetting()` 래핑.

---

#### `getAlbums()`

```dart
static Future<List<AssetPathEntity>> getAlbums()
```

| 항목 | 내용 |
|------|------|
| 반환 | 이미지 전용 앨범 목록. 최근 생성순 정렬. |
| 필터 | `RequestType.image` (동영상 제외), `ignoreSize: true` (크기 제한 없음) |
| 정렬 | `OrderOptionType.createDate` 내림차순 |

---

#### `getPhotos(album, {page, pageSize})`

```dart
static Future<List<AssetEntity>> getPhotos(
  AssetPathEntity album, {
  int page = 0,
  int pageSize = 80,
})
```

| 파라미터 | 설명 |
|---------|------|
| `album` | 대상 앨범 |
| `page` | 0-based 페이지 인덱스 |
| `pageSize` | 페이지당 사진 수 (기본 80) |

`pageSize`만큼 반환되면 다음 페이지가 있다고 판단 (`hasMore = true`).

---

#### `getPhotosByDateRange(album, range, {page, pageSize})`

```dart
static Future<List<AssetEntity>> getPhotosByDateRange(
  AssetPathEntity album,
  DateTimeRange range, {
  int page = 0,
  int pageSize = 80,
})
```

`FilterOptionGroup`의 `DateTimeCond`를 적용하여 날짜 범위 필터링.  
종료일은 `range.end + 1일`로 설정하여 당일 사진을 포함한다.

---

#### `extractMetadata(assets, {onProgress})`

```dart
static Future<ExtractionResult> extractMetadata(
  List<AssetEntity> assets, {
  void Function(int current, int total)? onProgress,
})
```

| 항목 | 내용 |
|------|------|
| 반환 | `ExtractionResult` (성공 목록 + 건너뜀 수) |
| 정렬 | 결과를 `capturedAt` 오름차순 정렬 |
| onProgress | `(current, total)` — Controller가 UI 업데이트에 활용 |

**내부 처리 흐름** (`_extractSingle` 호출):

```
asset.originFile
  → file.readAsBytes()
  → readExifFromBytes(bytes)
  → GPS 파싱 (EXIF 우선, photo_manager latlng fallback)
  → DateTime 파싱 (DateTimeOriginal 우선, createDateTime fallback)
  → GPS 없으면 null 반환 → skippedCount++
```

---

### 비공개(private) EXIF 파싱 헬퍼

| 메서드 | 역할 |
|--------|------|
| `_extractSingle(asset)` | 단일 에셋 → `PhotoMetadata?` 변환 |
| `_parseGpsCoord(tag, ref)` | `IfdRatios` DMS → 10진수 위경도 |
| `_parseAltitude(exif)` | 고도 파싱. `AltitudeRef=1`이면 음수(해수면 아래) |
| `_parseDirection(exif)` | 촬영 방향 파싱 (0~360°) |
| `_parseDateTime(exif)` | `'2023:06:15 14:30:00'` 형식 파싱 |
| `_ratio(Ratio)` | `numerator/denominator` → `double?` |

**EXIF 키 참조표**:

| EXIF 키 | 타입 | 설명 |
|---------|------|------|
| `GPS GPSLatitude` | `IfdRatios` | 위도 DMS |
| `GPS GPSLatitudeRef` | `IfdAscii` | `'N'` 또는 `'S'` |
| `GPS GPSLongitude` | `IfdRatios` | 경도 DMS |
| `GPS GPSLongitudeRef` | `IfdAscii` | `'E'` 또는 `'W'` |
| `GPS GPSAltitude` | `IfdRatios` | 고도 (분수) |
| `GPS GPSAltitudeRef` | `IfdBytes` | `0`=해수면 위, `1`=아래 |
| `GPS GPSImgDirection` | `IfdRatios` | 촬영 방향 각도 |
| `EXIF DateTimeOriginal` | `IfdAscii` | 셔터 눌린 시각 |
| `Image DateTime` | `IfdAscii` | 파일 수정 시각 (fallback) |
| `Image Make` | `IfdAscii` | 카메라 제조사 |
| `Image Model` | `IfdAscii` | 카메라 모델명 |

---

### 에러 처리 전략

- `_extractSingle`은 모든 예외를 `try/catch`로 잡아 `null` 반환 → `skippedCount` 증가.
- 서비스 수준에서 예외가 전파되지 않으므로 Controller는 전체 루프 실패 없이 처리 가능.
- `originFile`이 `null`인 경우(삭제된 파일, 접근 불가)도 건너뜀 처리.

---

---

## map_service.dart

**책임**: GPS 좌표 → 실제 장소명 변환 (Reverse Geocoding).  
**현재 상태**: F-4 단계 구현 예정. 인터페이스만 정의된 stub.

### 공개 API

```dart
static Future<String> reverseGeocode(double lat, double lng)
```

| 항목 | 내용 |
|------|------|
| 반환 | 장소명 문자열 (예: `"프랑스 파리 에펠탑"`) |
| 현재 동작 | 좌표 문자열 반환 (stub) |
| 예정 구현 | Google Maps Geocoding API HTTP 호출 |

### F-4 구현 계획

```
GET https://maps.googleapis.com/maps/api/geocode/json
  ?latlng={lat},{lng}
  &language=ko
  &key={API_KEY}

응답 우선순위:
  1. point_of_interest (랜드마크)
  2. establishment (상호명)
  3. locality (시/군/구)
  4. country (국가)
```

**보안**: API 키는 `--dart-define=GOOGLE_MAPS_API_KEY=xxx` 로 주입. 소스코드에 하드코딩 금지.

---

---

## video_service.dart

**책임**: 지도 애니메이션 + 사진 슬라이드쇼 → MP4 파일 합성.  
**현재 상태**: F-3 단계 구현 예정. 인터페이스만 정의된 stub.

### 공개 API

```dart
static Future<String> exportVideo({
  required List<String> assetIds,
  int durationSeconds = 30,
  ProgressCallback? onProgress,
})
```

| 항목 | 내용 |
|------|------|
| 반환 | 저장된 MP4 파일 경로 |
| 현재 동작 | `UnimplementedError` throw |
| 예정 구현 | `ffmpeg_kit_flutter` 연동 |

### F-3 구현 계획

```
출력 규격: 9:16 세로, 1080×1920, 15~30초, H.264

FFmpeg 파이프라인:
  1. 사진들을 프레임으로 변환 (이미지 슬라이드)
  2. 지도 스크린샷 시퀀스 생성 (MapController 활용)
  3. FFmpeg concat filter로 합성
  4. 자막 스트림 오버레이 (ASS/SRT)
  5. 로컬 저장소 출력

예시 FFmpeg 커맨드:
  ffmpeg -framerate 30 -i frame_%04d.png
         -i slide_%04d.jpg
         -filter_complex "[0][1]overlay=..."
         -c:v libx264 -crf 23 output.mp4
```
