import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/features/students/providers/student_providers.dart';

final classSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredClassesProvider = Provider<List<String>>((ref) {
  final allStudents = ref.watch(studentDataProvider).value ?? [];
  final query = ref.watch(classSearchQueryProvider).toLowerCase();
  
  final allClasses = allStudents.map((s) => s.className).toSet().where((c) => c.isNotEmpty).toList();
  
  if (query.isEmpty) {
    return allClasses;
  }
  
  return allClasses.where((c) => c.toLowerCase().contains(query)).toList();
});
