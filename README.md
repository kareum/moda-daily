# TravelMap ArchiVer

> 스마트폰 사진첩의 GPS·시간 메타데이터를 기반으로 여행 경로를 지도 위에 시각화하고, 숏폼 영상으로 내보내는 크로스플랫폼(iOS/Android) 모바일 앱.

---

## 목표

### 핵심 가치
과거 여행의 추억을 **데이터 기반**으로 손쉽게 정리하고 콘텐츠화하여 개인 생산성 극대화.

### 단계별 개발 목표

| 단계 | 기능 | 상태 |
|------|------|------|
| **F-1** | 사진 선택 및 GPS/시간/카메라 메타데이터 추출 | ✅ 구현 완료 |
| **F-2** | 지도 시각화 (클러스터링, 경로선) | ✅ 구현 완료 |
| **F-3** | 숏폼 영상 생성 및 다운로드 (FFmpeg) | 🔜 예정 |
| **F-4** | AI 자막 생성 (Geocoding + LLM) | 🔜 예정 |

---

## 기술 스택

| 분류 | 선택 |
|------|------|
| Framework | Flutter (Dart) |
| 최소 OS | iOS 14+, Android 10 (API 29)+ |
| 사진첩 접근 | `photo_manager ^3.3.0` |
| EXIF 파싱 | `exif ^3.3.0` |
| 날짜 포맷 | `intl ^0.20.2` |
| 지도 SDK | `flutter_map ^8.2.2` + OpenStreetMap |
| 좌표 타입 | `latlong2 ^0.9.1` |
| 영상 편집 | `ffmpeg_kit_flutter` (F-3) |
| Geocoding | Google Maps Geocoding API (F-4) |

---

## 아키텍처

단방향 데이터 흐름을 원칙으로 4개 레이어로 분리한다.

```
┌─────────────────────────────────────────────────────────────┐
│                        Services                             │
│   photo_service  │  map_service  │  video_service          │
│   (갤러리/EXIF)   │  (Geocoding)  │  (FFmpeg)               │
└──────────────────────────┬──────────────────────────────────┘
                           │ call
┌──────────────────────────▼──────────────────────────────────┐
│                       Controllers                           │
│  PhotoSelectionController │ ExtractionController            │
│  TravelMapController      │  (ChangeNotifier)               │
└──────────────────────────┬──────────────────────────────────┘
                           │ ListenableBuilder (subscribe)
┌──────────────────────────▼──────────────────────────────────┐
│                        Screens                              │
│  HomeScreen │ PhotoSelectionScreen │ MetadataResultScreen   │
│  TravelMapScreen                                            │
└──────────────────────────┬──────────────────────────────────┘
                           │ constructor injection
┌──────────────────────────▼──────────────────────────────────┐
│                        Widgets                              │
│  PhotoGrid │ DateFilterBar │ AlbumSelectorSheet │ ...        │
│  MapRouteLayer │ MapPhotoMarker │ PhotoInfoPanel │ ...        │
│  (순수 UI — 외부 상태에 의존하지 않음)                          │
└─────────────────────────────────────────────────────────────┘
```

### 레이어 책임 원칙

- **Services**: 외부 환경(디바이스 갤러리, 외부 API)과 통신하는 유일한 창구. 상태를 보유하지 않음.
- **Controllers**: `ChangeNotifier`로 UI 상태를 관리. Service를 호출하고 결과를 가공. Screen이 직접 Service를 호출하지 못하게 격리.
- **Screens**: Controller를 `ListenableBuilder`로 구독(Watch)만 함. 직접 API 호출 없음. 라우팅과 레이아웃 조합만 담당.
- **Widgets**: Constructor로만 데이터를 주입받는 순수 UI 컴포넌트. 특정 Controller/Service에 종속되지 않아 재사용 가능.

---

## 파일 구조

```
lib/
├── main.dart
├── models/
│   ├── photo_metadata.dart        # 사진 메타데이터 데이터 클래스
│   └── extraction_result.dart     # 추출 결과 집계 데이터 클래스
├── services/
│   ├── photo_service.dart         # 갤러리 접근 + EXIF 파싱
│   ├── map_service.dart           # Geocoding API (F-4)
│   └── video_service.dart         # FFmpeg 렌더링 (F-3)
├── controllers/
│   ├── photo_selection_controller.dart  # 사진 선택 상태 관리
│   ├── extraction_controller.dart       # 추출 진행/결과 상태 관리
│   └── travel_map_controller.dart       # 지도 클러스터·선택 마커 상태 관리
├── screens/
│   ├── home_screen.dart
│   ├── photo_selection_screen.dart
│   ├── metadata_result_screen.dart
│   └── travel_map_screen.dart           # 여행 경로 지도 화면
└── widgets/
    ├── photo_grid.dart
    ├── photo_grid_item.dart
    ├── album_selector_sheet.dart
    ├── date_filter_bar.dart
    ├── selection_bottom_bar.dart
    ├── extraction_progress_dialog.dart
    ├── metadata_summary_card.dart
    ├── metadata_list_item.dart
    ├── map_route_layer.dart             # 경로선 Polyline 레이어
    ├── map_photo_marker.dart            # 사진 썸네일 마커 / 클러스터 마커
    └── photo_info_panel.dart            # 마커 탭 시 하단 정보 패널
```

---

## 설치 및 실행

