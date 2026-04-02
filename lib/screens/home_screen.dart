import 'package:flutter/material.dart';

import 'photo_selection_screen.dart';

/// 앱 진입 화면. 라우팅과 레이아웃만 담당한다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // 로고 / 타이틀
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TravelMap',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'ArchiVer',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 설명
              const Text(
                '사진첩의 GPS · 시간 데이터를 기반으로\n여행 경로를 지도 위에 시각화합니다.',
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 40),

              // 기능 소개 칩
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeatureChip(icon: Icons.location_on_outlined, label: 'GPS 자동 추출'),
                  _FeatureChip(icon: Icons.route_outlined, label: '여행 경로 시각화'),
                  _FeatureChip(icon: Icons.videocam_outlined, label: '숏폼 영상 생성'),
                  _FeatureChip(icon: Icons.subtitles_outlined, label: 'AI 자막 생성'),
                ],
              ),

              const Spacer(flex: 2),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _goToPhotoSelection(context),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('여행 사진 선택하기',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'GPS 정보가 포함된 사진만 분석됩니다',
                  style: TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPhotoSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhotoSelectionScreen()),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
