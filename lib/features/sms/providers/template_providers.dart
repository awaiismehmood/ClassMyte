import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TemplateModel {
  final String id;
  final String title;
  final String text;
  final String category;

  const TemplateModel({required this.id, required this.title, required this.text, required this.category});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'text': text,
        'category': category,
      };

  factory TemplateModel.fromMap(Map<String, dynamic> map) => TemplateModel(
        id: map['id'],
        title: map['title'],
        text: map['text'],
        category: map['category'],
      );
}

final personalizationProvider = StateNotifierProvider<PersonalizationNotifier, Map<String, String>>((ref) {
  return PersonalizationNotifier();
});

class PersonalizationNotifier extends StateNotifier<Map<String, String>> {
  PersonalizationNotifier() : super({'prefix': '', 'suffix': ''}) {
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        state = {
          'prefix': doc.data()?['msg_prefix'] ?? '',
          'suffix': doc.data()?['msg_suffix'] ?? '',
        };
      }
    } else {
      // Fallback for not logged in yet
      final prefs = await SharedPreferences.getInstance();
      state = {
        'prefix': prefs.getString('msg_prefix') ?? '',
        'suffix': prefs.getString('msg_suffix') ?? '',
      };
    }
  }

  Future<void> save(String prefix, String suffix) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'msg_prefix': prefix,
        'msg_suffix': suffix,
      }, SetOptions(merge: true));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('msg_prefix', prefix);
      await prefs.setString('msg_suffix', suffix);
    }
    state = {'prefix': prefix, 'suffix': suffix};
  }
}

final userTemplatesProvider = StreamProvider.autoDispose<List<TemplateModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('templates')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TemplateModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList());
});

class TemplateService {
  static Future<void> addTemplate(TemplateModel template) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('templates')
        .doc();
    await docRef.set({...template.toMap(), 'id': docRef.id});
  }

  static Future<void> updateTemplate(TemplateModel template) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('templates')
        .doc(template.id)
        .update(template.toMap());
  }

  static Future<void> removeTemplate(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('templates')
        .doc(id)
        .delete();
  }
}

final selectedTemplateProvider = StateProvider<String?>((ref) => null);

final templateCategoryProvider = StateProvider<String>((ref) => 'Anniversary');
