import 'dart:io';
import 'package:classmyte/features/students/models/student_model.dart';
import 'package:classmyte/features/forms/models/form_template_model.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as p;

class FormGenerator {
  static Future<void> generateAndPrintForm({
    required Student student,
    required FormTemplate template,
  }) async {
    final doc = pw.Document();

    // Prepare Logo if enabled and path exists
    pw.ImageProvider? logoImage;
    if (template.showLogo && template.logoUrl != null && template.logoUrl!.isNotEmpty) {
      final file = File(template.logoUrl!);
      if (await file.exists()) {
        logoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    // Replace placeholders in content
    String processedContent = template.content
        .replaceAll('[name]', student.name)
        .replaceAll('[father_name]', student.fatherName)
        .replaceAll('[class]', student.className)
        .replaceAll('[phone]', student.phoneNumber)
        .replaceAll('[dob]', student.dob)
        .replaceAll('[admission_date]', student.admissionDate)
        .replaceAll('[alt_phone]', student.altNumber)
        .replaceAll('[gender]', student.gender)
        .replaceAll('[religion]', student.religion)
        .replaceAll('[nationality]', student.nationality)
        .replaceAll('[address]', student.address)
        .replaceAll('[schoolName]', template.schoolName);

    doc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Top Sections
                if (template.titlePlacement == 'above_header') ...[
                   if (template.titleEnabled) _buildTitleSection(template),
                   pw.SizedBox(height: 10),
                   if (template.headerEnabled) _buildHeader(template, logoImage),
                ] else ...[
                   if (template.headerEnabled) _buildHeader(template, logoImage),
                   pw.SizedBox(height: 10),
                   if (template.titleEnabled) _buildTitleSection(template),
                ],
                
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 30),

                // Content
                if (template.bodyEnabled)
                  pw.Text(
                    processedContent,
                    textAlign: _getAlign(template.bodyAlignment),
                    style: _getStyle(
                      bold: template.bodyBold,
                      italic: template.bodyItalic,
                      underline: template.bodyUnderline,
                      fontSize: template.bodyFontSize,
                      color: pdf.PdfColors.black,
                    ),
                  ),

                pw.Spacer(),

                // Dynamic Signatures
                if (template.signaturesEnabled)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: template.signatures.map((sig) {
                      return pw.Column(
                        children: [
                          pw.Container(
                            width: 120,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(top: pw.BorderSide(width: 0.5)),
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(sig, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      );
                    }).toList(),
                  ),
                pw.SizedBox(height: 50),
                
                // Footer
                if (template.footerEnabled && template.footer.isNotEmpty) ...[
                  pw.Divider(thickness: 0.5),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text(
                      template.footer,
                      style: pw.TextStyle(fontSize: 10, color: pdf.PdfColors.grey600),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

    // Preview and Print
    await p.Printing.layoutPdf(
      onLayout: (pdf.PdfPageFormat format) async => doc.save(),
      name: '${student.name}_${template.id}.pdf',
    );
  }

  static pw.Widget _buildTitleSection(FormTemplate template) {
    final alignment = _getAlign(template.titleAlignment);
    return pw.Column(
      crossAxisAlignment: _getCrossAlign(template.titleAlignment),
      children: [
        pw.Text(
          template.title,
          textAlign: alignment,
          style: _getStyle(
            bold: template.titleBold,
            italic: template.titleItalic,
            underline: template.titleUnderline,
            fontSize: template.titleFontSize,
            color: pdf.PdfColors.black,
          ),
        ),
        if (template.subtitle.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            template.subtitle,
            textAlign: alignment,
            style: _getStyle(
              bold: template.subtitleBold,
              italic: template.subtitleItalic,
              underline: template.subtitleUnderline,
              fontSize: template.subtitleFontSize,
              color: pdf.PdfColors.grey700,
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildHeader(FormTemplate template, pw.ImageProvider? logo) {
    final schoolNameWidget = pw.Text(
          template.schoolName.toUpperCase(),
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        );

    if (logo == null || !template.showLogo) return pw.Center(child: schoolNameWidget);

    final logoWidget = pw.Container(
      width: 70,
      height: 70,
      child: template.logoShape == 'round' 
        ? pw.ClipOval(child: pw.Image(logo, fit: pw.BoxFit.cover))
        : pw.Image(logo, fit: pw.BoxFit.cover),
    );

    if (template.logoAlignment == 'center') {
      return pw.Center(
        child: pw.Column(
          children: [
            logoWidget,
            pw.SizedBox(height: 10),
            schoolNameWidget,
          ],
        ),
      );
    } else if (template.logoAlignment == 'left') {
      return pw.Row(
        children: [
          logoWidget,
          pw.SizedBox(width: 20),
          pw.Expanded(child: schoolNameWidget),
        ],
      );
    } else {
      return pw.Row(
        children: [
          pw.Expanded(child: schoolNameWidget),
          pw.SizedBox(width: 20),
          logoWidget,
        ],
      );
    }
  }

  static pw.CrossAxisAlignment _getCrossAlign(String align) {
    switch (align) {
      case 'left': return pw.CrossAxisAlignment.start;
      case 'right': return pw.CrossAxisAlignment.end;
      default: return pw.CrossAxisAlignment.center;
    }
  }

  static pw.TextAlign _getAlign(String align) {
    switch (align) {
      case 'center': return pw.TextAlign.center;
      case 'right': return pw.TextAlign.right;
      case 'justify': return pw.TextAlign.justify;
      default: return pw.TextAlign.left;
    }
  }

  static pw.TextStyle _getStyle({
    required bool bold,
    required bool italic,
    required bool underline,
    required double fontSize,
    required pdf.PdfColor color,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
      decoration:
          underline ? pw.TextDecoration.underline : pw.TextDecoration.none,
      color: color,
      lineSpacing: 8,
    );
  }


  static Future<void> generateSamplePreview(FormTemplate template) async {
    final sampleStudent = Student(
      id: 'sample_id',
      name: 'John Doe',
      fatherName: 'Robert Doe',
      className: '10th',
      phoneNumber: '0300-1112223',
      altNumber: '0345-0000000',
      dob: '2010-01-01',
      admissionDate: '2024-03-23',
      status: 'Active',
    );

    await generateAndPrintForm(student: sampleStudent, template: template);
  }
}
