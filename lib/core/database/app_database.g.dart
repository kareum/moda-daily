// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VideoArchivesTable extends VideoArchives
    with TableInfo<$VideoArchivesTable, VideoArchive> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoArchivesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _videoPathMeta =
      const VerificationMeta('videoPath');
  @override
  late final GeneratedColumn<String> videoPath = GeneratedColumn<String>(
      'video_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gpsPointCountMeta =
      const VerificationMeta('gpsPointCount');
  @override
  late final GeneratedColumn<int> gpsPointCount = GeneratedColumn<int>(
      'gps_point_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _originalVideoPathMeta =
      const VerificationMeta('originalVideoPath');
  @override
  late final GeneratedColumn<String> originalVideoPath =
      GeneratedColumn<String>('original_video_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editCountMeta =
      const VerificationMeta('editCount');
  @override
  late final GeneratedColumn<int> editCount = GeneratedColumn<int>(
      'edit_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastEditConfigJsonMeta =
      const VerificationMeta('lastEditConfigJson');
  @override
  late final GeneratedColumn<String> lastEditConfigJson =
      GeneratedColumn<String>('last_edit_config_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        videoPath,
        thumbnailPath,
        createdAt,
        updatedAt,
        durationSeconds,
        gpsPointCount,
        originalVideoPath,
        editCount,
        lastEditConfigJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_archives';
  @override
  VerificationContext validateIntegrity(Insertable<VideoArchive> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('video_path')) {
      context.handle(_videoPathMeta,
          videoPath.isAcceptableOrUnknown(data['video_path']!, _videoPathMeta));
    } else if (isInserting) {
      context.missing(_videoPathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('gps_point_count')) {
      context.handle(
          _gpsPointCountMeta,
          gpsPointCount.isAcceptableOrUnknown(
              data['gps_point_count']!, _gpsPointCountMeta));
    }
    if (data.containsKey('original_video_path')) {
      context.handle(
          _originalVideoPathMeta,
          originalVideoPath.isAcceptableOrUnknown(
              data['original_video_path']!, _originalVideoPathMeta));
    } else if (isInserting) {
      context.missing(_originalVideoPathMeta);
    }
    if (data.containsKey('edit_count')) {
      context.handle(_editCountMeta,
          editCount.isAcceptableOrUnknown(data['edit_count']!, _editCountMeta));
    }
    if (data.containsKey('last_edit_config_json')) {
      context.handle(
          _lastEditConfigJsonMeta,
          lastEditConfigJson.isAcceptableOrUnknown(
              data['last_edit_config_json']!, _lastEditConfigJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoArchive map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoArchive(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      videoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_path'])!,
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      gpsPointCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gps_point_count'])!,
      originalVideoPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_video_path'])!,
      editCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}edit_count'])!,
      lastEditConfigJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_edit_config_json']),
    );
  }

  @override
  $VideoArchivesTable createAlias(String alias) {
    return $VideoArchivesTable(attachedDatabase, alias);
  }
}

class VideoArchive extends DataClass implements Insertable<VideoArchive> {
  final int id;
  final String title;

  /// 최종 저장된 MP4 경로 (camera roll 또는 앱 내부 경로)
  final String videoPath;

  /// 첫 프레임 썸네일 경로
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int durationSeconds;
  final int gpsPointCount;

  /// 최초 생성된 원본 MP4 경로 (편집 후에도 유지)
  final String originalVideoPath;

  /// 편집 횟수 (0 = 원본 그대로)
  final int editCount;

  /// 마지막으로 적용된 편집 설정 JSON (bgm, speed, filter 등)
  /// null이면 편집 이력 없음
  final String? lastEditConfigJson;
  const VideoArchive(
      {required this.id,
      required this.title,
      required this.videoPath,
      this.thumbnailPath,
      required this.createdAt,
      required this.updatedAt,
      required this.durationSeconds,
      required this.gpsPointCount,
      required this.originalVideoPath,
      required this.editCount,
      this.lastEditConfigJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['video_path'] = Variable<String>(videoPath);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['gps_point_count'] = Variable<int>(gpsPointCount);
    map['original_video_path'] = Variable<String>(originalVideoPath);
    map['edit_count'] = Variable<int>(editCount);
    if (!nullToAbsent || lastEditConfigJson != null) {
      map['last_edit_config_json'] = Variable<String>(lastEditConfigJson);
    }
    return map;
  }

  VideoArchivesCompanion toCompanion(bool nullToAbsent) {
    return VideoArchivesCompanion(
      id: Value(id),
      title: Value(title),
      videoPath: Value(videoPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      durationSeconds: Value(durationSeconds),
      gpsPointCount: Value(gpsPointCount),
      originalVideoPath: Value(originalVideoPath),
      editCount: Value(editCount),
      lastEditConfigJson: lastEditConfigJson == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEditConfigJson),
    );
  }

  factory VideoArchive.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoArchive(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      videoPath: serializer.fromJson<String>(json['videoPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      gpsPointCount: serializer.fromJson<int>(json['gpsPointCount']),
      originalVideoPath: serializer.fromJson<String>(json['originalVideoPath']),
      editCount: serializer.fromJson<int>(json['editCount']),
      lastEditConfigJson:
          serializer.fromJson<String?>(json['lastEditConfigJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'videoPath': serializer.toJson<String>(videoPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'gpsPointCount': serializer.toJson<int>(gpsPointCount),
      'originalVideoPath': serializer.toJson<String>(originalVideoPath),
      'editCount': serializer.toJson<int>(editCount),
      'lastEditConfigJson': serializer.toJson<String?>(lastEditConfigJson),
    };
  }

  VideoArchive copyWith(
          {int? id,
          String? title,
          String? videoPath,
          Value<String?> thumbnailPath = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          int? durationSeconds,
          int? gpsPointCount,
          String? originalVideoPath,
          int? editCount,
          Value<String?> lastEditConfigJson = const Value.absent()}) =>
      VideoArchive(
        id: id ?? this.id,
        title: title ?? this.title,
        videoPath: videoPath ?? this.videoPath,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        gpsPointCount: gpsPointCount ?? this.gpsPointCount,
        originalVideoPath: originalVideoPath ?? this.originalVideoPath,
        editCount: editCount ?? this.editCount,
        lastEditConfigJson: lastEditConfigJson.present
            ? lastEditConfigJson.value
            : this.lastEditConfigJson,
      );
  VideoArchive copyWithCompanion(VideoArchivesCompanion data) {
    return VideoArchive(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      videoPath: data.videoPath.present ? data.videoPath.value : this.videoPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      gpsPointCount: data.gpsPointCount.present
          ? data.gpsPointCount.value
          : this.gpsPointCount,
      originalVideoPath: data.originalVideoPath.present
          ? data.originalVideoPath.value
          : this.originalVideoPath,
      editCount: data.editCount.present ? data.editCount.value : this.editCount,
      lastEditConfigJson: data.lastEditConfigJson.present
          ? data.lastEditConfigJson.value
          : this.lastEditConfigJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoArchive(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('videoPath: $videoPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('gpsPointCount: $gpsPointCount, ')
          ..write('originalVideoPath: $originalVideoPath, ')
          ..write('editCount: $editCount, ')
          ..write('lastEditConfigJson: $lastEditConfigJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      videoPath,
      thumbnailPath,
      createdAt,
      updatedAt,
      durationSeconds,
      gpsPointCount,
      originalVideoPath,
      editCount,
      lastEditConfigJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoArchive &&
          other.id == this.id &&
          other.title == this.title &&
          other.videoPath == this.videoPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.gpsPointCount == this.gpsPointCount &&
          other.originalVideoPath == this.originalVideoPath &&
          other.editCount == this.editCount &&
          other.lastEditConfigJson == this.lastEditConfigJson);
}

class VideoArchivesCompanion extends UpdateCompanion<VideoArchive> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> videoPath;
  final Value<String?> thumbnailPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> durationSeconds;
  final Value<int> gpsPointCount;
  final Value<String> originalVideoPath;
  final Value<int> editCount;
  final Value<String?> lastEditConfigJson;
  const VideoArchivesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.videoPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.gpsPointCount = const Value.absent(),
    this.originalVideoPath = const Value.absent(),
    this.editCount = const Value.absent(),
    this.lastEditConfigJson = const Value.absent(),
  });
  VideoArchivesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String videoPath,
    this.thumbnailPath = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    required int durationSeconds,
    this.gpsPointCount = const Value.absent(),
    required String originalVideoPath,
    this.editCount = const Value.absent(),
    this.lastEditConfigJson = const Value.absent(),
  })  : title = Value(title),
        videoPath = Value(videoPath),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        durationSeconds = Value(durationSeconds),
        originalVideoPath = Value(originalVideoPath);
  static Insertable<VideoArchive> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? videoPath,
    Expression<String>? thumbnailPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? durationSeconds,
    Expression<int>? gpsPointCount,
    Expression<String>? originalVideoPath,
    Expression<int>? editCount,
    Expression<String>? lastEditConfigJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (videoPath != null) 'video_path': videoPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (gpsPointCount != null) 'gps_point_count': gpsPointCount,
      if (originalVideoPath != null) 'original_video_path': originalVideoPath,
      if (editCount != null) 'edit_count': editCount,
      if (lastEditConfigJson != null)
        'last_edit_config_json': lastEditConfigJson,
    });
  }

  VideoArchivesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? videoPath,
      Value<String?>? thumbnailPath,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? durationSeconds,
      Value<int>? gpsPointCount,
      Value<String>? originalVideoPath,
      Value<int>? editCount,
      Value<String?>? lastEditConfigJson}) {
    return VideoArchivesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      videoPath: videoPath ?? this.videoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      gpsPointCount: gpsPointCount ?? this.gpsPointCount,
      originalVideoPath: originalVideoPath ?? this.originalVideoPath,
      editCount: editCount ?? this.editCount,
      lastEditConfigJson: lastEditConfigJson ?? this.lastEditConfigJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (videoPath.present) {
      map['video_path'] = Variable<String>(videoPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (gpsPointCount.present) {
      map['gps_point_count'] = Variable<int>(gpsPointCount.value);
    }
    if (originalVideoPath.present) {
      map['original_video_path'] = Variable<String>(originalVideoPath.value);
    }
    if (editCount.present) {
      map['edit_count'] = Variable<int>(editCount.value);
    }
    if (lastEditConfigJson.present) {
      map['last_edit_config_json'] = Variable<String>(lastEditConfigJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoArchivesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('videoPath: $videoPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('gpsPointCount: $gpsPointCount, ')
          ..write('originalVideoPath: $originalVideoPath, ')
          ..write('editCount: $editCount, ')
          ..write('lastEditConfigJson: $lastEditConfigJson')
          ..write(')'))
        .toString();
  }
}

class $VideoGpsPointsTable extends VideoGpsPoints
    with TableInfo<$VideoGpsPointsTable, VideoGpsPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoGpsPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _archiveIdMeta =
      const VerificationMeta('archiveId');
  @override
  late final GeneratedColumn<int> archiveId = GeneratedColumn<int>(
      'archive_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES video_archives (id)'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _photoAssetIdMeta =
      const VerificationMeta('photoAssetId');
  @override
  late final GeneratedColumn<String> photoAssetId = GeneratedColumn<String>(
      'photo_asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        archiveId,
        latitude,
        longitude,
        altitude,
        capturedAt,
        photoAssetId,
        orderIndex
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_gps_points';
  @override
  VerificationContext validateIntegrity(Insertable<VideoGpsPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('archive_id')) {
      context.handle(_archiveIdMeta,
          archiveId.isAcceptableOrUnknown(data['archive_id']!, _archiveIdMeta));
    } else if (isInserting) {
      context.missing(_archiveIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('photo_asset_id')) {
      context.handle(
          _photoAssetIdMeta,
          photoAssetId.isAcceptableOrUnknown(
              data['photo_asset_id']!, _photoAssetIdMeta));
    } else if (isInserting) {
      context.missing(_photoAssetIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoGpsPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoGpsPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      archiveId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}archive_id'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      photoAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_asset_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $VideoGpsPointsTable createAlias(String alias) {
    return $VideoGpsPointsTable(attachedDatabase, alias);
  }
}

class VideoGpsPoint extends DataClass implements Insertable<VideoGpsPoint> {
  final int id;
  final int archiveId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime capturedAt;
  final String photoAssetId;

  /// 영상 내 재생 순서 (0-based)
  final int orderIndex;
  const VideoGpsPoint(
      {required this.id,
      required this.archiveId,
      required this.latitude,
      required this.longitude,
      this.altitude,
      required this.capturedAt,
      required this.photoAssetId,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['archive_id'] = Variable<int>(archiveId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['photo_asset_id'] = Variable<String>(photoAssetId);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  VideoGpsPointsCompanion toCompanion(bool nullToAbsent) {
    return VideoGpsPointsCompanion(
      id: Value(id),
      archiveId: Value(archiveId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      capturedAt: Value(capturedAt),
      photoAssetId: Value(photoAssetId),
      orderIndex: Value(orderIndex),
    );
  }

  factory VideoGpsPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoGpsPoint(
      id: serializer.fromJson<int>(json['id']),
      archiveId: serializer.fromJson<int>(json['archiveId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      photoAssetId: serializer.fromJson<String>(json['photoAssetId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'archiveId': serializer.toJson<int>(archiveId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'photoAssetId': serializer.toJson<String>(photoAssetId),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  VideoGpsPoint copyWith(
          {int? id,
          int? archiveId,
          double? latitude,
          double? longitude,
          Value<double?> altitude = const Value.absent(),
          DateTime? capturedAt,
          String? photoAssetId,
          int? orderIndex}) =>
      VideoGpsPoint(
        id: id ?? this.id,
        archiveId: archiveId ?? this.archiveId,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        altitude: altitude.present ? altitude.value : this.altitude,
        capturedAt: capturedAt ?? this.capturedAt,
        photoAssetId: photoAssetId ?? this.photoAssetId,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  VideoGpsPoint copyWithCompanion(VideoGpsPointsCompanion data) {
    return VideoGpsPoint(
      id: data.id.present ? data.id.value : this.id,
      archiveId: data.archiveId.present ? data.archiveId.value : this.archiveId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      photoAssetId: data.photoAssetId.present
          ? data.photoAssetId.value
          : this.photoAssetId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoGpsPoint(')
          ..write('id: $id, ')
          ..write('archiveId: $archiveId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('photoAssetId: $photoAssetId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, archiveId, latitude, longitude, altitude,
      capturedAt, photoAssetId, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoGpsPoint &&
          other.id == this.id &&
          other.archiveId == this.archiveId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.capturedAt == this.capturedAt &&
          other.photoAssetId == this.photoAssetId &&
          other.orderIndex == this.orderIndex);
}

class VideoGpsPointsCompanion extends UpdateCompanion<VideoGpsPoint> {
  final Value<int> id;
  final Value<int> archiveId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<DateTime> capturedAt;
  final Value<String> photoAssetId;
  final Value<int> orderIndex;
  const VideoGpsPointsCompanion({
    this.id = const Value.absent(),
    this.archiveId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.photoAssetId = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  VideoGpsPointsCompanion.insert({
    this.id = const Value.absent(),
    required int archiveId,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    required DateTime capturedAt,
    required String photoAssetId,
    required int orderIndex,
  })  : archiveId = Value(archiveId),
        latitude = Value(latitude),
        longitude = Value(longitude),
        capturedAt = Value(capturedAt),
        photoAssetId = Value(photoAssetId),
        orderIndex = Value(orderIndex);
  static Insertable<VideoGpsPoint> custom({
    Expression<int>? id,
    Expression<int>? archiveId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<DateTime>? capturedAt,
    Expression<String>? photoAssetId,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (archiveId != null) 'archive_id': archiveId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (photoAssetId != null) 'photo_asset_id': photoAssetId,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  VideoGpsPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? archiveId,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double?>? altitude,
      Value<DateTime>? capturedAt,
      Value<String>? photoAssetId,
      Value<int>? orderIndex}) {
    return VideoGpsPointsCompanion(
      id: id ?? this.id,
      archiveId: archiveId ?? this.archiveId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      capturedAt: capturedAt ?? this.capturedAt,
      photoAssetId: photoAssetId ?? this.photoAssetId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (archiveId.present) {
      map['archive_id'] = Variable<int>(archiveId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (photoAssetId.present) {
      map['photo_asset_id'] = Variable<String>(photoAssetId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoGpsPointsCompanion(')
          ..write('id: $id, ')
          ..write('archiveId: $archiveId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('photoAssetId: $photoAssetId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $VideoEditHistoryTable extends VideoEditHistory
    with TableInfo<$VideoEditHistoryTable, VideoEditHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoEditHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _archiveIdMeta =
      const VerificationMeta('archiveId');
  @override
  late final GeneratedColumn<int> archiveId = GeneratedColumn<int>(
      'archive_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES video_archives (id)'));
  static const VerificationMeta _videoPathMeta =
      const VerificationMeta('videoPath');
  @override
  late final GeneratedColumn<String> videoPath = GeneratedColumn<String>(
      'video_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editConfigJsonMeta =
      const VerificationMeta('editConfigJson');
  @override
  late final GeneratedColumn<String> editConfigJson = GeneratedColumn<String>(
      'edit_config_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editedAtMeta =
      const VerificationMeta('editedAt');
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
      'edited_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, archiveId, videoPath, editConfigJson, editedAt, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_edit_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<VideoEditHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('archive_id')) {
      context.handle(_archiveIdMeta,
          archiveId.isAcceptableOrUnknown(data['archive_id']!, _archiveIdMeta));
    } else if (isInserting) {
      context.missing(_archiveIdMeta);
    }
    if (data.containsKey('video_path')) {
      context.handle(_videoPathMeta,
          videoPath.isAcceptableOrUnknown(data['video_path']!, _videoPathMeta));
    } else if (isInserting) {
      context.missing(_videoPathMeta);
    }
    if (data.containsKey('edit_config_json')) {
      context.handle(
          _editConfigJsonMeta,
          editConfigJson.isAcceptableOrUnknown(
              data['edit_config_json']!, _editConfigJsonMeta));
    } else if (isInserting) {
      context.missing(_editConfigJsonMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(_editedAtMeta,
          editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta));
    } else if (isInserting) {
      context.missing(_editedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoEditHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoEditHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      archiveId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}archive_id'])!,
      videoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_path'])!,
      editConfigJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}edit_config_json'])!,
      editedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}edited_at'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $VideoEditHistoryTable createAlias(String alias) {
    return $VideoEditHistoryTable(attachedDatabase, alias);
  }
}

class VideoEditHistoryData extends DataClass
    implements Insertable<VideoEditHistoryData> {
  final int id;
  final int archiveId;

  /// 이 편집 버전의 MP4 경로 (원본 덮어쓰지 않고 별도 파일)
  final String videoPath;

  /// 적용된 편집 설정 JSON (bgm, speed, trimStart, trimEnd, filter 등)
  final String editConfigJson;
  final DateTime editedAt;

  /// 편집 버전 번호 (1부터 시작)
  final int version;
  const VideoEditHistoryData(
      {required this.id,
      required this.archiveId,
      required this.videoPath,
      required this.editConfigJson,
      required this.editedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['archive_id'] = Variable<int>(archiveId);
    map['video_path'] = Variable<String>(videoPath);
    map['edit_config_json'] = Variable<String>(editConfigJson);
    map['edited_at'] = Variable<DateTime>(editedAt);
    map['version'] = Variable<int>(version);
    return map;
  }

  VideoEditHistoryCompanion toCompanion(bool nullToAbsent) {
    return VideoEditHistoryCompanion(
      id: Value(id),
      archiveId: Value(archiveId),
      videoPath: Value(videoPath),
      editConfigJson: Value(editConfigJson),
      editedAt: Value(editedAt),
      version: Value(version),
    );
  }

  factory VideoEditHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoEditHistoryData(
      id: serializer.fromJson<int>(json['id']),
      archiveId: serializer.fromJson<int>(json['archiveId']),
      videoPath: serializer.fromJson<String>(json['videoPath']),
      editConfigJson: serializer.fromJson<String>(json['editConfigJson']),
      editedAt: serializer.fromJson<DateTime>(json['editedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'archiveId': serializer.toJson<int>(archiveId),
      'videoPath': serializer.toJson<String>(videoPath),
      'editConfigJson': serializer.toJson<String>(editConfigJson),
      'editedAt': serializer.toJson<DateTime>(editedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  VideoEditHistoryData copyWith(
          {int? id,
          int? archiveId,
          String? videoPath,
          String? editConfigJson,
          DateTime? editedAt,
          int? version}) =>
      VideoEditHistoryData(
        id: id ?? this.id,
        archiveId: archiveId ?? this.archiveId,
        videoPath: videoPath ?? this.videoPath,
        editConfigJson: editConfigJson ?? this.editConfigJson,
        editedAt: editedAt ?? this.editedAt,
        version: version ?? this.version,
      );
  VideoEditHistoryData copyWithCompanion(VideoEditHistoryCompanion data) {
    return VideoEditHistoryData(
      id: data.id.present ? data.id.value : this.id,
      archiveId: data.archiveId.present ? data.archiveId.value : this.archiveId,
      videoPath: data.videoPath.present ? data.videoPath.value : this.videoPath,
      editConfigJson: data.editConfigJson.present
          ? data.editConfigJson.value
          : this.editConfigJson,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoEditHistoryData(')
          ..write('id: $id, ')
          ..write('archiveId: $archiveId, ')
          ..write('videoPath: $videoPath, ')
          ..write('editConfigJson: $editConfigJson, ')
          ..write('editedAt: $editedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, archiveId, videoPath, editConfigJson, editedAt, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoEditHistoryData &&
          other.id == this.id &&
          other.archiveId == this.archiveId &&
          other.videoPath == this.videoPath &&
          other.editConfigJson == this.editConfigJson &&
          other.editedAt == this.editedAt &&
          other.version == this.version);
}

class VideoEditHistoryCompanion extends UpdateCompanion<VideoEditHistoryData> {
  final Value<int> id;
  final Value<int> archiveId;
  final Value<String> videoPath;
  final Value<String> editConfigJson;
  final Value<DateTime> editedAt;
  final Value<int> version;
  const VideoEditHistoryCompanion({
    this.id = const Value.absent(),
    this.archiveId = const Value.absent(),
    this.videoPath = const Value.absent(),
    this.editConfigJson = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.version = const Value.absent(),
  });
  VideoEditHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int archiveId,
    required String videoPath,
    required String editConfigJson,
    required DateTime editedAt,
    required int version,
  })  : archiveId = Value(archiveId),
        videoPath = Value(videoPath),
        editConfigJson = Value(editConfigJson),
        editedAt = Value(editedAt),
        version = Value(version);
  static Insertable<VideoEditHistoryData> custom({
    Expression<int>? id,
    Expression<int>? archiveId,
    Expression<String>? videoPath,
    Expression<String>? editConfigJson,
    Expression<DateTime>? editedAt,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (archiveId != null) 'archive_id': archiveId,
      if (videoPath != null) 'video_path': videoPath,
      if (editConfigJson != null) 'edit_config_json': editConfigJson,
      if (editedAt != null) 'edited_at': editedAt,
      if (version != null) 'version': version,
    });
  }

  VideoEditHistoryCompanion copyWith(
      {Value<int>? id,
      Value<int>? archiveId,
      Value<String>? videoPath,
      Value<String>? editConfigJson,
      Value<DateTime>? editedAt,
      Value<int>? version}) {
    return VideoEditHistoryCompanion(
      id: id ?? this.id,
      archiveId: archiveId ?? this.archiveId,
      videoPath: videoPath ?? this.videoPath,
      editConfigJson: editConfigJson ?? this.editConfigJson,
      editedAt: editedAt ?? this.editedAt,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (archiveId.present) {
      map['archive_id'] = Variable<int>(archiveId.value);
    }
    if (videoPath.present) {
      map['video_path'] = Variable<String>(videoPath.value);
    }
    if (editConfigJson.present) {
      map['edit_config_json'] = Variable<String>(editConfigJson.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoEditHistoryCompanion(')
          ..write('id: $id, ')
          ..write('archiveId: $archiveId, ')
          ..write('videoPath: $videoPath, ')
          ..write('editConfigJson: $editConfigJson, ')
          ..write('editedAt: $editedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideoArchivesTable videoArchives = $VideoArchivesTable(this);
  late final $VideoGpsPointsTable videoGpsPoints = $VideoGpsPointsTable(this);
  late final $VideoEditHistoryTable videoEditHistory =
      $VideoEditHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [videoArchives, videoGpsPoints, videoEditHistory];
}

typedef $$VideoArchivesTableCreateCompanionBuilder = VideoArchivesCompanion
    Function({
  Value<int> id,
  required String title,
  required String videoPath,
  Value<String?> thumbnailPath,
  required DateTime createdAt,
  required DateTime updatedAt,
  required int durationSeconds,
  Value<int> gpsPointCount,
  required String originalVideoPath,
  Value<int> editCount,
  Value<String?> lastEditConfigJson,
});
typedef $$VideoArchivesTableUpdateCompanionBuilder = VideoArchivesCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> videoPath,
  Value<String?> thumbnailPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> durationSeconds,
  Value<int> gpsPointCount,
  Value<String> originalVideoPath,
  Value<int> editCount,
  Value<String?> lastEditConfigJson,
});

final class $$VideoArchivesTableReferences
    extends BaseReferences<_$AppDatabase, $VideoArchivesTable, VideoArchive> {
  $$VideoArchivesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VideoGpsPointsTable, List<VideoGpsPoint>>
      _videoGpsPointsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.videoGpsPoints,
              aliasName: $_aliasNameGenerator(
                  db.videoArchives.id, db.videoGpsPoints.archiveId));

  $$VideoGpsPointsTableProcessedTableManager get videoGpsPointsRefs {
    final manager = $$VideoGpsPointsTableTableManager($_db, $_db.videoGpsPoints)
        .filter((f) => f.archiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_videoGpsPointsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VideoEditHistoryTable, List<VideoEditHistoryData>>
      _videoEditHistoryRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.videoEditHistory,
              aliasName: $_aliasNameGenerator(
                  db.videoArchives.id, db.videoEditHistory.archiveId));

  $$VideoEditHistoryTableProcessedTableManager get videoEditHistoryRefs {
    final manager =
        $$VideoEditHistoryTableTableManager($_db, $_db.videoEditHistory)
            .filter((f) => f.archiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_videoEditHistoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VideoArchivesTableFilterComposer
    extends Composer<_$AppDatabase, $VideoArchivesTable> {
  $$VideoArchivesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gpsPointCount => $composableBuilder(
      column: $table.gpsPointCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalVideoPath => $composableBuilder(
      column: $table.originalVideoPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get editCount => $composableBuilder(
      column: $table.editCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastEditConfigJson => $composableBuilder(
      column: $table.lastEditConfigJson,
      builder: (column) => ColumnFilters(column));

  Expression<bool> videoGpsPointsRefs(
      Expression<bool> Function($$VideoGpsPointsTableFilterComposer f) f) {
    final $$VideoGpsPointsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.videoGpsPoints,
        getReferencedColumn: (t) => t.archiveId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoGpsPointsTableFilterComposer(
              $db: $db,
              $table: $db.videoGpsPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> videoEditHistoryRefs(
      Expression<bool> Function($$VideoEditHistoryTableFilterComposer f) f) {
    final $$VideoEditHistoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.videoEditHistory,
        getReferencedColumn: (t) => t.archiveId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoEditHistoryTableFilterComposer(
              $db: $db,
              $table: $db.videoEditHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VideoArchivesTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoArchivesTable> {
  $$VideoArchivesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gpsPointCount => $composableBuilder(
      column: $table.gpsPointCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalVideoPath => $composableBuilder(
      column: $table.originalVideoPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get editCount => $composableBuilder(
      column: $table.editCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastEditConfigJson => $composableBuilder(
      column: $table.lastEditConfigJson,
      builder: (column) => ColumnOrderings(column));
}

class $$VideoArchivesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoArchivesTable> {
  $$VideoArchivesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get videoPath =>
      $composableBuilder(column: $table.videoPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get gpsPointCount => $composableBuilder(
      column: $table.gpsPointCount, builder: (column) => column);

  GeneratedColumn<String> get originalVideoPath => $composableBuilder(
      column: $table.originalVideoPath, builder: (column) => column);

  GeneratedColumn<int> get editCount =>
      $composableBuilder(column: $table.editCount, builder: (column) => column);

  GeneratedColumn<String> get lastEditConfigJson => $composableBuilder(
      column: $table.lastEditConfigJson, builder: (column) => column);

  Expression<T> videoGpsPointsRefs<T extends Object>(
      Expression<T> Function($$VideoGpsPointsTableAnnotationComposer a) f) {
    final $$VideoGpsPointsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.videoGpsPoints,
        getReferencedColumn: (t) => t.archiveId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoGpsPointsTableAnnotationComposer(
              $db: $db,
              $table: $db.videoGpsPoints,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> videoEditHistoryRefs<T extends Object>(
      Expression<T> Function($$VideoEditHistoryTableAnnotationComposer a) f) {
    final $$VideoEditHistoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.videoEditHistory,
        getReferencedColumn: (t) => t.archiveId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoEditHistoryTableAnnotationComposer(
              $db: $db,
              $table: $db.videoEditHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VideoArchivesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideoArchivesTable,
    VideoArchive,
    $$VideoArchivesTableFilterComposer,
    $$VideoArchivesTableOrderingComposer,
    $$VideoArchivesTableAnnotationComposer,
    $$VideoArchivesTableCreateCompanionBuilder,
    $$VideoArchivesTableUpdateCompanionBuilder,
    (VideoArchive, $$VideoArchivesTableReferences),
    VideoArchive,
    PrefetchHooks Function(
        {bool videoGpsPointsRefs, bool videoEditHistoryRefs})> {
  $$VideoArchivesTableTableManager(_$AppDatabase db, $VideoArchivesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoArchivesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoArchivesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoArchivesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> videoPath = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> gpsPointCount = const Value.absent(),
            Value<String> originalVideoPath = const Value.absent(),
            Value<int> editCount = const Value.absent(),
            Value<String?> lastEditConfigJson = const Value.absent(),
          }) =>
              VideoArchivesCompanion(
            id: id,
            title: title,
            videoPath: videoPath,
            thumbnailPath: thumbnailPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            durationSeconds: durationSeconds,
            gpsPointCount: gpsPointCount,
            originalVideoPath: originalVideoPath,
            editCount: editCount,
            lastEditConfigJson: lastEditConfigJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String videoPath,
            Value<String?> thumbnailPath = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            required int durationSeconds,
            Value<int> gpsPointCount = const Value.absent(),
            required String originalVideoPath,
            Value<int> editCount = const Value.absent(),
            Value<String?> lastEditConfigJson = const Value.absent(),
          }) =>
              VideoArchivesCompanion.insert(
            id: id,
            title: title,
            videoPath: videoPath,
            thumbnailPath: thumbnailPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            durationSeconds: durationSeconds,
            gpsPointCount: gpsPointCount,
            originalVideoPath: originalVideoPath,
            editCount: editCount,
            lastEditConfigJson: lastEditConfigJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VideoArchivesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {videoGpsPointsRefs = false, videoEditHistoryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (videoGpsPointsRefs) db.videoGpsPoints,
                if (videoEditHistoryRefs) db.videoEditHistory
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (videoGpsPointsRefs)
                    await $_getPrefetchedData<VideoArchive, $VideoArchivesTable,
                            VideoGpsPoint>(
                        currentTable: table,
                        referencedTable: $$VideoArchivesTableReferences
                            ._videoGpsPointsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VideoArchivesTableReferences(db, table, p0)
                                .videoGpsPointsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.archiveId == item.id),
                        typedResults: items),
                  if (videoEditHistoryRefs)
                    await $_getPrefetchedData<VideoArchive, $VideoArchivesTable,
                            VideoEditHistoryData>(
                        currentTable: table,
                        referencedTable: $$VideoArchivesTableReferences
                            ._videoEditHistoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VideoArchivesTableReferences(db, table, p0)
                                .videoEditHistoryRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.archiveId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VideoArchivesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideoArchivesTable,
    VideoArchive,
    $$VideoArchivesTableFilterComposer,
    $$VideoArchivesTableOrderingComposer,
    $$VideoArchivesTableAnnotationComposer,
    $$VideoArchivesTableCreateCompanionBuilder,
    $$VideoArchivesTableUpdateCompanionBuilder,
    (VideoArchive, $$VideoArchivesTableReferences),
    VideoArchive,
    PrefetchHooks Function(
        {bool videoGpsPointsRefs, bool videoEditHistoryRefs})>;
typedef $$VideoGpsPointsTableCreateCompanionBuilder = VideoGpsPointsCompanion
    Function({
  Value<int> id,
  required int archiveId,
  required double latitude,
  required double longitude,
  Value<double?> altitude,
  required DateTime capturedAt,
  required String photoAssetId,
  required int orderIndex,
});
typedef $$VideoGpsPointsTableUpdateCompanionBuilder = VideoGpsPointsCompanion
    Function({
  Value<int> id,
  Value<int> archiveId,
  Value<double> latitude,
  Value<double> longitude,
  Value<double?> altitude,
  Value<DateTime> capturedAt,
  Value<String> photoAssetId,
  Value<int> orderIndex,
});

final class $$VideoGpsPointsTableReferences
    extends BaseReferences<_$AppDatabase, $VideoGpsPointsTable, VideoGpsPoint> {
  $$VideoGpsPointsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $VideoArchivesTable _archiveIdTable(_$AppDatabase db) =>
      db.videoArchives.createAlias($_aliasNameGenerator(
          db.videoGpsPoints.archiveId, db.videoArchives.id));

  $$VideoArchivesTableProcessedTableManager get archiveId {
    final $_column = $_itemColumn<int>('archive_id')!;

    final manager = $$VideoArchivesTableTableManager($_db, $_db.videoArchives)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_archiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VideoGpsPointsTableFilterComposer
    extends Composer<_$AppDatabase, $VideoGpsPointsTable> {
  $$VideoGpsPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoAssetId => $composableBuilder(
      column: $table.photoAssetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$VideoArchivesTableFilterComposer get archiveId {
    final $$VideoArchivesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.archiveId,
        referencedTable: $db.videoArchives,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoArchivesTableFilterComposer(
              $db: $db,
              $table: $db.videoArchives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VideoGpsPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoGpsPointsTable> {
  $$VideoGpsPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoAssetId => $composableBuilder(
      column: $table.photoAssetId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$VideoArchivesTableOrderingComposer get archiveId {
    final $$VideoArchivesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.archiveId,
        referencedTable: $db.videoArchives,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoArchivesTableOrderingComposer(
              $db: $db,
              $table: $db.videoArchives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VideoGpsPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoGpsPointsTable> {
  $$VideoGpsPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get photoAssetId => $composableBuilder(
      column: $table.photoAssetId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$VideoArchivesTableAnnotationComposer get archiveId {
    final $$VideoArchivesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.archiveId,
        referencedTable: $db.videoArchives,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoArchivesTableAnnotationComposer(
              $db: $db,
              $table: $db.videoArchives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VideoGpsPointsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideoGpsPointsTable,
    VideoGpsPoint,
    $$VideoGpsPointsTableFilterComposer,
    $$VideoGpsPointsTableOrderingComposer,
    $$VideoGpsPointsTableAnnotationComposer,
    $$VideoGpsPointsTableCreateCompanionBuilder,
    $$VideoGpsPointsTableUpdateCompanionBuilder,
    (VideoGpsPoint, $$VideoGpsPointsTableReferences),
    VideoGpsPoint,
    PrefetchHooks Function({bool archiveId})> {
  $$VideoGpsPointsTableTableManager(
      _$AppDatabase db, $VideoGpsPointsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoGpsPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoGpsPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoGpsPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> archiveId = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double?> altitude = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<String> photoAssetId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              VideoGpsPointsCompanion(
            id: id,
            archiveId: archiveId,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            capturedAt: capturedAt,
            photoAssetId: photoAssetId,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int archiveId,
            required double latitude,
            required double longitude,
            Value<double?> altitude = const Value.absent(),
            required DateTime capturedAt,
            required String photoAssetId,
            required int orderIndex,
          }) =>
              VideoGpsPointsCompanion.insert(
            id: id,
            archiveId: archiveId,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            capturedAt: capturedAt,
            photoAssetId: photoAssetId,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VideoGpsPointsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({archiveId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (archiveId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.archiveId,
                    referencedTable:
                        $$VideoGpsPointsTableReferences._archiveIdTable(db),
                    referencedColumn:
                        $$VideoGpsPointsTableReferences._archiveIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VideoGpsPointsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideoGpsPointsTable,
    VideoGpsPoint,
    $$VideoGpsPointsTableFilterComposer,
    $$VideoGpsPointsTableOrderingComposer,
    $$VideoGpsPointsTableAnnotationComposer,
    $$VideoGpsPointsTableCreateCompanionBuilder,
    $$VideoGpsPointsTableUpdateCompanionBuilder,
    (VideoGpsPoint, $$VideoGpsPointsTableReferences),
    VideoGpsPoint,
    PrefetchHooks Function({bool archiveId})>;
typedef $$VideoEditHistoryTableCreateCompanionBuilder
    = VideoEditHistoryCompanion Function({
  Value<int> id,
  required int archiveId,
  required String videoPath,
  required String editConfigJson,
  required DateTime editedAt,
  required int version,
});
typedef $$VideoEditHistoryTableUpdateCompanionBuilder
    = VideoEditHistoryCompanion Function({
  Value<int> id,
  Value<int> archiveId,
  Value<String> videoPath,
  Value<String> editConfigJson,
  Value<DateTime> editedAt,
  Value<int> version,
});

final class $$VideoEditHistoryTableReferences extends BaseReferences<
    _$AppDatabase, $VideoEditHistoryTable, VideoEditHistoryData> {
  $$VideoEditHistoryTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $VideoArchivesTable _archiveIdTable(_$AppDatabase db) =>
      db.videoArchives.createAlias($_aliasNameGenerator(
          db.videoEditHistory.archiveId, db.videoArchives.id));

  $$VideoArchivesTableProcessedTableManager get archiveId {
    final $_column = $_itemColumn<int>('archive_id')!;

    final manager = $$VideoArchivesTableTableManager($_db, $_db.videoArchives)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_archiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VideoEditHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $VideoEditHistoryTable> {
  $$VideoEditHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editConfigJson => $composableBuilder(
      column: $table.editConfigJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
      column: $table.editedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  $$VideoArchivesTableFilterComposer get archiveId {
    final $$VideoArchivesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.archiveId,
        referencedTable: $db.videoArchives,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoArchivesTableFilterComposer(
              $db: $db,
              $table: $db.videoArchives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VideoEditHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoEditHistoryTable> {
  $$VideoEditHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoPath => $composableBuilder(
      column: $table.videoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editConfigJson => $composableBuilder(
      column: $table.editConfigJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
      column: $table.editedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  $$VideoArchivesTableOrderingComposer get archiveId {
    final $$VideoArchivesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.archiveId,
        referencedTable: $db.videoArchives,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoArchivesTableOrderingComposer(
              $db: $db,
              $table: $db.videoArchives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VideoEditHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoEditHistoryTable> {
  $$VideoEditHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoPath =>
      $composableBuilder(column: $table.videoPath, builder: (column) => column);

  GeneratedColumn<String> get editConfigJson => $composableBuilder(
      column: $table.editConfigJson, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  $$VideoArchivesTableAnnotationComposer get archiveId {
    final $$VideoArchivesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.archiveId,
        referencedTable: $db.videoArchives,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VideoArchivesTableAnnotationComposer(
              $db: $db,
              $table: $db.videoArchives,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VideoEditHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideoEditHistoryTable,
    VideoEditHistoryData,
    $$VideoEditHistoryTableFilterComposer,
    $$VideoEditHistoryTableOrderingComposer,
    $$VideoEditHistoryTableAnnotationComposer,
    $$VideoEditHistoryTableCreateCompanionBuilder,
    $$VideoEditHistoryTableUpdateCompanionBuilder,
    (VideoEditHistoryData, $$VideoEditHistoryTableReferences),
    VideoEditHistoryData,
    PrefetchHooks Function({bool archiveId})> {
  $$VideoEditHistoryTableTableManager(
      _$AppDatabase db, $VideoEditHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoEditHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoEditHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoEditHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> archiveId = const Value.absent(),
            Value<String> videoPath = const Value.absent(),
            Value<String> editConfigJson = const Value.absent(),
            Value<DateTime> editedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
          }) =>
              VideoEditHistoryCompanion(
            id: id,
            archiveId: archiveId,
            videoPath: videoPath,
            editConfigJson: editConfigJson,
            editedAt: editedAt,
            version: version,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int archiveId,
            required String videoPath,
            required String editConfigJson,
            required DateTime editedAt,
            required int version,
          }) =>
              VideoEditHistoryCompanion.insert(
            id: id,
            archiveId: archiveId,
            videoPath: videoPath,
            editConfigJson: editConfigJson,
            editedAt: editedAt,
            version: version,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VideoEditHistoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({archiveId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (archiveId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.archiveId,
                    referencedTable:
                        $$VideoEditHistoryTableReferences._archiveIdTable(db),
                    referencedColumn: $$VideoEditHistoryTableReferences
                        ._archiveIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VideoEditHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideoEditHistoryTable,
    VideoEditHistoryData,
    $$VideoEditHistoryTableFilterComposer,
    $$VideoEditHistoryTableOrderingComposer,
    $$VideoEditHistoryTableAnnotationComposer,
    $$VideoEditHistoryTableCreateCompanionBuilder,
    $$VideoEditHistoryTableUpdateCompanionBuilder,
    (VideoEditHistoryData, $$VideoEditHistoryTableReferences),
    VideoEditHistoryData,
    PrefetchHooks Function({bool archiveId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideoArchivesTableTableManager get videoArchives =>
      $$VideoArchivesTableTableManager(_db, _db.videoArchives);
  $$VideoGpsPointsTableTableManager get videoGpsPoints =>
      $$VideoGpsPointsTableTableManager(_db, _db.videoGpsPoints);
  $$VideoEditHistoryTableTableManager get videoEditHistory =>
      $$VideoEditHistoryTableTableManager(_db, _db.videoEditHistory);
}
