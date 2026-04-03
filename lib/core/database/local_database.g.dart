// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalStudentsTable extends LocalStudents
    with TableInfo<$LocalStudentsTable, LocalStudent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _classNameMeta =
      const VerificationMeta('className');
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
      'class_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fatherNameMeta =
      const VerificationMeta('fatherName');
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
      'father_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _altNumberMeta =
      const VerificationMeta('altNumber');
  @override
  late final GeneratedColumn<String> altNumber = GeneratedColumn<String>(
      'alt_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<String> dob = GeneratedColumn<String>(
      'dob', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _admissionDateMeta =
      const VerificationMeta('admissionDate');
  @override
  late final GeneratedColumn<String> admissionDate = GeneratedColumn<String>(
      'admission_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Active'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        className,
        fatherName,
        phoneNumber,
        altNumber,
        dob,
        admissionDate,
        status,
        lastUpdated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_students';
  @override
  VerificationContext validateIntegrity(Insertable<LocalStudent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('class_name')) {
      context.handle(_classNameMeta,
          className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta));
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
          _fatherNameMeta,
          fatherName.isAcceptableOrUnknown(
              data['father_name']!, _fatherNameMeta));
    } else if (isInserting) {
      context.missing(_fatherNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('alt_number')) {
      context.handle(_altNumberMeta,
          altNumber.isAcceptableOrUnknown(data['alt_number']!, _altNumberMeta));
    }
    if (data.containsKey('dob')) {
      context.handle(
          _dobMeta, dob.isAcceptableOrUnknown(data['dob']!, _dobMeta));
    }
    if (data.containsKey('admission_date')) {
      context.handle(
          _admissionDateMeta,
          admissionDate.isAcceptableOrUnknown(
              data['admission_date']!, _admissionDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStudent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      className: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}class_name'])!,
      fatherName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}father_name'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      altNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alt_number']),
      dob: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dob']),
      admissionDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}admission_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $LocalStudentsTable createAlias(String alias) {
    return $LocalStudentsTable(attachedDatabase, alias);
  }
}

