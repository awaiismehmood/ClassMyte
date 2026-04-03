import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

@DataClassName('LocalStudent')
class LocalStudents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get className => text()();
  TextColumn get fatherName => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get altNumber => text().nullable()();
  TextColumn get dob => text().nullable()();
  TextColumn get admissionDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('Active'))();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SmsHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tag => text()();
  TextColumn get message => text()();
  IntColumn get totalRecipients => integer()();
  IntColumn get sentCount => integer()();
  IntColumn get failedCount => integer()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [LocalStudents, SmsHistoryTable])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'classmyte.sqlite'));
    return NativeDatabase(file);
  });
}
