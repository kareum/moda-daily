# 시퀀스 다이어그램

주요 유저 시나리오별 컴포넌트 간 상호작용을 정의한다.

---

## 1. 앱 시작 및 권한 요청

앱 최초 실행 시 사진첩 접근 권한을 요청하고, 결과에 따라 다른 화면으로 분기한다.

```mermaid
sequenceDiagram
    actor User
    participant Home as HomeScreen
    participant Sel as PhotoSelectionScreen
    participant Ctrl as PhotoSelectionController
    participant Svc as PhotoService
    participant OS as OS (갤러리)

    User->>Home: 앱 실행
    Home-->>User: 홈 화면 표시

    User->>Home: "여행 사진 선택하기" 탭
    Home->>Sel: Navigator.push()
    Sel->>Ctrl: initialize()
    Ctrl->>Svc: requestPermission()
    Svc->>OS: PhotoManager.requestPermissionExtend()
    OS-->>User: 권한 다이얼로그 표시

    alt 권한 허용
        User->>OS: 허용
        OS-->>Svc: PermissionState.authorized
        Svc-->>Ctrl: PermissionState.authorized
        Ctrl->>Ctrl: permissionStatus = granted
        Ctrl->>Svc: getAlbums()
        Svc->>OS: PhotoManager.getAssetPathList()
        OS-->>Svc: List<AssetPathEntity>
        Svc-->>Ctrl: List<AssetPathEntity>
        Ctrl->>Ctrl: _albums, _currentAlbum 갱신
        Ctrl->>Ctrl: notifyListeners()
        Ctrl->>Svc: getPhotos(firstAlbum, page: 0)
        Svc->>OS: album.getAssetListPaged()
        OS-->>Svc: List<AssetEntity>
        Svc-->>Ctrl: List<AssetEntity>
        Ctrl->>Ctrl: _assets 갱신, notifyListeners()
        Sel-->>User: 사진 그리드 표시

    else 권한 거부
        User->>OS: 거부
        OS-->>Svc: PermissionState.denied
        Svc-->>Ctrl: PermissionState.denied
        Ctrl->>Ctrl: permissionStatus = denied, notifyListeners()
        Sel-->>User: 권한 거부 안내 화면 표시
    end
```

---

## 2. 앨범 변경

```mermaid
sequenceDiagram
    actor User
    participant Sel as PhotoSelectionScreen
    participant Sheet as AlbumSelectorSheet
    participant Ctrl as PhotoSelectionController
    participant Svc as PhotoService
    participant OS as OS (갤러리)

    User->>Sel: 앨범 아이콘 탭
    Sel->>Sheet: AlbumSelectorSheet.show() (바텀 시트)
    Sheet-->>User: 앨범 목록 표시

    User->>Sheet: 특정 앨범 선택
    Sheet->>Ctrl: selectAlbum(album)
    Sheet->>Sheet: Navigator.pop() (시트 닫기)

    Ctrl->>Ctrl: _currentAlbum 갱신, clearSelection()
    Ctrl->>Ctrl: _assets = [], _currentPage = 0
    Ctrl->>Svc: getPhotos(newAlbum, page: 0)
    Svc->>OS: album.getAssetListPaged()
    OS-->>Svc: List<AssetEntity>
    Svc-->>Ctrl: List<AssetEntity>
    Ctrl->>Ctrl: _assets 갱신, notifyListeners()
    Sel-->>User: 새 앨범 사진 그리드 표시
```

---

## 3. 날짜 범위 필터

```mermaid
sequenceDiagram
    actor User
    participant Bar as DateFilterBar
    participant Sel as PhotoSelectionScreen
    participant Ctrl as PhotoSelectionController
    participant Svc as PhotoService
    participant OS as OS (갤러리)

    User->>Bar: "직접 선택" 칩 탭
    Bar->>Bar: showDateRangePicker()
    Bar-->>User: 날짜 범위 선택 UI

    User->>Bar: 날짜 범위 확인
    Bar->>Ctrl: applyDateFilter(DateTimeRange)

    Ctrl->>Ctrl: _dateFilter 갱신, clearSelection()
    Ctrl->>Ctrl: _assets = [], _currentPage = 0
    Ctrl->>Svc: getPhotosByDateRange(album, range, page: 0)

    Note over Svc,OS: FilterOptionGroup에 DateTimeCond 적용하여<br/>새 AssetPathList 요청
    Svc->>OS: PhotoManager.getAssetPathList(filterOption)
    OS-->>Svc: List<AssetPathEntity> (필터 적용됨)
    Svc->>OS: albums.first.getAssetListPaged()
    OS-->>Svc: List<AssetEntity>
    Svc-->>Ctrl: List<AssetEntity>

    Ctrl->>Ctrl: _assets 갱신, notifyListeners()
    Sel-->>User: 필터된 사진 그리드 표시
```

---

## 4. 사진 선택 (멀티셀렉트)

