import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/photo_metadata.dart';

/// 추출된 단일 사진 메타데이터를 표시하는 리스트 아이템.
/// [metadata] 와 썸네일 로딩을 위한 [asset] 만 받는다.
class MetadataListItem extends StatelessWidget {
  final PhotoMetadata metadata;
  final AssetEntity? asset; // 썸네일 표시용 (null이면 placeholder)

  const MetadataListItem({
    super.key,
    required this.metadata,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: asset != null
                    ? FutureBuilder<Uint8List?>(
                        future: asset!.thumbnailDataWithSize(
                            const ThumbnailSize.square(144)),
                        builder: (_, snapshot) {
                          final data = snapshot.data;
                          if (data == null) {
                            return const ColoredBox(
                              color: Color(0xFFEEEEEE),
                              child: Icon(Icons.image_outlined,
                                  color: Colors.black26),
                            );
                          }
                          return Image.memory(data, fit: BoxFit.cover);
                        },
                      )
                    : const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.image_outlined, color: Colors.black26),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // 메타데이터 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 파일명
                  Text(
                    metadata.fileName ?? metadata.assetId,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 촬영 일시
                  _InfoRow(
                    icon: Icons.access_time,
                    text: DateFormat('yyyy.MM.dd HH:mm:ss')
                        .format(metadata.capturedAt),
                  ),

                  // GPS 좌표
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: metadata.coordinateText,
                    color: Colors.green,
                  ),

                  // 고도 (있을 때만)
                  if (metadata.altitude != null)
                    _InfoRow(
                      icon: Icons.terrain_outlined,
                      text: metadata.altitudeText,
                    ),

                  // 카메라 모델 (있을 때만)
                  if (metadata.cameraModel != null ||
                      metadata.cameraMake != null)
                    _InfoRow(
                      icon: Icons.camera_alt_outlined,
                      text: metadata.cameraInfo,
                    ),

                  // 촬영 방향 (있을 때만)
                  if (metadata.imageDirection != null)
                    _InfoRow(
                      icon: Icons.explore_outlined,
                      text: metadata.directionText,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: c),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
