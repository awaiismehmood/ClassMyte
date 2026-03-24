class FormTemplate {
  final String id;
  final String formName;
  final String title;
  final String subtitle;
  final String content;
  final String footer;
  final bool isDefault;
  final String schoolName;
  final String? logoUrl;
  final bool showLogo;
  final String logoAlignment;
  final String logoShape; // 'round', 'square'
  final List<String> signatures;
  
  // New Customization Options
  final String titlePlacement; // 'above_header', 'below_header'
  final String titleAlignment; // 'left', 'center', 'right'
  final bool showHeader;
  final bool showFooter;
  final String bodyAlignment; // 'left', 'center', 'justify'
  
  // Section Toggles
  final bool headerEnabled;
  final bool titleEnabled;
  final bool bodyEnabled;
  final bool footerEnabled;
  final bool signaturesEnabled;

  // Styling Options (Title)
  final bool titleBold;
  final bool titleItalic;
  final bool titleUnderline;
  final double titleFontSize;
  
  // Styling Options (Subtitle)
  final bool subtitleBold;
  final bool subtitleItalic;
  final bool subtitleUnderline;
  final double subtitleFontSize;
  
  // Styling Options (Body)
  final bool bodyBold;
  final bool bodyItalic;
  final bool bodyUnderline;
  final double bodyFontSize;

  FormTemplate({
    required this.id,
    this.formName = 'Untitled Form',
    required this.title,
    required this.subtitle,
    required this.content,
    this.footer = '',
    this.isDefault = false,
    this.schoolName = 'ClassMyte Academy',
    this.logoUrl,
    this.showLogo = false,
    this.logoAlignment = 'center',
    this.logoShape = 'round',
    this.signatures = const ['Student Signature', 'Authorized Signature'],
    this.titlePlacement = 'below_header',
    this.titleAlignment = 'center',
    this.showHeader = true,
    this.showFooter = true,
    this.bodyAlignment = 'left',
    this.headerEnabled = true,
    this.titleEnabled = true,
    this.bodyEnabled = true,
    this.footerEnabled = true,
    this.signaturesEnabled = true,
    this.titleBold = true,
    this.titleItalic = false,
    this.titleUnderline = false,
    this.titleFontSize = 18,
    this.subtitleBold = false,
    this.subtitleItalic = true,
    this.subtitleUnderline = false,
    this.subtitleFontSize = 12,
    this.bodyBold = false,
    this.bodyItalic = false,
    this.bodyUnderline = false,
    this.bodyFontSize = 14,
  });

  Map<String, dynamic> toMap() {
    return {
      'formName': formName,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'footer': footer,
      'isDefault': isDefault,
      'schoolName': schoolName,
      'logoUrl': logoUrl,
      'showLogo': showLogo,
      'logoAlignment': logoAlignment,
      'logoShape': logoShape,
      'signatures': signatures,
      'titlePlacement': titlePlacement,
      'titleAlignment': titleAlignment,
      'showHeader': showHeader,
      'showFooter': showFooter,
      'bodyAlignment': bodyAlignment,
      'headerEnabled': headerEnabled,
      'titleEnabled': titleEnabled,
      'bodyEnabled': bodyEnabled,
      'footerEnabled': footerEnabled,
      'signaturesEnabled': signaturesEnabled,
      'titleBold': titleBold,
      'titleItalic': titleItalic,
      'titleUnderline': titleUnderline,
      'titleFontSize': titleFontSize,
      'subtitleBold': subtitleBold,
      'subtitleItalic': subtitleItalic,
      'subtitleUnderline': subtitleUnderline,
      'subtitleFontSize': subtitleFontSize,
      'bodyBold': bodyBold,
      'bodyItalic': bodyItalic,
      'bodyUnderline': bodyUnderline,
      'bodyFontSize': bodyFontSize,
    };
  }

  factory FormTemplate.fromMap(Map<String, dynamic> map, String id) {
    return FormTemplate(
      id: id,
      formName: map['formName'] ?? 'Untitled Form',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      content: map['content'] ?? '',
      footer: map['footer'] ?? '',
      isDefault: map['isDefault'] ?? false,
      schoolName: map['schoolName'] ?? 'ClassMyte Academy',
      logoUrl: map['logoUrl'],
      showLogo: map['showLogo'] ?? false,
      logoAlignment: map['logoAlignment'] ?? 'center',
      logoShape: map['logoShape'] ?? 'round',
      signatures: List<String>.from(
          map['signatures'] ?? ['Student Signature', 'Authorized Signature']),
      titlePlacement: map['titlePlacement'] ?? 'below_header',
      titleAlignment: map['titleAlignment'] ?? 'center',
      showHeader: map['showHeader'] ?? true,
      showFooter: map['showFooter'] ?? true,
      bodyAlignment: map['bodyAlignment'] ?? 'left',
      headerEnabled: map['headerEnabled'] ?? true,
      titleEnabled: map['titleEnabled'] ?? true,
      bodyEnabled: map['bodyEnabled'] ?? true,
      footerEnabled: map['footerEnabled'] ?? true,
      signaturesEnabled: map['signaturesEnabled'] ?? true,
      titleBold: map['titleBold'] ?? true,
      titleItalic: map['titleItalic'] ?? false,
      titleUnderline: map['titleUnderline'] ?? false,
      titleFontSize: (map['titleFontSize'] ?? 18).toDouble(),
      subtitleBold: map['subtitleBold'] ?? false,
      subtitleItalic: map['subtitleItalic'] ?? true,
      subtitleUnderline: map['subtitleUnderline'] ?? false,
      subtitleFontSize: (map['subtitleFontSize'] ?? 12).toDouble(),
      bodyBold: map['bodyBold'] ?? false,
      bodyItalic: map['bodyItalic'] ?? false,
      bodyUnderline: map['bodyUnderline'] ?? false,
      bodyFontSize: (map['bodyFontSize'] ?? 14).toDouble(),
    );
  }

  FormTemplate copyWith({
    String? id,
    String? formName,
    String? title,
    String? subtitle,
    String? content,
    String? footer,
    bool? isDefault,
    String? schoolName,
    String? logoUrl,
    bool? showLogo,
    String? logoAlignment,
    String? logoShape,
    List<String>? signatures,
    String? titlePlacement,
    String? titleAlignment,
    bool? showHeader,
    bool? showFooter,
    String? bodyAlignment,
    bool? headerEnabled,
    bool? titleEnabled,
    bool? bodyEnabled,
    bool? footerEnabled,
    bool? signaturesEnabled,
    bool? titleBold,
    bool? titleItalic,
    bool? titleUnderline,
    double? titleFontSize,
    bool? subtitleBold,
    bool? subtitleItalic,
    bool? subtitleUnderline,
    double? subtitleFontSize,
    bool? bodyBold,
    bool? bodyItalic,
    bool? bodyUnderline,
    double? bodyFontSize,
  }) {
    return FormTemplate(
      id: id ?? this.id,
      formName: formName ?? this.formName,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      footer: footer ?? this.footer,
      isDefault: isDefault ?? this.isDefault,
      schoolName: schoolName ?? this.schoolName,
      logoUrl: logoUrl ?? this.logoUrl,
      showLogo: showLogo ?? this.showLogo,
      logoAlignment: logoAlignment ?? this.logoAlignment,
      logoShape: logoShape ?? this.logoShape,
      signatures: signatures ?? this.signatures,
      titlePlacement: titlePlacement ?? this.titlePlacement,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      showHeader: showHeader ?? this.showHeader,
      showFooter: showFooter ?? this.showFooter,
      bodyAlignment: bodyAlignment ?? this.bodyAlignment,
      headerEnabled: headerEnabled ?? this.headerEnabled,
      titleEnabled: titleEnabled ?? this.titleEnabled,
      bodyEnabled: bodyEnabled ?? this.bodyEnabled,
      footerEnabled: footerEnabled ?? this.footerEnabled,
      signaturesEnabled: signaturesEnabled ?? this.signaturesEnabled,
      titleBold: titleBold ?? this.titleBold,
      titleItalic: titleItalic ?? this.titleItalic,
      titleUnderline: titleUnderline ?? this.titleUnderline,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      subtitleBold: subtitleBold ?? this.subtitleBold,
      subtitleItalic: subtitleItalic ?? this.subtitleItalic,
      subtitleUnderline: subtitleUnderline ?? this.subtitleUnderline,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      bodyBold: bodyBold ?? this.bodyBold,
      bodyItalic: bodyItalic ?? this.bodyItalic,
      bodyUnderline: bodyUnderline ?? this.bodyUnderline,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
    );
  }
}

