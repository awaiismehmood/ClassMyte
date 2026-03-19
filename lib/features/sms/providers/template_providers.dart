import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    state = {
      'prefix': prefs.getString('msg_prefix') ?? '',
      'suffix': prefs.getString('msg_suffix') ?? '',
    };
  }

  Future<void> save(String prefix, String suffix) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('msg_prefix', prefix);
    await prefs.setString('msg_suffix', suffix);
    state = {'prefix': prefix, 'suffix': suffix};
  }
}

final userTemplatesProvider = StateNotifierProvider<TemplatesNotifier, List<TemplateModel>>((ref) {
  return TemplatesNotifier();
});

class TemplatesNotifier extends StateNotifier<List<TemplateModel>> {
  TemplatesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('user_templates') ?? [];
    state = data.map((e) => TemplateModel.fromMap(jsonDecode(e))).toList();
  }

  Future<void> addTemplate(TemplateModel template) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [...state, template];
    final encoded = updated.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('user_templates', encoded);
    state = updated;
  }

  Future<void> removeTemplate(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = state.where((e) => e.id != id).toList();
    final encoded = updated.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('user_templates', encoded);
    state = updated;
  }
}

final templateCategoryProvider = StateProvider<String>((ref) => 'Anniversary');
