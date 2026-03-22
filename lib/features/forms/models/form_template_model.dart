class FormTemplate {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String footer;
  final bool isDefault;
  final String schoolName;
  final String? logoUrl;
  final bool showLogo;
  final String logoAlignment;
  final List<String> signatures;

  FormTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    this.footer = '',
    this.isDefault = false,
    this.schoolName = 'ClassMyte Academy',
    this.logoUrl,
    this.showLogo = false,
    this.logoAlignment = 'center',
    this.signatures = const ['Student Signature', 'Authorized Signature'],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'footer': footer,
      'isDefault': isDefault,
      'schoolName': schoolName,
      'logoUrl': logoUrl,
      'showLogo': showLogo,
      'logoAlignment': logoAlignment,
      'signatures': signatures,
    };
  }

  factory FormTemplate.fromMap(Map<String, dynamic> map, String id) {
    return FormTemplate(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      content: map['content'] ?? '',
      footer: map['footer'] ?? '',
      isDefault: map['isDefault'] ?? false,
      schoolName: map['schoolName'] ?? 'ClassMyte Academy',
      logoUrl: map['logoUrl'],
      showLogo: map['showLogo'] ?? false,
      logoAlignment: map['logoAlignment'] ?? 'center',
      signatures: List<String>.from(
          map['signatures'] ?? ['Student Signature', 'Authorized Signature']),
    );
  }
}
