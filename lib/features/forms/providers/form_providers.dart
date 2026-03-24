import 'package:classmyte/features/forms/models/form_template_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formTemplatesProvider = StreamProvider.autoDispose<List<FormTemplate>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('form_templates')
      .snapshots()
      .map((snapshot) {
    final templates = snapshot.docs
        .map((doc) => FormTemplate.fromMap(doc.data(), doc.id))
        .toList();

    if (templates.isEmpty) {
      return [
        FormTemplate(
          id: 'default_sample',
          formName: 'Sample Form',
          title: 'Sample Form',
          subtitle: 'Student Record & Identity',
          content: 'This is to certify that [name], s/o [father_name], has been successfully admitted to [class]. \n\nRegistration Details:\nPhone: [phone]\nDOB: [dob]\nAdmission Date: [admission_date]\n\nPlease keep this document safe for future reference.',
          footer: 'Official Student Record - Generated via ClassMyte',
          isDefault: true,
        ),
      ];
    }
    return templates;
  });
});