[PLATFORM_SETUP.md](PLATFORM_SETUP.md) 참고.

```bash
# 1. 의존성 설치
flutter pub get

# 2. 실행 (디바이스 목록 확인 후)
flutter devices
flutter run -d <device_id>
```

---

## 상세 문서

| 문서 | 내용 |
|------|------|
| [SEQUENCE.md](SEQUENCE.md) | 주요 유저 시나리오별 시퀀스 다이어그램 |
| [SERVICES.md](SERVICES.md) | Service 레이어 상세 구현 명세 |
| [CONTROLLERS.md](CONTROLLERS.md) | Controller 레이어 상태·메서드 명세 |
| [SCREENS.md](SCREENS.md) | Screen·Widget 레이어 구성 명세 |
| [PLATFORM_SETUP.md](PLATFORM_SETUP.md) | Android/iOS 플랫폼 설정 가이드 |

---

## 화면 흐름

```
HomeScreen
  └─ "여행 사진 선택하기"
       └─ PhotoSelectionScreen  (앨범 탐색 · 날짜 필터 · 멀티셀렉트)
            └─ "메타데이터 추출"
                 └─ ExtractionProgressDialog
                      └─ MetadataResultScreen  (요약 카드 · 시간순 목록)
                           └─ "지도에서 보기" FAB
                                └─ TravelMapScreen  (경로선 · 마커 · 클러스터)
                                     └─ 마커 탭 → PhotoInfoPanel
```

---

## F-3 구현 로드맵 — 숏폼 영상 생성 & 아카이브

선택된 사진으로 숏폼 영상을 만들어 저장하고, 생성된 영상과 연결된 GPS 정보를 DB에 보관한다.  
**원칙: 모든 작업은 모듈 단위로 진행, 디자인(UI)과 기능(로직)은 항상 분리**

### Phase 1 — 데이터 기반 `[ ]`
> 모든 모듈의 계약서. 가장 먼저 확정.

| # | 작업 | 파일 | 상태 |
|---|---|---|---|
| 1 | `VideoArchive` 모델 (id, title, videoPath, thumbnailPath, createdAt, durationSec, editCount 등) | `core/database/app_database.dart` | `[x]` |
| 2 | `VideoGpsPoint` 모델 (archiveId, lat, lng, capturedAt, photoAssetId, orderIndex) | `core/database/app_database.dart` | `[x]` |
| 3 | `VideoEditHistory` 테이블 + `drift` DB 설정 | `core/database/` | `[x]` |
| 4 | `ArchiveRepository` CRUD + 편집이력(saveEdit, rollback) | `repositories/archive_repository.dart` | `[x]` |

### Phase 2 — 서비스 레이어 `[ ]`
> 비즈니스 로직. BuildContext / Widget import 금지.

| # | 작업 | 파일 | 상태 |
|---|---|---|---|
| 5 | `ffmpeg_kit_flutter` 추가 + `VideoService.exportVideo()` / `applyEdit()` / `extractThumbnail()` | `services/video_service.dart` | `[x]` |
| 6 | `GalleryService.saveVideoToGallery()` / `saveImageToGallery()` | `services/gallery_service.dart` | `[x]` |
| 7 | `ArchiveController` — 생성·편집·롤백·삭제 + `ArchiveState` sealed class | `controllers/archive_controller.dart` | `[x]` |

### Phase 3 — UI 컴포넌트 `[ ]`
> 디자인만. 로직·Controller 직접 호출 금지. 데이터는 생성자로만 주입.

| # | 작업 | 파일 | 상태 |
|---|---|---|---|
| 8 | `VideoProgressSheet` — 생성/편집 진행률 바텀시트 (완료·에러 상태 포함) | `widgets/components/video_progress_sheet.dart` | `[x]` |
| 9 | `ArchiveCard` — 저장 영상 카드 (썸네일·편집 버전 배지·액션 버튼) | `widgets/components/archive_card.dart` | `[x]` |
| 10 | `VideoPlayerCard` — 인라인 영상 플레이어 (시크바·글래스 컨트롤) | `widgets/components/video_player_card.dart` | `[x]` |
| + | `TravelMapScreen` '영상 만들기' FAB 진입점 추가 | `screens/travel_map_screen.dart` | `[x]` |

### Phase 4 — 화면 조립 `[ ]`
> 컴포넌트(Phase 3) + 컨트롤러(Phase 2) 연결.

| # | 작업 | 파일 | 상태 |
|---|---|---|---|
| 11 | `VideoCreationScreen` — 생성 흐름 (진행 → 완료 → 저장) | `screens/` | `[ ]` |
| 12 | `ArchiveListScreen` — 저장된 영상 목록 | `screens/` | `[ ]` |
| 13 | `VideoDetailScreen` — 영상 재생 + GPS 경로 리플레이 | `screens/` | `[ ]` |

### 레이어 데이터 흐름
```
[Phase 1] 모델/DB → [Phase 2] 서비스/컨트롤러   ← 로직 레이어
                                  ↕
          [Phase 3] 컴포넌트 → [Phase 4] 화면    ← UI 레이어
```

---

## 데이터 보안 원칙

MVP 단계에서는 사용자 사진 데이터를 **서버로 전송하지 않는다.**  
메타데이터 추출 및 영상 렌더링 전 과정을 모바일 기기 내에서 로컬로 처리한다.
