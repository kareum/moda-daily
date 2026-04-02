# Controllers 레이어 명세

`ChangeNotifier`를 상속하여 UI 상태를 관리한다.  
Screen은 `ListenableBuilder`로 구독하며, 직접 Service를 호출하지 않는다.

---

## PhotoSelectionController

**파일**: `lib/controllers/photo_selection_controller.dart`  
**책임**: 사진 선택 화면의 모든 상태 — 권한, 앨범 목록, 사진 페이지네이션, 날짜 필터, 멀티셀렉트.

---

### 상태 구조

```dart
// 권한
PermissionStatus _permissionStatus    // initial | granted | limited | denied

// 앨범
List<AssetPathEntity> _albums         // 앨범 목록
AssetPathEntity? _currentAlbum        // 현재 선택된 앨범

// 사진 (페이지네이션)
List<AssetEntity> _assets             // 현재 로드된 사진 목록
int _currentPage                      // 현재 페이지 (0-based)
bool _hasMorePhotos                   // 다음 페이지 존재 여부

// 선택
Set<String> _selectedIds              // 선택된 assetId Set

// 필터
DateTimeRange? _dateFilter            // 날짜 필터 (null = 전체)

// 로딩 & 에러
bool _isLoadingAlbums
bool _isLoadingPhotos
String? _errorMessage
```

---

### 공개 Getters

| Getter | 타입 | 설명 |
|--------|------|------|
| `permissionStatus` | `PermissionStatus` | 현재 권한 상태 |
| `albums` | `List<AssetPathEntity>` | 읽기 전용 앨범 목록 |
| `currentAlbum` | `AssetPathEntity?` | 현재 앨범 |
| `assets` | `List<AssetEntity>` | 읽기 전용 사진 목록 |
| `selectedIds` | `Set<String>` | 읽기 전용 선택 ID Set |
| `dateFilter` | `DateTimeRange?` | 현재 날짜 필터 |
| `isLoadingAlbums` | `bool` | 앨범 로딩 중 여부 |
| `isLoadingPhotos` | `bool` | 사진 로딩 중 여부 |
| `hasMorePhotos` | `bool` | 추가 로드 가능 여부 |
| `errorMessage` | `String?` | 에러 메시지 |
| `selectedCount` | `int` | 선택된 사진 수 |
| `selectedAssets` | `List<AssetEntity>` | 선택된 에셋 목록 (추출 전달용) |

> `assets`와 `selectedIds`는 `List.unmodifiable` / `Set.unmodifiable`로 반환하여 외부 변형을 차단한다.

---

### 공개 메서드

#### `initialize()`

```dart
Future<void> initialize()
```

권한 요청 → 허용 시 앨범·사진 로드 순으로 초기화.  
`PhotoSelectionScreen.initState()`에서 1회 호출.

```
requestPermission()
  → granted/limited: _loadAlbums()
    → _albums 설정, _currentAlbum = albums.first
    → _loadPhotos(reset: true)
  → denied: permissionStatus = denied, notifyListeners()
```

---

#### `openAppSettings()`

```dart
Future<void> openAppSettings()
```

`PhotoService.openSettings()` 위임. Screen이 서비스를 직접 참조하지 않도록 위임 제공.

---

#### `selectAlbum(album)`

```dart
Future<void> selectAlbum(AssetPathEntity album)
```

동일 앨범 재선택은 no-op (`album.id == _currentAlbum?.id` 가드).  
`_dateFilter` 초기화, `clearSelection()` 후 사진 재로드.

---

#### `applyDateFilter(range)`

```dart
Future<void> applyDateFilter(DateTimeRange? range)
```

`null` 전달 시 필터 해제(전체).  
`clearSelection()` 후 사진 재로드.

---

#### `loadMorePhotos()`

```dart
Future<void> loadMorePhotos()
```

**가드 조건**: `!_hasMorePhotos || _isLoadingPhotos`이면 early return.  
`PhotoGrid`가 스크롤 하단 임계값(maxScrollExtent - 200px) 도달 시 호출.

---

#### `toggleSelection(assetId)`

```dart
void toggleSelection(String assetId)
```

`_selectedIds`에 포함 여부로 추가/제거 토글. `notifyListeners()` 호출.

