import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_database.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(() => db.close());
  return db;
});
