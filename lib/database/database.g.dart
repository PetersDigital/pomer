// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _phaseTypeMeta =
      const VerificationMeta('phaseType');
  @override
  late final GeneratedColumn<String> phaseType = GeneratedColumn<String>(
      'phase_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, startTime, endTime, durationSeconds, phaseType, status, taskId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('phase_type')) {
      context.handle(_phaseTypeMeta,
          phaseType.isAcceptableOrUnknown(data['phase_type']!, _phaseTypeMeta));
    } else if (isInserting) {
      context.missing(_phaseTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      phaseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phase_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String phaseType;
  final String status;
  final String? taskId;
  const Session(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.durationSeconds,
      required this.phaseType,
      required this.status,
      this.taskId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['phase_type'] = Variable<String>(phaseType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationSeconds: Value(durationSeconds),
      phaseType: Value(phaseType),
      status: Value(status),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      phaseType: serializer.fromJson<String>(json['phaseType']),
      status: serializer.fromJson<String>(json['status']),
      taskId: serializer.fromJson<String?>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'phaseType': serializer.toJson<String>(phaseType),
      'status': serializer.toJson<String>(status),
      'taskId': serializer.toJson<String?>(taskId),
    };
  }

  Session copyWith(
          {int? id,
          DateTime? startTime,
          DateTime? endTime,
          int? durationSeconds,
          String? phaseType,
          String? status,
          Value<String?> taskId = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        phaseType: phaseType ?? this.phaseType,
        status: status ?? this.status,
        taskId: taskId.present ? taskId.value : this.taskId,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      phaseType: data.phaseType.present ? data.phaseType.value : this.phaseType,
      status: data.status.present ? data.status.value : this.status,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('phaseType: $phaseType, ')
          ..write('status: $status, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, startTime, endTime, durationSeconds, phaseType, status, taskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds &&
          other.phaseType == this.phaseType &&
          other.status == this.status &&
          other.taskId == this.taskId);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> durationSeconds;
  final Value<String> phaseType;
  final Value<String> status;
  final Value<String?> taskId;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.phaseType = const Value.absent(),
    this.status = const Value.absent(),
    this.taskId = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startTime,
    required DateTime endTime,
    required int durationSeconds,
    required String phaseType,
    required String status,
    this.taskId = const Value.absent(),
  })  : startTime = Value(startTime),
        endTime = Value(endTime),
        durationSeconds = Value(durationSeconds),
        phaseType = Value(phaseType),
        status = Value(status);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<String>? phaseType,
    Expression<String>? status,
    Expression<String>? taskId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (phaseType != null) 'phase_type': phaseType,
      if (status != null) 'status': status,
      if (taskId != null) 'task_id': taskId,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<int>? durationSeconds,
      Value<String>? phaseType,
      Value<String>? status,
      Value<String?>? taskId}) {
    return SessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      phaseType: phaseType ?? this.phaseType,
      status: status ?? this.status,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (phaseType.present) {
      map['phase_type'] = Variable<String>(phaseType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('phaseType: $phaseType, ')
          ..write('status: $status, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => const Uuid().v4());
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, tag, isCompleted, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
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
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String? tag;
  final bool isCompleted;
  final DateTime createdAt;
  const Task(
      {required this.id,
      required this.title,
      this.tag,
      required this.isCompleted,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      tag: serializer.fromJson<String?>(json['tag']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'tag': serializer.toJson<String?>(tag),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith(
          {String? id,
          String? title,
          Value<String?> tag = const Value.absent(),
          bool? isCompleted,
          DateTime? createdAt}) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        tag: tag.present ? tag.value : this.tag,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      tag: data.tag.present ? data.tag.value : this.tag,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('tag: $tag, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, tag, isCompleted, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.tag == this.tag &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> tag;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.tag = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.tag = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? tag,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (tag != null) 'tag': tag,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? tag,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('tag: $tag, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantCatalogTable extends PlantCatalog
    with TableInfo<$PlantCatalogTable, PlantCatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantCatalogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
      'tier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, emoji, name, tier];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_catalog';
  @override
  VerificationContext validateIntegrity(Insertable<PlantCatalogItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
          _tierMeta, tier.isAcceptableOrUnknown(data['tier']!, _tierMeta));
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantCatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantCatalogItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tier'])!,
    );
  }

  @override
  $PlantCatalogTable createAlias(String alias) {
    return $PlantCatalogTable(attachedDatabase, alias);
  }
}

class PlantCatalogItem extends DataClass
    implements Insertable<PlantCatalogItem> {
  final int id;
  final String emoji;
  final String name;
  final String tier;
  const PlantCatalogItem(
      {required this.id,
      required this.emoji,
      required this.name,
      required this.tier});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['emoji'] = Variable<String>(emoji);
    map['name'] = Variable<String>(name);
    map['tier'] = Variable<String>(tier);
    return map;
  }

  PlantCatalogCompanion toCompanion(bool nullToAbsent) {
    return PlantCatalogCompanion(
      id: Value(id),
      emoji: Value(emoji),
      name: Value(name),
      tier: Value(tier),
    );
  }

  factory PlantCatalogItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantCatalogItem(
      id: serializer.fromJson<int>(json['id']),
      emoji: serializer.fromJson<String>(json['emoji']),
      name: serializer.fromJson<String>(json['name']),
      tier: serializer.fromJson<String>(json['tier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'emoji': serializer.toJson<String>(emoji),
      'name': serializer.toJson<String>(name),
      'tier': serializer.toJson<String>(tier),
    };
  }

  PlantCatalogItem copyWith(
          {int? id, String? emoji, String? name, String? tier}) =>
      PlantCatalogItem(
        id: id ?? this.id,
        emoji: emoji ?? this.emoji,
        name: name ?? this.name,
        tier: tier ?? this.tier,
      );
  PlantCatalogItem copyWithCompanion(PlantCatalogCompanion data) {
    return PlantCatalogItem(
      id: data.id.present ? data.id.value : this.id,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      name: data.name.present ? data.name.value : this.name,
      tier: data.tier.present ? data.tier.value : this.tier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantCatalogItem(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('name: $name, ')
          ..write('tier: $tier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, emoji, name, tier);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantCatalogItem &&
          other.id == this.id &&
          other.emoji == this.emoji &&
          other.name == this.name &&
          other.tier == this.tier);
}

class PlantCatalogCompanion extends UpdateCompanion<PlantCatalogItem> {
  final Value<int> id;
  final Value<String> emoji;
  final Value<String> name;
  final Value<String> tier;
  const PlantCatalogCompanion({
    this.id = const Value.absent(),
    this.emoji = const Value.absent(),
    this.name = const Value.absent(),
    this.tier = const Value.absent(),
  });
  PlantCatalogCompanion.insert({
    this.id = const Value.absent(),
    required String emoji,
    required String name,
    required String tier,
  })  : emoji = Value(emoji),
        name = Value(name),
        tier = Value(tier);
  static Insertable<PlantCatalogItem> custom({
    Expression<int>? id,
    Expression<String>? emoji,
    Expression<String>? name,
    Expression<String>? tier,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emoji != null) 'emoji': emoji,
      if (name != null) 'name': name,
      if (tier != null) 'tier': tier,
    });
  }

  PlantCatalogCompanion copyWith(
      {Value<int>? id,
      Value<String>? emoji,
      Value<String>? name,
      Value<String>? tier}) {
    return PlantCatalogCompanion(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      tier: tier ?? this.tier,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantCatalogCompanion(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('name: $name, ')
          ..write('tier: $tier')
          ..write(')'))
        .toString();
  }
}

class $UserGardenTable extends UserGarden
    with TableInfo<$UserGardenTable, UserGardenItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGardenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _plantIdMeta =
      const VerificationMeta('plantId');
  @override
  late final GeneratedColumn<int> plantId = GeneratedColumn<int>(
      'plant_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plant_catalog (id)'));
  static const VerificationMeta _earnedAtMeta =
      const VerificationMeta('earnedAt');
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
      'earned_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, plantId, earnedAt, durationMinutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_garden';
  @override
  VerificationContext validateIntegrity(Insertable<UserGardenItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plant_id')) {
      context.handle(_plantIdMeta,
          plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta));
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(_earnedAtMeta,
          earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGardenItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGardenItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      plantId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plant_id'])!,
      earnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}earned_at'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
    );
  }

  @override
  $UserGardenTable createAlias(String alias) {
    return $UserGardenTable(attachedDatabase, alias);
  }
}

class UserGardenItem extends DataClass implements Insertable<UserGardenItem> {
  final int id;
  final int plantId;
  final DateTime earnedAt;
  final int durationMinutes;
  const UserGardenItem(
      {required this.id,
      required this.plantId,
      required this.earnedAt,
      required this.durationMinutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plant_id'] = Variable<int>(plantId);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    return map;
  }

  UserGardenCompanion toCompanion(bool nullToAbsent) {
    return UserGardenCompanion(
      id: Value(id),
      plantId: Value(plantId),
      earnedAt: Value(earnedAt),
      durationMinutes: Value(durationMinutes),
    );
  }

  factory UserGardenItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGardenItem(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<int>(json['plantId']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<int>(plantId),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
    };
  }

  UserGardenItem copyWith(
          {int? id, int? plantId, DateTime? earnedAt, int? durationMinutes}) =>
      UserGardenItem(
        id: id ?? this.id,
        plantId: plantId ?? this.plantId,
        earnedAt: earnedAt ?? this.earnedAt,
        durationMinutes: durationMinutes ?? this.durationMinutes,
      );
  UserGardenItem copyWithCompanion(UserGardenCompanion data) {
    return UserGardenItem(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGardenItem(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('durationMinutes: $durationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, earnedAt, durationMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGardenItem &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.earnedAt == this.earnedAt &&
          other.durationMinutes == this.durationMinutes);
}

class UserGardenCompanion extends UpdateCompanion<UserGardenItem> {
  final Value<int> id;
  final Value<int> plantId;
  final Value<DateTime> earnedAt;
  final Value<int> durationMinutes;
  const UserGardenCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
  });
  UserGardenCompanion.insert({
    this.id = const Value.absent(),
    required int plantId,
    this.earnedAt = const Value.absent(),
    required int durationMinutes,
  })  : plantId = Value(plantId),
        durationMinutes = Value(durationMinutes);
  static Insertable<UserGardenItem> custom({
    Expression<int>? id,
    Expression<int>? plantId,
    Expression<DateTime>? earnedAt,
    Expression<int>? durationMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
    });
  }

  UserGardenCompanion copyWith(
      {Value<int>? id,
      Value<int>? plantId,
      Value<DateTime>? earnedAt,
      Value<int>? durationMinutes}) {
    return UserGardenCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      earnedAt: earnedAt ?? this.earnedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<int>(plantId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGardenCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('durationMinutes: $durationMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $PlantCatalogTable plantCatalog = $PlantCatalogTable(this);
  late final $UserGardenTable userGarden = $UserGardenTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sessions, tasks, plantCatalog, userGarden];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required DateTime startTime,
  required DateTime endTime,
  required int durationSeconds,
  required String phaseType,
  required String status,
  Value<String?> taskId,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<int> durationSeconds,
  Value<String> phaseType,
  Value<String> status,
  Value<String?> taskId,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phaseType => $composableBuilder(
      column: $table.phaseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phaseType => $composableBuilder(
      column: $table.phaseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get phaseType =>
      $composableBuilder(column: $table.phaseType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String> phaseType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> taskId = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            phaseType: phaseType,
            status: status,
            taskId: taskId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime startTime,
            required DateTime endTime,
            required int durationSeconds,
            required String phaseType,
            required String status,
            Value<String?> taskId = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            phaseType: phaseType,
            status: status,
            taskId: taskId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  required String title,
  Value<String?> tag,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> tag,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> tag = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            tag: tag,
            isCompleted: isCompleted,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String title,
            Value<String?> tag = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            tag: tag,
            isCompleted: isCompleted,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()>;
typedef $$PlantCatalogTableCreateCompanionBuilder = PlantCatalogCompanion
    Function({
  Value<int> id,
  required String emoji,
  required String name,
  required String tier,
});
typedef $$PlantCatalogTableUpdateCompanionBuilder = PlantCatalogCompanion
    Function({
  Value<int> id,
  Value<String> emoji,
  Value<String> name,
  Value<String> tier,
});

final class $$PlantCatalogTableReferences extends BaseReferences<_$AppDatabase,
    $PlantCatalogTable, PlantCatalogItem> {
  $$PlantCatalogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserGardenTable, List<UserGardenItem>>
      _userGardenRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.userGarden,
          aliasName:
              $_aliasNameGenerator(db.plantCatalog.id, db.userGarden.plantId));

  $$UserGardenTableProcessedTableManager get userGardenRefs {
    final manager = $$UserGardenTableTableManager($_db, $_db.userGarden)
        .filter((f) => f.plantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userGardenRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlantCatalogTableFilterComposer
    extends Composer<_$AppDatabase, $PlantCatalogTable> {
  $$PlantCatalogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tier => $composableBuilder(
      column: $table.tier, builder: (column) => ColumnFilters(column));

  Expression<bool> userGardenRefs(
      Expression<bool> Function($$UserGardenTableFilterComposer f) f) {
    final $$UserGardenTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userGarden,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserGardenTableFilterComposer(
              $db: $db,
              $table: $db.userGarden,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlantCatalogTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantCatalogTable> {
  $$PlantCatalogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tier => $composableBuilder(
      column: $table.tier, builder: (column) => ColumnOrderings(column));
}

class $$PlantCatalogTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantCatalogTable> {
  $$PlantCatalogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  Expression<T> userGardenRefs<T extends Object>(
      Expression<T> Function($$UserGardenTableAnnotationComposer a) f) {
    final $$UserGardenTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userGarden,
        getReferencedColumn: (t) => t.plantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserGardenTableAnnotationComposer(
              $db: $db,
              $table: $db.userGarden,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlantCatalogTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlantCatalogTable,
    PlantCatalogItem,
    $$PlantCatalogTableFilterComposer,
    $$PlantCatalogTableOrderingComposer,
    $$PlantCatalogTableAnnotationComposer,
    $$PlantCatalogTableCreateCompanionBuilder,
    $$PlantCatalogTableUpdateCompanionBuilder,
    (PlantCatalogItem, $$PlantCatalogTableReferences),
    PlantCatalogItem,
    PrefetchHooks Function({bool userGardenRefs})> {
  $$PlantCatalogTableTableManager(_$AppDatabase db, $PlantCatalogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantCatalogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantCatalogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantCatalogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> tier = const Value.absent(),
          }) =>
              PlantCatalogCompanion(
            id: id,
            emoji: emoji,
            name: name,
            tier: tier,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String emoji,
            required String name,
            required String tier,
          }) =>
              PlantCatalogCompanion.insert(
            id: id,
            emoji: emoji,
            name: name,
            tier: tier,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlantCatalogTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userGardenRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userGardenRefs) db.userGarden],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userGardenRefs)
                    await $_getPrefetchedData<PlantCatalogItem,
                            $PlantCatalogTable, UserGardenItem>(
                        currentTable: table,
                        referencedTable: $$PlantCatalogTableReferences
                            ._userGardenRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlantCatalogTableReferences(db, table, p0)
                                .userGardenRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.plantId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlantCatalogTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlantCatalogTable,
    PlantCatalogItem,
    $$PlantCatalogTableFilterComposer,
    $$PlantCatalogTableOrderingComposer,
    $$PlantCatalogTableAnnotationComposer,
    $$PlantCatalogTableCreateCompanionBuilder,
    $$PlantCatalogTableUpdateCompanionBuilder,
    (PlantCatalogItem, $$PlantCatalogTableReferences),
    PlantCatalogItem,
    PrefetchHooks Function({bool userGardenRefs})>;
typedef $$UserGardenTableCreateCompanionBuilder = UserGardenCompanion Function({
  Value<int> id,
  required int plantId,
  Value<DateTime> earnedAt,
  required int durationMinutes,
});
typedef $$UserGardenTableUpdateCompanionBuilder = UserGardenCompanion Function({
  Value<int> id,
  Value<int> plantId,
  Value<DateTime> earnedAt,
  Value<int> durationMinutes,
});

final class $$UserGardenTableReferences
    extends BaseReferences<_$AppDatabase, $UserGardenTable, UserGardenItem> {
  $$UserGardenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlantCatalogTable _plantIdTable(_$AppDatabase db) =>
      db.plantCatalog.createAlias(
          $_aliasNameGenerator(db.userGarden.plantId, db.plantCatalog.id));

  $$PlantCatalogTableProcessedTableManager get plantId {
    final $_column = $_itemColumn<int>('plant_id')!;

    final manager = $$PlantCatalogTableTableManager($_db, $_db.plantCatalog)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserGardenTableFilterComposer
    extends Composer<_$AppDatabase, $UserGardenTable> {
  $$UserGardenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  $$PlantCatalogTableFilterComposer get plantId {
    final $$PlantCatalogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.plantCatalog,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantCatalogTableFilterComposer(
              $db: $db,
              $table: $db.plantCatalog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserGardenTableOrderingComposer
    extends Composer<_$AppDatabase, $UserGardenTable> {
  $$UserGardenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  $$PlantCatalogTableOrderingComposer get plantId {
    final $$PlantCatalogTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.plantCatalog,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantCatalogTableOrderingComposer(
              $db: $db,
              $table: $db.plantCatalog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserGardenTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserGardenTable> {
  $$UserGardenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  $$PlantCatalogTableAnnotationComposer get plantId {
    final $$PlantCatalogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.plantId,
        referencedTable: $db.plantCatalog,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlantCatalogTableAnnotationComposer(
              $db: $db,
              $table: $db.plantCatalog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserGardenTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserGardenTable,
    UserGardenItem,
    $$UserGardenTableFilterComposer,
    $$UserGardenTableOrderingComposer,
    $$UserGardenTableAnnotationComposer,
    $$UserGardenTableCreateCompanionBuilder,
    $$UserGardenTableUpdateCompanionBuilder,
    (UserGardenItem, $$UserGardenTableReferences),
    UserGardenItem,
    PrefetchHooks Function({bool plantId})> {
  $$UserGardenTableTableManager(_$AppDatabase db, $UserGardenTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGardenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGardenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGardenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> plantId = const Value.absent(),
            Value<DateTime> earnedAt = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
          }) =>
              UserGardenCompanion(
            id: id,
            plantId: plantId,
            earnedAt: earnedAt,
            durationMinutes: durationMinutes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int plantId,
            Value<DateTime> earnedAt = const Value.absent(),
            required int durationMinutes,
          }) =>
              UserGardenCompanion.insert(
            id: id,
            plantId: plantId,
            earnedAt: earnedAt,
            durationMinutes: durationMinutes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserGardenTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({plantId = false}) {
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
                if (plantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.plantId,
                    referencedTable:
                        $$UserGardenTableReferences._plantIdTable(db),
                    referencedColumn:
                        $$UserGardenTableReferences._plantIdTable(db).id,
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

typedef $$UserGardenTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserGardenTable,
    UserGardenItem,
    $$UserGardenTableFilterComposer,
    $$UserGardenTableOrderingComposer,
    $$UserGardenTableAnnotationComposer,
    $$UserGardenTableCreateCompanionBuilder,
    $$UserGardenTableUpdateCompanionBuilder,
    (UserGardenItem, $$UserGardenTableReferences),
    UserGardenItem,
    PrefetchHooks Function({bool plantId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$PlantCatalogTableTableManager get plantCatalog =>
      $$PlantCatalogTableTableManager(_db, _db.plantCatalog);
  $$UserGardenTableTableManager get userGarden =>
      $$UserGardenTableTableManager(_db, _db.userGarden);
}
