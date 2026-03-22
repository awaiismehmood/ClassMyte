import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/core/data/data_retrieval.dart';
import 'package:classmyte/core/services/searching.dart';
import '../models/student_edit_state.dart';

class StudentEditNotifier extends AutoDisposeFamilyNotifier<StudentEditState, Map<String, String>> {
  @override
  StudentEditState build(Map<String, String> arg) {
    return StudentEditState(
      name: arg['name'] ?? '',
      fatherName: arg['fatherName'] ?? '',
      className: arg['class'] ?? '',
      phoneNumber: arg['phoneNumber'] ?? '',
      altNumber: arg['altNumber'] ?? '',
      dob: arg['DOB'] ?? '',
      admissionDate: arg['Admission Date'] ?? '',
      isActive: arg['status'] == 'Active',
    );
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'name': state = state.copyWith(name: value); break;
      case 'fatherName': state = state.copyWith(fatherName: value); break;
      case 'class': state = state.copyWith(className: value); break;
      case 'phoneNumber': state = state.copyWith(phoneNumber: value); break;
      case 'altNumber': state = state.copyWith(altNumber: value); break;
      case 'dob': state = state.copyWith(dob: value); break;
      case 'admissionDate': state = state.copyWith(admissionDate: value); break;
    }
  }

  void toggleActive(bool val) => state = state.copyWith(isActive: val);
  void toggleEditable() => state = state.copyWith(isEditable: !state.isEditable);
  void setLoading(bool val) => state = state.copyWith(isLoading: val);
}

final studentEditProvider = NotifierProvider.family.autoDispose<StudentEditNotifier, StudentEditState, Map<String, String>>(StudentEditNotifier.new);

final studentDataProvider = FutureProvider<List<Map<String, String>>>((ref) async => await StudentData.getStudentData());

final studentSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedClassesProvider = StateProvider<List<String>>((ref) => []);
final selectedAdmissionYearProvider = StateProvider<int>((ref) => 0);
final selectedAgeProvider = StateProvider<int>((ref) => 0);
final showBirthdaysOnlyProvider = StateProvider<bool>((ref) => false);
final selectedStatusFilterProvider = StateProvider<String>((ref) => 'All');

final filteredStudentsProvider = Provider<List<Map<String, String>>>((ref) {
  final allStudents = ref.watch(studentDataProvider).value ?? [];
  final query = ref.watch(studentSearchQueryProvider);
  final selectedClasses = ref.watch(selectedClassesProvider);
  final selectedYear = ref.watch(selectedAdmissionYearProvider);
  final selectedAge = ref.watch(selectedAgeProvider);
  final showBirthdaysOnly = ref.watch(showBirthdaysOnlyProvider);
  final selectedStatus = ref.watch(selectedStatusFilterProvider);

  if (query.isEmpty && selectedClasses.isEmpty && selectedYear == 0 && selectedAge == 0 && !showBirthdaysOnly && selectedStatus == 'All') return allStudents;

  return SearchService.searchStudents(
    allStudents,
    query,
    selectedClasses: selectedClasses,
    selectedYear: selectedYear,
    selectedAge: selectedAge,
    showBirthdaysOnly: showBirthdaysOnly,
    selectedStatus: selectedStatus,
  );
});

final selectedStudentIdsProvider = StateProvider<Set<String>>((ref) => {});
