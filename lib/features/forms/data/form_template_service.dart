import 'package:classmyte/features/forms/models/form_template_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormTemplateService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CollectionReference _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _db.collection('users').doc(user.uid).collection('form_templates');
  }

  static Future<void> addTemplate(FormTemplate template) async {
    final col = _getCollection();
    final docRef = col.doc();
    await docRef.set({
      ...template.toMap(),
      'id': docRef.id,
      'isDefault': false,
    });
  }

  static Future<void> updateTemplate(FormTemplate template) async {
    final col = _getCollection();
    await col.doc(template.id).update(template.toMap());
  }

  static Future<void> deleteTemplate(String id) async {
    final col = _getCollection();
    await col.doc(id).delete();
  }

  static Future<void> duplicateTemplate(FormTemplate template) async {
    final col = _getCollection();
    final docRef = col.doc();
    await docRef.set({
      ...template.toMap(),
      'id': docRef.id,
      'formName': '${template.formName} (Copy)',
      'isDefault': false,
    });
  }
}
