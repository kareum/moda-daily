# Screens & Widgets 레이어 명세

---

## 설계 원칙

| 레이어 | 원칙 |
|--------|------|
| **Screens** | Controller를 `ListenableBuilder`로 구독만 함. 라우팅·레이아웃·이벤트 바인딩 담당. 직접 Service 호출 없음. |
| **Widgets** | Constructor로만 데이터를 받는 순수 UI 컴포넌트. Controller/Service에 의존하지 않아 재사용·단독 테스트 가능. |

---

---

# Screens

---

## HomeScreen

**파일**: `lib/screens/home_screen.dart`  
**역할**: 앱 진입 화면. 앱 소개 + `PhotoSelectionScreen` 라우팅.

### 의존성

없음. Controller나 Service를 직접 참조하지 않는다.

### 구성 요소

| 요소 | 설명 |
|------|------|
| 앱 로고 + 타이틀 | `map_outlined` 아이콘 + "TravelMap / ArchiVer" |
| 기능 소개 칩 | `_FeatureChip` × 4 (GPS 추출, 경로 시각화, 영상 생성, AI 자막) |
| 시작 버튼 | `FilledButton` → `PhotoSelectionScreen` push |

### 라우팅

```dart
Navigator.push(context,
  MaterialPageRoute(builder: (_) => const PhotoSelectionScreen())
);
```

---

## PhotoSelectionScreen

**파일**: `lib/screens/photo_selection_screen.dart`  
**역할**: 사진 선택 화면. `PhotoSelectionController`와 `ExtractionController`를 구독.

### 의존성

```dart
late final PhotoSelectionController _selectionCtrl;
late final ExtractionController _extractionCtrl;
```

두 Controller는 `initState`에서 생성, `dispose`에서 해제.

### 생명주기

```
initState
  └─ _selectionCtrl.initialize()
       └─ 권한 요청 → 앨범 로드 → 첫 페이지 로드

dispose
  └─ _selectionCtrl.dispose()
  └─ _extractionCtrl.dispose()
```

### 화면 구성 (Scaffold)

```
AppBar
  ├── title: "사진 선택" + 현재 앨범명 (2줄)
  ├── action: "전체 선택/해제" TextButton
  └── action: 앨범 선택 IconButton → AlbumSelectorSheet.show()

Body (Column)
  ├── DateFilterBar (전체/이번주/이번달/직접선택)
  ├── Divider
  └── Expanded
        ├── isLoadingAlbums → CircularProgressIndicator
        └── PhotoGrid (assets, selectedIds, isLoading, hasMore, ...)

BottomNavigationBar
  └── SelectionBottomBar (selectedCount, onExtract, onClear)
```

### 추출 플로우 (`_onExtractTapped`)

```dart
Future<void> _onExtractTapped() async {
  // 1. 다이얼로그 표시 (ListenableBuilder로 ExtractionController 구독)
  showDialog(builder: (_) =>
    ListenableBuilder(
      listenable: _extractionCtrl,
      builder: (_, __) => ExtractionProgressDialog(
        progress: _extractionCtrl.progress,
        total: _extractionCtrl.total,
        progressRatio: _extractionCtrl.progressRatio,
      ),
    )
  );

  // 2. 추출 실행 (비동기 완료 대기)
  await _extractionCtrl.extract(_selectionCtrl.selectedAssets);

  // 3. 다이얼로그 닫기
  Navigator.pop(context);

  // 4. 결과 화면 push, 뒤로오면 Controller reset
  Navigator.push(context,
    MaterialPageRoute(builder: (_) => MetadataResultScreen(
      result: _extractionCtrl.result!,
      assetMap: {for (final a in _selectionCtrl.selectedAssets) a.id: a},
    )),
  ).then((_) => _extractionCtrl.reset());
}
```

### 권한 거부 분기

`permissionStatus == PermissionStatus.denied`일 때 Scaffold 대신 `_PermissionDeniedScreen` 반환.

---

## MetadataResultScreen

**파일**: `lib/screens/metadata_result_screen.dart`  
**역할**: 추출된 메타데이터 결과 표시. Controller 의존 없음 — 완료된 데이터를 constructor로 받는다.

### 생성자

```dart
const MetadataResultScreen({
  required ExtractionResult result,
  required Map<String, AssetEntity> assetMap, // 썸네일 표시용
})
```

### 화면 구성 (CustomScrollView)

```
AppBar
  ├── title: "추출 결과"
  └── action: 여행 날짜 범위 텍스트 (yy.MM.dd ~ yy.MM.dd)

SliverToBoxAdapter
  └── MetadataSummaryCard (총 선택 / GPS 있음 / 제외)

SliverToBoxAdapter
  └── "시간순 정렬 · N장" 헤더

SliverList.builder
  └── MetadataListItem × successCount

FloatingActionButton (extended)
  └── "지도에서 보기" — F-2에서 활성화 예정 (현재 onPressed: null)
```

### `_travelDateRange()` 헬퍼

`result.metadata`의 첫/마지막 `capturedAt`으로 여행 날짜 범위 계산.  
같은 날이면 단일 날짜 표시, 다른 날이면 `시작 ~ 종료` 표시.

### GPS 없음 분기

`result.hasData == false`이면 `_NoGpsBody` (안내 메시지) 표시.

---

---

# Widgets

모든 위젯은 **constructor로만 데이터를 받는다**.  
Controller나 Service를 직접 import하지 않는다.

---

## PhotoGrid