---

#### `selectAll()` / `clearSelection()`

```dart
void selectAll()     // _assets 전체 ID를 _selectedIds에 추가
void clearSelection() // _selectedIds 전체 제거
```

---

### 내부 메서드

#### `_loadAlbums()` (private)

로딩 플래그 → `PhotoService.getAlbums()` → `_albums`, `_currentAlbum` 설정 → `_loadPhotos(reset: true)`.  
실패 시 `_errorMessage` 설정.

#### `_loadPhotos({reset})` (private)

`reset: true`이면 `_currentPage = 0`, `_assets = []` 초기화.  
`_dateFilter` 유무에 따라 `getPhotos` 또는 `getPhotosByDateRange` 분기.  
반환 개수가 `_pageSize`(80) 미만이면 `_hasMorePhotos = false`.

---

### PermissionStatus enum

```dart
enum PermissionStatus {
  initial,   // 권한 요청 전 (앱 첫 진입)
  granted,   // 전체 허용
  limited,   // 제한적 허용 (iOS 14+)
  denied,    // 거부
}
```

---

---

## ExtractionController

**파일**: `lib/controllers/extraction_controller.dart`  
**책임**: 메타데이터 추출 작업의 진행 상황과 결과 상태 관리.

---

### 상태 구조

```dart
bool _isExtracting        // 추출 진행 중
int _progress             // 현재까지 처리한 사진 수
int _total                // 전체 처리 대상 수
ExtractionResult? _result // 추출 완료 결과
String? _errorMessage     // 오류 메시지
```

---

### 공개 Getters

| Getter | 타입 | 설명 |
|--------|------|------|
| `isExtracting` | `bool` | 추출 진행 중 여부 |
| `progress` | `int` | 현재 처리 수 |
| `total` | `int` | 전체 처리 대상 수 |
| `result` | `ExtractionResult?` | 완료된 결과 (완료 전 null) |
| `errorMessage` | `String?` | 오류 메시지 |
| `progressRatio` | `double` | `0.0~1.0` (LinearProgressIndicator에 직접 전달) |
| `progressText` | `String` | `"3 / 27"` 형식 텍스트 |

---

### 공개 메서드

#### `extract(assets)`

```dart
Future<void> extract(List<AssetEntity> assets)
```

**가드 조건**: `_isExtracting || assets.isEmpty`이면 early return.

```
_isExtracting = true, _progress = 0, _total = N
→ PhotoService.extractMetadata(assets, onProgress: callback)
    → onProgress 콜백마다 _progress 갱신, notifyListeners()
    → ExtractionProgressDialog가 실시간 업데이트됨
→ _result 저장
→ _isExtracting = false, notifyListeners()
```

`onProgress` 콜백은 Service 내부 루프에서 사진 1장 처리 완료마다 호출된다.  
Controller → Dialog 간 통신을 Service에 의존하지 않고 처리하는 핵심 연결점.

---

#### `reset()`

```dart
void reset()
```

결과 화면에서 뒤로가기 시 `PhotoSelectionScreen`이 `.then((_) => reset())` 호출.  
다음 추출을 위해 모든 상태를 초기값으로 복원.

---

### 상태 전이 다이어그램

```
initial
  │  extract() 호출
  ▼
extracting (isExtracting=true, progress 증가)
  │  완료
  ├──► completed (result != null)
  │  오류
  └──► error (errorMessage != null)

completed/error
  │  reset() 호출
  ▼
initial
```

---

### Screen과의 연동 패턴

```dart
// PhotoSelectionScreen — 다이얼로그를 ListenableBuilder로 감쌈
showDialog(
  builder: (_) => ListenableBuilder(
    listenable: _extractionCtrl,
    builder: (_, __) => ExtractionProgressDialog(
      // Controller의 값만 꺼내서 순수 위젯에 주입
      progress: _extractionCtrl.progress,
      total: _extractionCtrl.total,
      progressRatio: _extractionCtrl.progressRatio,
    ),
  ),
);
```

`ExtractionProgressDialog`는 Controller를 전혀 모르고, `int`/`double` 값만 받는다.  
이 패턴 덕분에 위젯 테스트 시 Controller 없이 더미 값으로 렌더링 검증 가능.
