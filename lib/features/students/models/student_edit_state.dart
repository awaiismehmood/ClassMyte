class StudentEditState {
  final String name;
  final String fatherName;
  final String className;
  final String phoneNumber;
  final String altNumber;
  final String dob;
  final String admissionDate;
  final bool isActive;
  final bool isEditable;
  final bool isLoading;

  StudentEditState({
    required this.name,
    required this.fatherName,
    required this.className,
    required this.phoneNumber,
    required this.altNumber,
    required this.dob,
    required this.admissionDate,
    this.isActive = true,
    this.isEditable = false,
    this.isLoading = false,
  });

  StudentEditState copyWith({
    String? name,
    String? fatherName,
    String? className,
    String? phoneNumber,
    String? altNumber,
    String? dob,
    String? admissionDate,
    bool? isActive,
    bool? isEditable,
    bool? isLoading,
  }) {
    return StudentEditState(
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      className: className ?? this.className,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altNumber: altNumber ?? this.altNumber,
      dob: dob ?? this.dob,
      admissionDate: admissionDate ?? this.admissionDate,
      isActive: isActive ?? this.isActive,
      isEditable: isEditable ?? this.isEditable,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