```mermaid
sequenceDiagram
    actor User
    participant Grid as PhotoGrid
    participant Item as PhotoGridItem
    participant Ctrl as PhotoSelectionController
    participant Bar as SelectionBottomBar

    User->>Item: 사진 탭
    Item->>Grid: onTap (callback)
    Grid->>Ctrl: onToggle(assetId)

    alt 미선택 → 선택
        Ctrl->>Ctrl: _selectedIds.add(assetId)
    else 선택 → 해제
        Ctrl->>Ctrl: _selectedIds.remove(assetId)
    end

    Ctrl->>Ctrl: notifyListeners()
    Item-->>User: 체크 뱃지 애니메이션 표시
    Bar-->>User: "N장 선택됨" 카운터 업데이트

    Note over Grid: 하단 스크롤 도달 시 페이지네이션
    User->>Grid: 스크롤 하단
    Grid->>Ctrl: onLoadMore()
    Ctrl->>Ctrl: loadMorePhotos()
    Note over Ctrl: _isLoadingPhotos 가드로<br/>중복 호출 방지
```

---

## 5. 메타데이터 추출 (핵심 플로우)

GPS가 있는 사진만 결과에 포함되고, GPS 없는 사진은 `skippedCount`로 집계된다.

```mermaid
sequenceDiagram
    actor User
    participant Sel as PhotoSelectionScreen
    participant Dialog as ExtractionProgressDialog
    participant ECtrl as ExtractionController
    participant Svc as PhotoService
    participant FS as 파일 시스템 (originFile)
    participant EXIF as exif 패키지

    User->>Sel: "메타데이터 추출" 탭
    Sel->>Dialog: showDialog (ListenableBuilder로 감쌈)
    Sel->>ECtrl: extract(selectedAssets)

    ECtrl->>ECtrl: isExtracting=true, progress=0, notifyListeners()
    Dialog-->>User: 진행 다이얼로그 표시 (0/N)

    loop 선택된 사진 N장 순회
        ECtrl->>Svc: extractMetadata([assets], onProgress)
        Svc->>FS: asset.originFile (원본 파일 요청)
        FS-->>Svc: File

        Svc->>FS: file.readAsBytes()
        FS-->>Svc: Uint8List

        Svc->>EXIF: readExifFromBytes(bytes)
        EXIF-->>Svc: Map<String, IfdTag>

        Svc->>Svc: _parseGpsCoord() — DMS → 10진수 변환
        Svc->>Svc: _parseDateTime() — DateTimeOriginal 파싱

        alt GPS 있음
            Svc->>Svc: PhotoMetadata 생성
        else GPS 없음 → photo_manager fallback
            Svc->>Svc: asset.latlngAsync()
            alt latlng 유효 (0,0 아님)
                Svc->>Svc: PhotoMetadata 생성
            else GPS 완전 없음
                Svc->>Svc: skippedCount++
            end
        end

        Svc->>ECtrl: onProgress(current, total) 콜백
        ECtrl->>ECtrl: _progress 갱신, notifyListeners()
        Dialog-->>User: 진행률 업데이트 (i/N)
    end

    Svc->>Svc: metadata 시간순 정렬
    Svc-->>ECtrl: ExtractionResult
    ECtrl->>ECtrl: _result 저장, isExtracting=false, notifyListeners()

    Sel->>Dialog: Navigator.pop() (다이얼로그 닫기)
    Sel->>Sel: MetadataResultScreen으로 push
    Sel-->>User: 추출 결과 화면 표시
```

---

## 6. 결과 화면 표시

```mermaid
sequenceDiagram
    actor User
    participant Result as MetadataResultScreen
    participant Summary as MetadataSummaryCard
    participant List as MetadataListItem (×N)

    Result->>Summary: totalSelected, withGps, skipped 전달
    Summary-->>User: 요약 카드 (선택 N장 / GPS M장 / 제외 K장)

    Result->>List: PhotoMetadata + AssetEntity 전달 (×M)
    List-->>User: 썸네일 + 파일명 + 시간 + GPS 좌표 + 카메라 정보

    Note over Result: 시간순 정렬된 목록 표시
    Note over Result: FAB "지도에서 보기" — F-2에서 활성화

    User->>Result: 뒤로가기
    Result->>Result: ExtractionController.reset() 호출
```

---

## GPS 좌표 변환 알고리즘

EXIF GPS는 **DMS(도·분·초)** 형식의 `IfdRatios`로 저장된다. 지도 SDK에서 사용하는 **10진수 위경도**로 변환한다.

```
10진수 = 도(D) + 분(M)/60 + 초(S)/3600

남위(S), 서경(W)인 경우 음수 처리: decimal = -decimal

예시:
  GPS GPSLatitude:    [37/1, 33/1, 1200/100]  →  37° 33' 12.00"
  GPS GPSLatitudeRef: N
  → 37 + 33/60 + 12/3600 = 37.553333...
```

각 IfdRatio 값은 `numerator / denominator`로 소수점 표현:

| IfdRatios index | 의미 | 예시 값 |
|-----------------|------|---------|
| `list[0]` | 도 (Degrees) | `37/1` → 37.0 |
| `list[1]` | 분 (Minutes) | `33/1` → 33.0 |
| `list[2]` | 초 (Seconds) | `1200/100` → 12.0 |
