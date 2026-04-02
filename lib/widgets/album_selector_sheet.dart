import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// 앨범 목록을 보여주는 바텀 시트.
/// [albums], [currentAlbum], [onSelect] 을 constructor로 받는 순수 위젯.
class AlbumSelectorSheet extends StatelessWidget {
  final List<AssetPathEntity> albums;
  final AssetPathEntity? currentAlbum;
  final void Function(AssetPathEntity) onSelect;

  const AlbumSelectorSheet({
    super.key,
    required this.albums,
    required this.currentAlbum,
    required this.onSelect,
  });

  /// 바텀 시트 띄우기 헬퍼
  static Future<void> show(
    BuildContext context, {
    required List<AssetPathEntity> albums,
    required AssetPathEntity? currentAlbum,
    required void Function(AssetPathEntity) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AlbumSelectorSheet(
        albums: albums,
        currentAlbum: currentAlbum,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '앨범 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Divider(),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: albums.length,
            itemBuilder: (_, index) {
              final album = albums[index];
              final isSelected = album.id == currentAlbum?.id;
              return ListTile(
                leading: const Icon(Icons.photo_album_outlined),
                title: Text(album.name),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  onSelect(album);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
