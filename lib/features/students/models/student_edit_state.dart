class StudentEditState {
  final String name;
  final String fatherName;
  final String className;
  final String phoneNumber;
  final String altNumber;
  final String dob;
  final String admissionDate;
  final String gender;
  final String religion;
  final String nationality;
  final String address;
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
    required this.gender,
    required this.religion,
    required this.nationality,
    required this.address,
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
    String? gender,
    String? religion,
    String? nationality,
    String? address,
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
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      isEditable: isEditable ?? this.isEditable,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