**파일**: `lib/widgets/photo_grid.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `assets` | `List<AssetEntity>` | 표시할 사진 목록 |
| `selectedIds` | `Set<String>` | 선택된 ID Set |
| `isLoading` | `bool` | 로딩 스피너 표시 여부 |
| `hasMore` | `bool` | 하단 로딩 셀 표시 여부 |
| `onToggle` | `void Function(String)` | 선택 토글 콜백 |
| `onLoadMore` | `VoidCallback` | 무한스크롤 트리거 콜백 |

### 페이지네이션 구현

`ScrollController`를 내부에 보유하며 `maxScrollExtent - 200px` 임계값 초과 시 `onLoadMore` 호출.  
`hasMore == true`이면 마지막 셀에 `CircularProgressIndicator` 표시.

```dart
// itemCount 계산
itemCount: assets.length + (hasMore ? 1 : 0)

// 마지막 셀
if (index >= assets.length) return LoadingCell();
```

---

## PhotoGridItem

**파일**: `lib/widgets/photo_grid_item.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `asset` | `AssetEntity` | 사진 에셋 |
| `isSelected` | `bool` | 선택 상태 |
| `onTap` | `VoidCallback` | 탭 콜백 |

### 애니메이션

- 선택 오버레이: `AnimatedContainer` (150ms) — primary 색상 반투명
- 체크 뱃지: `AnimatedSwitcher` (150ms) — `_CheckBadge` ↔ `_UncheckBadge`

썸네일은 `AssetEntityImage` (photo_manager 제공)로 200×200 최적화 로드.

---

## AlbumSelectorSheet

**파일**: `lib/widgets/album_selector_sheet.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `albums` | `List<AssetPathEntity>` | 앨범 목록 |
| `currentAlbum` | `AssetPathEntity?` | 현재 선택 앨범 |
| `onSelect` | `void Function(AssetPathEntity)` | 앨범 선택 콜백 |

### 정적 헬퍼

```dart
static Future<void> show(BuildContext context, {
  required List<AssetPathEntity> albums,
  required AssetPathEntity? currentAlbum,
  required void Function(AssetPathEntity) onSelect,
})
```

`showModalBottomSheet`를 래핑. Screen에서 호출 시 인자를 명시적으로 전달하여 Widget 내부가 외부 상태를 몰라도 되게 설계.

---

## DateFilterBar

**파일**: `lib/widgets/date_filter_bar.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `current` | `DateTimeRange?` | 현재 필터 (null=전체) |
| `onChange` | `void Function(DateTimeRange?)` | 변경 콜백 |

### 필터 칩 종류

| 칩 | 동작 |
|----|------|
| 전체 | `onChange(null)` |
| 이번 주 | `onChange(thisWeekRange())` |
| 이번 달 | `onChange(thisMonthRange())` |
| 직접 선택 | `showDateRangePicker()` → `onChange(picked)` |

`_FilterChip`은 `isSelected` 상태에 따라 배경색/텍스트색을 `AnimatedContainer`로 전환.

---

## SelectionBottomBar

**파일**: `lib/widgets/selection_bottom_bar.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `selectedCount` | `int` | 선택된 사진 수 |
| `onExtract` | `VoidCallback?` | 추출 버튼 콜백 (null=비활성) |
| `onClear` | `VoidCallback` | 선택 해제 콜백 |

`onExtract == null`이면 `FilledButton`이 자동으로 비활성(disabled) 스타일 적용.

---

## ExtractionProgressDialog

**파일**: `lib/widgets/extraction_progress_dialog.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `progress` | `int` | 현재 처리 수 |
| `total` | `int` | 전체 수 |
| `progressRatio` | `double` | `0.0~1.0` (LinearProgressIndicator 값) |

`PopScope(canPop: false)`로 추출 중 뒤로가기를 차단한다.  
Controller를 모른다. Screen의 `ListenableBuilder`가 값을 꺼내 주입.

---

## MetadataSummaryCard

**파일**: `lib/widgets/metadata_summary_card.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `totalSelected` | `int` | 전체 선택 수 |
| `withGps` | `int` | GPS 있어 추출 성공한 수 |
| `skipped` | `int` | GPS 없어 제외된 수 |

3개의 `_StatCell`을 가로로 나열. 각 셀에 아이콘 + 숫자 + 레이블.

---

## MetadataListItem

**파일**: `lib/widgets/metadata_list_item.dart`

### Props

| Prop | 타입 | 설명 |
|------|------|------|
| `metadata` | `PhotoMetadata` | 표시할 메타데이터 |
| `asset` | `AssetEntity?` | 썸네일 표시용 (null이면 placeholder) |

### 표시 정보 우선순위

```
필수 표시:
  - 파일명 (없으면 assetId)
  - 촬영 일시 (yyyy.MM.dd HH:mm:ss)
  - GPS 좌표 (소수점 6자리)

있을 때만 표시:
  - 고도 (altitude != null)
  - 카메라 모델 (cameraModel || cameraMake != null)
  - 촬영 방향 (imageDirection != null)
```

각 정보 행은 `_InfoRow(icon, text, color?)` 컴포넌트로 구성.

---

## _FeatureChip (HomeScreen 전용 private 위젯)

```dart
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
}
```

`HomeScreen` 내부에 private 클래스로 정의. 앱 소개용으로만 사용되므로 별도 파일로 분리하지 않음.

---

## _PermissionDeniedScreen (PhotoSelectionScreen 전용 private 위젯)

```dart
class _PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;
}
```

권한 거부 상태에서만 표시. `PhotoSelectionScreen` 파일 내 private 위젯으로 관리.  
`onOpenSettings` 콜백만 받으므로 Controller와 완전히 분리.
