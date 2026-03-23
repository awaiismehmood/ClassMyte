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
  final String gender;
  final String religion;
  final String nationality;
  final String address;

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
    this.gender = 'Not Specified',
    this.religion = '',
    this.nationality = '',
    this.address = '',
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
      gender: data['Gender'] ?? 'Not Specified',
      religion: data['Religion'] ?? '',
      nationality: data['Nationality'] ?? '',
      address: data['Address'] ?? '',
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
      'Gender': gender,
      'Religion': religion,
      'Nationality': nationality,
      'Address': address,
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
    String? gender,
    String? religion,
    String? nationality,
    String? address,
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
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
    );
  }
}
