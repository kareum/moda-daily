import 'photo_metadata.dart';

class ExtractionResult {
  final List<PhotoMetadata> metadata;
  final int skippedCount;

  const ExtractionResult({
    required this.metadata,
    required this.skippedCount,
  });

  int get successCount => metadata.length;
  int get totalProcessed => metadata.length + skippedCount;
  bool get hasData => metadata.isNotEmpty;
}