class LocalStudent extends DataClass implements Insertable<LocalStudent> {
  final String id;
  final String name;
  final String className;
  final String fatherName;
  final String phoneNumber;
  final String? altNumber;
  final String? dob;
  final String? admissionDate;
  final String status;
  final DateTime lastUpdated;
  const LocalStudent(
      {required this.id,
      required this.name,
      required this.className,
      required this.fatherName,
      required this.phoneNumber,
      this.altNumber,
      this.dob,
      this.admissionDate,
      required this.status,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['class_name'] = Variable<String>(className);
    map['father_name'] = Variable<String>(fatherName);
    map['phone_number'] = Variable<String>(phoneNumber);
    if (!nullToAbsent || altNumber != null) {
      map['alt_number'] = Variable<String>(altNumber);
    }
    if (!nullToAbsent || dob != null) {
      map['dob'] = Variable<String>(dob);
    }
    if (!nullToAbsent || admissionDate != null) {
      map['admission_date'] = Variable<String>(admissionDate);
    }
    map['status'] = Variable<String>(status);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  LocalStudentsCompanion toCompanion(bool nullToAbsent) {
    return LocalStudentsCompanion(
      id: Value(id),
      name: Value(name),
      className: Value(className),
      fatherName: Value(fatherName),
      phoneNumber: Value(phoneNumber),
      altNumber: altNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(altNumber),
      dob: dob == null && nullToAbsent ? const Value.absent() : Value(dob),
      admissionDate: admissionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(admissionDate),
      status: Value(status),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory LocalStudent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudent(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      className: serializer.fromJson<String>(json['className']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      altNumber: serializer.fromJson<String?>(json['altNumber']),
      dob: serializer.fromJson<String?>(json['dob']),
      admissionDate: serializer.fromJson<String?>(json['admissionDate']),
      status: serializer.fromJson<String>(json['status']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'className': serializer.toJson<String>(className),
      'fatherName': serializer.toJson<String>(fatherName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'altNumber': serializer.toJson<String?>(altNumber),
      'dob': serializer.toJson<String?>(dob),
      'admissionDate': serializer.toJson<String?>(admissionDate),
      'status': serializer.toJson<String>(status),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  LocalStudent copyWith(
          {String? id,
          String? name,
          String? className,
          String? fatherName,
          String? phoneNumber,
          Value<String?> altNumber = const Value.absent(),
          Value<String?> dob = const Value.absent(),
          Value<String?> admissionDate = const Value.absent(),
          String? status,
          DateTime? lastUpdated}) =>
      LocalStudent(
        id: id ?? this.id,
        name: name ?? this.name,
        className: className ?? this.className,
        fatherName: fatherName ?? this.fatherName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        altNumber: altNumber.present ? altNumber.value : this.altNumber,
        dob: dob.present ? dob.value : this.dob,
        admissionDate:
            admissionDate.present ? admissionDate.value : this.admissionDate,
        status: status ?? this.status,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  LocalStudent copyWithCompanion(LocalStudentsCompanion data) {
    return LocalStudent(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      className: data.className.present ? data.className.value : this.className,
      fatherName:
          data.fatherName.present ? data.fatherName.value : this.fatherName,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      altNumber: data.altNumber.present ? data.altNumber.value : this.altNumber,
      dob: data.dob.present ? data.dob.value : this.dob,
      admissionDate: data.admissionDate.present
          ? data.admissionDate.value
          : this.admissionDate,
      status: data.status.present ? data.status.value : this.status,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudent(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('className: $className, ')
          ..write('fatherName: $fatherName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('altNumber: $altNumber, ')
          ..write('dob: $dob, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('status: $status, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, className, fatherName, phoneNumber,
      altNumber, dob, admissionDate, status, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudent &&
          other.id == this.id &&
          other.name == this.name &&
          other.className == this.className &&
          other.fatherName == this.fatherName &&
          other.phoneNumber == this.phoneNumber &&
          other.altNumber == this.altNumber &&
          other.dob == this.dob &&
          other.admissionDate == this.admissionDate &&
          other.status == this.status &&
          other.lastUpdated == this.lastUpdated);
}

class LocalStudentsCompanion extends UpdateCompanion<LocalStudent> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> className;
  final Value<String> fatherName;
  final Value<String> phoneNumber;
  final Value<String?> altNumber;
  final Value<String?> dob;
  final Value<String?> admissionDate;
  final Value<String> status;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const LocalStudentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.className = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.altNumber = const Value.absent(),
    this.dob = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudentsCompanion.insert({
    required String id,
    required String name,
    required String className,
    required String fatherName,
    required String phoneNumber,
    this.altNumber = const Value.absent(),
    this.dob = const Value.absent(),
    this.admissionDate = const Value.absent(),
    this.status = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        className = Value(className),
        fatherName = Value(fatherName),
        phoneNumber = Value(phoneNumber);
  static Insertable<LocalStudent> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? className,
    Expression<String>? fatherName,
    Expression<String>? phoneNumber,
    Expression<String>? altNumber,
    Expression<String>? dob,
    Expression<String>? admissionDate,
    Expression<String>? status,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (className != null) 'class_name': className,
      if (fatherName != null) 'father_name': fatherName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (altNumber != null) 'alt_number': altNumber,
      if (dob != null) 'dob': dob,
      if (admissionDate != null) 'admission_date': admissionDate,
      if (status != null) 'status': status,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? className,
      Value<String>? fatherName,
      Value<String>? phoneNumber,
      Value<String?>? altNumber,
      Value<String?>? dob,
      Value<String?>? admissionDate,
      Value<String>? status,
      Value<DateTime>? lastUpdated,
      Value<int>? rowid}) {
    return LocalStudentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      fatherName: fatherName ?? this.fatherName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altNumber: altNumber ?? this.altNumber,
      dob: dob ?? this.dob,
      admissionDate: admissionDate ?? this.admissionDate,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (altNumber.present) {
      map['alt_number'] = Variable<String>(altNumber.value);
    }
    if (dob.present) {
      map['dob'] = Variable<String>(dob.value);
    }
    if (admissionDate.present) {
      map['admission_date'] = Variable<String>(admissionDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('className: $className, ')
          ..write('fatherName: $fatherName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('altNumber: $altNumber, ')
          ..write('dob: $dob, ')
          ..write('admissionDate: $admissionDate, ')
          ..write('status: $status, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmsHistoryTableTable extends SmsHistoryTable
    with TableInfo<$SmsHistoryTableTable, SmsHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalRecipientsMeta =
      const VerificationMeta('totalRecipients');
  @override
  late final GeneratedColumn<int> totalRecipients = GeneratedColumn<int>(
      'total_recipients', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sentCountMeta =
      const VerificationMeta('sentCount');
  @override
  late final GeneratedColumn<int> sentCount = GeneratedColumn<int>(
      'sent_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _failedCountMeta =
      const VerificationMeta('failedCount');
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
      'failed_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tag, message, totalRecipients, sentCount, failedCount, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_history_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SmsHistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('total_recipients')) {
      context.handle(
          _totalRecipientsMeta,
          totalRecipients.isAcceptableOrUnknown(
              data['total_recipients']!, _totalRecipientsMeta));
    } else if (isInserting) {
      context.missing(_totalRecipientsMeta);
    }
    if (data.containsKey('sent_count')) {
      context.handle(_sentCountMeta,
          sentCount.isAcceptableOrUnknown(data['sent_count']!, _sentCountMeta));
    } else if (isInserting) {
      context.missing(_sentCountMeta);
    }
    if (data.containsKey('failed_count')) {
      context.handle(
          _failedCountMeta,
          failedCount.isAcceptableOrUnknown(
              data['failed_count']!, _failedCountMeta));
    } else if (isInserting) {
      context.missing(_failedCountMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmsHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmsHistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      totalRecipients: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_recipients'])!,
      sentCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sent_count'])!,
      failedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_count'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $SmsHistoryTableTable createAlias(String alias) {
    return $SmsHistoryTableTable(attachedDatabase, alias);
  }
}

class SmsHistoryTableData extends DataClass
    implements Insertable<SmsHistoryTableData> {
  final int id;
  final String tag;
  final String message;
  final int totalRecipients;
  final int sentCount;
  final int failedCount;
  final DateTime timestamp;
  const SmsHistoryTableData(
      {required this.id,
      required this.tag,
      required this.message,
      required this.totalRecipients,
      required this.sentCount,
      required this.failedCount,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tag'] = Variable<String>(tag);
    map['message'] = Variable<String>(message);
    map['total_recipients'] = Variable<int>(totalRecipients);
    map['sent_count'] = Variable<int>(sentCount);
    map['failed_count'] = Variable<int>(failedCount);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  SmsHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SmsHistoryTableCompanion(
      id: Value(id),
      tag: Value(tag),
      message: Value(message),
      totalRecipients: Value(totalRecipients),
      sentCount: Value(sentCount),
      failedCount: Value(failedCount),
      timestamp: Value(timestamp),
    );
  }

  factory SmsHistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmsHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      tag: serializer.fromJson<String>(json['tag']),
      message: serializer.fromJson<String>(json['message']),
      totalRecipients: serializer.fromJson<int>(json['totalRecipients']),
      sentCount: serializer.fromJson<int>(json['sentCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tag': serializer.toJson<String>(tag),
      'message': serializer.toJson<String>(message),
      'totalRecipients': serializer.toJson<int>(totalRecipients),
      'sentCount': serializer.toJson<int>(sentCount),
      'failedCount': serializer.toJson<int>(failedCount),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  SmsHistoryTableData copyWith(
          {int? id,
          String? tag,
          String? message,
          int? totalRecipients,
          int? sentCount,
          int? failedCount,
          DateTime? timestamp}) =>
      SmsHistoryTableData(
        id: id ?? this.id,
        tag: tag ?? this.tag,
        message: message ?? this.message,
        totalRecipients: totalRecipients ?? this.totalRecipients,
        sentCount: sentCount ?? this.sentCount,
        failedCount: failedCount ?? this.failedCount,
        timestamp: timestamp ?? this.timestamp,
      );
  SmsHistoryTableData copyWithCompanion(SmsHistoryTableCompanion data) {
    return SmsHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      tag: data.tag.present ? data.tag.value : this.tag,
      message: data.message.present ? data.message.value : this.message,
      totalRecipients: data.totalRecipients.present
          ? data.totalRecipients.value
          : this.totalRecipients,
      sentCount: data.sentCount.present ? data.sentCount.value : this.sentCount,
      failedCount:
          data.failedCount.present ? data.failedCount.value : this.failedCount,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmsHistoryTableData(')
          ..write('id: $id, ')
          ..write('tag: $tag, ')
          ..write('message: $message, ')
          ..write('totalRecipients: $totalRecipients, ')
          ..write('sentCount: $sentCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, tag, message, totalRecipients, sentCount, failedCount, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmsHistoryTableData &&
          other.id == this.id &&
          other.tag == this.tag &&
          other.message == this.message &&
          other.totalRecipients == this.totalRecipients &&
          other.sentCount == this.sentCount &&
          other.failedCount == this.failedCount &&
          other.timestamp == this.timestamp);
}

class SmsHistoryTableCompanion extends UpdateCompanion<SmsHistoryTableData> {
  final Value<int> id;
  final Value<String> tag;
  final Value<String> message;
  final Value<int> totalRecipients;
  final Value<int> sentCount;
  final Value<int> failedCount;
  final Value<DateTime> timestamp;
  const SmsHistoryTableCompanion({
    this.id = const Value.absent(),
    this.tag = const Value.absent(),
    this.message = const Value.absent(),
    this.totalRecipients = const Value.absent(),
    this.sentCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  SmsHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String tag,
    required String message,
    required int totalRecipients,
    required int sentCount,
    required int failedCount,
    this.timestamp = const Value.absent(),
  })  : tag = Value(tag),
        message = Value(message),
        totalRecipients = Value(totalRecipients),
        sentCount = Value(sentCount),
        failedCount = Value(failedCount);
  static Insertable<SmsHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? tag,
    Expression<String>? message,
    Expression<int>? totalRecipients,
    Expression<int>? sentCount,
    Expression<int>? failedCount,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tag != null) 'tag': tag,
      if (message != null) 'message': message,
      if (totalRecipients != null) 'total_recipients': totalRecipients,
      if (sentCount != null) 'sent_count': sentCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  SmsHistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? tag,
      Value<String>? message,
      Value<int>? totalRecipients,
      Value<int>? sentCount,
      Value<int>? failedCount,
      Value<DateTime>? timestamp}) {
    return SmsHistoryTableCompanion(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      message: message ?? this.message,
      totalRecipients: totalRecipients ?? this.totalRecipients,
      sentCount: sentCount ?? this.sentCount,
      failedCount: failedCount ?? this.failedCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (totalRecipients.present) {
      map['total_recipients'] = Variable<int>(totalRecipients.value);
    }
    if (sentCount.present) {
      map['sent_count'] = Variable<int>(sentCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('tag: $tag, ')
          ..write('message: $message, ')
          ..write('totalRecipients: $totalRecipients, ')
          ..write('sentCount: $sentCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalStudentsTable localStudents = $LocalStudentsTable(this);
  late final $SmsHistoryTableTable smsHistoryTable =
      $SmsHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localStudents, smsHistoryTable];
}

typedef $$LocalStudentsTableCreateCompanionBuilder = LocalStudentsCompanion
    Function({
  required String id,
  required String name,
  required String className,
  required String fatherName,
  required String phoneNumber,
  Value<String?> altNumber,
  Value<String?> dob,
  Value<String?> admissionDate,
  Value<String> status,
  Value<DateTime> lastUpdated,
  Value<int> rowid,
});
typedef $$LocalStudentsTableUpdateCompanionBuilder = LocalStudentsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> className,
  Value<String> fatherName,
  Value<String> phoneNumber,
  Value<String?> altNumber,
  Value<String?> dob,
  Value<String?> admissionDate,
  Value<String> status,
  Value<DateTime> lastUpdated,
  Value<int> rowid,
});

class $$LocalStudentsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fatherName => $composableBuilder(
      column: $table.fatherName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get altNumber => $composableBuilder(
      column: $table.altNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get admissionDate => $composableBuilder(
      column: $table.admissionDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$LocalStudentsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get className => $composableBuilder(
      column: $table.className, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fatherName => $composableBuilder(
      column: $table.fatherName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get altNumber => $composableBuilder(
      column: $table.altNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get admissionDate => $composableBuilder(
      column: $table.admissionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$LocalStudentsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
      column: $table.fatherName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get altNumber =>
      $composableBuilder(column: $table.altNumber, builder: (column) => column);

  GeneratedColumn<String> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get admissionDate => $composableBuilder(
      column: $table.admissionDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$LocalStudentsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalStudentsTable,
    LocalStudent,
    $$LocalStudentsTableFilterComposer,
    $$LocalStudentsTableOrderingComposer,
    $$LocalStudentsTableAnnotationComposer,
    $$LocalStudentsTableCreateCompanionBuilder,
    $$LocalStudentsTableUpdateCompanionBuilder,
    (
      LocalStudent,
      BaseReferences<_$LocalDatabase, $LocalStudentsTable, LocalStudent>
    ),
    LocalStudent,
    PrefetchHooks Function()> {
  $$LocalStudentsTableTableManager(
      _$LocalDatabase db, $LocalStudentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> className = const Value.absent(),
            Value<String> fatherName = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String?> altNumber = const Value.absent(),
            Value<String?> dob = const Value.absent(),
            Value<String?> admissionDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStudentsCompanion(
            id: id,
            name: name,
            className: className,
            fatherName: fatherName,
            phoneNumber: phoneNumber,
            altNumber: altNumber,
            dob: dob,
            admissionDate: admissionDate,
            status: status,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String className,
            required String fatherName,
            required String phoneNumber,
            Value<String?> altNumber = const Value.absent(),
            Value<String?> dob = const Value.absent(),
            Value<String?> admissionDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStudentsCompanion.insert(
            id: id,
            name: name,
            className: className,
            fatherName: fatherName,
            phoneNumber: phoneNumber,
            altNumber: altNumber,
            dob: dob,
            admissionDate: admissionDate,
            status: status,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalStudentsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalStudentsTable,
    LocalStudent,
    $$LocalStudentsTableFilterComposer,
    $$LocalStudentsTableOrderingComposer,
    $$LocalStudentsTableAnnotationComposer,
    $$LocalStudentsTableCreateCompanionBuilder,
    $$LocalStudentsTableUpdateCompanionBuilder,
    (
      LocalStudent,
      BaseReferences<_$LocalDatabase, $LocalStudentsTable, LocalStudent>
    ),
    LocalStudent,
    PrefetchHooks Function()>;
typedef $$SmsHistoryTableTableCreateCompanionBuilder = SmsHistoryTableCompanion
    Function({
  Value<int> id,
  required String tag,
  required String message,
  required int totalRecipients,
  required int sentCount,
  required int failedCount,
  Value<DateTime> timestamp,
});
typedef $$SmsHistoryTableTableUpdateCompanionBuilder = SmsHistoryTableCompanion
    Function({
  Value<int> id,
  Value<String> tag,
  Value<String> message,
  Value<int> totalRecipients,
  Value<int> sentCount,
  Value<int> failedCount,
  Value<DateTime> timestamp,
});

class $$SmsHistoryTableTableFilterComposer
    extends Composer<_$LocalDatabase, $SmsHistoryTableTable> {
  $$SmsHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalRecipients => $composableBuilder(
      column: $table.totalRecipients,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sentCount => $composableBuilder(
      column: $table.sentCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$SmsHistoryTableTableOrderingComposer
    extends Composer<_$LocalDatabase, $SmsHistoryTableTable> {
  $$SmsHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalRecipients => $composableBuilder(
      column: $table.totalRecipients,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sentCount => $composableBuilder(
      column: $table.sentCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$SmsHistoryTableTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SmsHistoryTableTable> {
  $$SmsHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get totalRecipients => $composableBuilder(
      column: $table.totalRecipients, builder: (column) => column);

  GeneratedColumn<int> get sentCount =>
      $composableBuilder(column: $table.sentCount, builder: (column) => column);

  GeneratedColumn<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$SmsHistoryTableTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SmsHistoryTableTable,
    SmsHistoryTableData,
    $$SmsHistoryTableTableFilterComposer,
    $$SmsHistoryTableTableOrderingComposer,
    $$SmsHistoryTableTableAnnotationComposer,
    $$SmsHistoryTableTableCreateCompanionBuilder,
    $$SmsHistoryTableTableUpdateCompanionBuilder,
    (
      SmsHistoryTableData,
      BaseReferences<_$LocalDatabase, $SmsHistoryTableTable,
          SmsHistoryTableData>
    ),
    SmsHistoryTableData,
    PrefetchHooks Function()> {
  $$SmsHistoryTableTableTableManager(
      _$LocalDatabase db, $SmsHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsHistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> tag = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<int> totalRecipients = const Value.absent(),
            Value<int> sentCount = const Value.absent(),
            Value<int> failedCount = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              SmsHistoryTableCompanion(
            id: id,
            tag: tag,
            message: message,
            totalRecipients: totalRecipients,
            sentCount: sentCount,
            failedCount: failedCount,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String tag,
            required String message,
            required int totalRecipients,
            required int sentCount,
            required int failedCount,
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              SmsHistoryTableCompanion.insert(
            id: id,
            tag: tag,
            message: message,
            totalRecipients: totalRecipients,
            sentCount: sentCount,
            failedCount: failedCount,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SmsHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $SmsHistoryTableTable,
    SmsHistoryTableData,
    $$SmsHistoryTableTableFilterComposer,
    $$SmsHistoryTableTableOrderingComposer,
    $$SmsHistoryTableTableAnnotationComposer,
    $$SmsHistoryTableTableCreateCompanionBuilder,
    $$SmsHistoryTableTableUpdateCompanionBuilder,
    (
      SmsHistoryTableData,
      BaseReferences<_$LocalDatabase, $SmsHistoryTableTable,
          SmsHistoryTableData>
    ),
    SmsHistoryTableData,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalStudentsTableTableManager get localStudents =>
      $$LocalStudentsTableTableManager(_db, _db.localStudents);
  $$SmsHistoryTableTableTableManager get smsHistoryTable =>
      $$SmsHistoryTableTableTableManager(_db, _db.smsHistoryTable);
}
