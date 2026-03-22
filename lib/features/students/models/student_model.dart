import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String fatherName;
  final String className;
  final String phoneNumber;
  final String altNumber;
  final String dob;
  final String admissionDate;
  final String status;

  Student({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.className,
    required this.phoneNumber,
    required this.altNumber,
    required this.dob,
    required this.admissionDate,
    required this.status,
  });

  factory Student.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Student(
      id: doc.id,
      name: data['Name'] ?? '',
      fatherName: data['Father Name'] ?? '',
      className: data['Class'] ?? '',
      phoneNumber: data['Number'] ?? '',
      altNumber: data['Alt Number'] ?? '',
      dob: data['DOB'] ?? '',
      admissionDate: data['Admission Date'] ?? '',
      status: data['status'] ?? 'Active',
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'fatherName': fatherName,
      'class': className,
      'phoneNumber': phoneNumber,
      'altNumber': altNumber,
      'DOB': dob,
      'Admission Date': admissionDate,
      'status': status,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? fatherName,
    String? className,
    String? phoneNumber,
    String? altNumber,
    String? dob,
    String? admissionDate,
    String? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      className: className ?? this.className,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      altNumber: altNumber ?? this.altNumber,
      dob: dob ?? this.dob,
      admissionDate: admissionDate ?? this.admissionDate,
      status: status ?? this.status,
    );
  }
}
