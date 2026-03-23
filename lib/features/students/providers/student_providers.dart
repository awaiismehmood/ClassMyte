import 'package:classmyte/features/students/models/student_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classmyte/core/data/data_retrieval.dart';
import 'package:classmyte/core/services/searching.dart';
import '../models/student_edit_state.dart';

class StudentEditNotifier extends AutoDisposeFamilyNotifier<StudentEditState, Student> {
  @override
  StudentEditState build(Student arg) {
    return StudentEditState(
      name: arg.name,
      fatherName: arg.fatherName,
      className: arg.className,
      phoneNumber: arg.phoneNumber,
      altNumber: arg.altNumber,
      dob: arg.dob,
      admissionDate: arg.admissionDate,
      gender: arg.gender,
      religion: arg.religion,
      nationality: arg.nationality,
      address: arg.address,
      isActive: arg.status == 'Active',
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
      case 'gender': state = state.copyWith(gender: value); break;
      case 'religion': state = state.copyWith(religion: value); break;
      case 'nationality': state = state.copyWith(nationality: value); break;
      case 'address': state = state.copyWith(address: value); break;
    }
  }

  void toggleActive(bool val) => state = state.copyWith(isActive: val);
  void toggleEditable() => state = state.copyWith(isEditable: !state.isEditable);
  void setLoading(bool val) => state = state.copyWith(isLoading: val);
}

final studentEditProvider = NotifierProvider.family.autoDispose<StudentEditNotifier, StudentEditState, Student>(StudentEditNotifier.new);

// Convert to StreamProvider for real-time updates
final studentDataProvider = StreamProvider<List<Student>>((ref) => StudentData.studentStream());

final studentSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final selectedClassesProvider = StateProvider.autoDispose<List<String>>((ref) => []);
final selectedAdmissionYearProvider = StateProvider.autoDispose<int>((ref) => 0);
final selectedAgeProvider = StateProvider.autoDispose<int>((ref) => 0);
final showBirthdaysOnlyProvider = StateProvider.autoDispose<bool>((ref) => false);
final selectedStatusFilterProvider = StateProvider.autoDispose<String>((ref) => 'All');

final filteredStudentsProvider = Provider.autoDispose<List<Student>>((ref) {
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

final selectedStudentIdsProvider = StateProvider.autoDispose<Set<String>>((ref) => {});
