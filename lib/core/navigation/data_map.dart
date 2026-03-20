// ignore_for_file: non_constant_identifier_names

class Student {
  final String name;
  final String className;
  final String phoneNumber;
  final String fatherName;
  final String DOB;
  final String Admission;
  final bool isActive;

  Student({
    required this.name,
    required this.className,
    required this.phoneNumber,
    required this.fatherName,
    required this.DOB,
    required this.Admission,
    this.isActive = true,
  });
}

