# 플랫폼 설정 가이드

## 1. 프로젝트 생성

```bash
cd /Users/areumkim/TravelMap
flutter create . --project-name travel_map_archiver --org com.yourcompany
```

생성 후 `lib/main.dart` 등은 이 폴더의 파일로 덮어씌워집니다.

---

## 2. Android 설정

### `android/app/src/main/AndroidManifest.xml`

`<manifest>` 태그 안, `<application>` 태그 **위**에 추가:

```xml
<!-- Android 12 이하: 저장소 읽기 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Android 13+: 이미지 접근 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- GPS EXIF 메타데이터 접근 (Android 10+) -->
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />
```

### `android/app/build.gradle`

```gradle
android {
    compileSdk 34

    defaultConfig {
        minSdk 29        // Android 10 이상 (요구사항 T-1-2)
        targetSdk 34
    }
}
```

---

## 3. iOS 설정

### `ios/Runner/Info.plist`

`<dict>` 안에 추가:

```xml
<!-- 사진첩 접근 권한 설명 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>여행 사진의 GPS와 시간 정보를 추출하기 위해 사진첩 접근이 필요합니다.</string>

<!-- iOS 14+: 제한적 접근(Limited Access) 허용 -->
<key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
<false/>
```

---

## 4. 의존성 설치 및 실행

```bash
flutter pub get
flutter run
```

---

## 5. 주요 라이브러리 버전

| 패키지 | 버전 | 용도 |
|--------|------|------|
| photo_manager | ^3.3.0 | 갤러리 접근, 에셋 관리 |
| exif | ^3.4.0 | EXIF 메타데이터 파싱 |
| intl | ^0.19.0 | 날짜 포맷, 다국어 |
