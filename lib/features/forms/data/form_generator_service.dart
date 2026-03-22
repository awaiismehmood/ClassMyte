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
        .replaceAll('[schoolName]', template.schoolName);

    doc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header based on Alignment
                _buildHeader(template, logoImage),
                
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 30),

                // Content
                pw.Text(
                  processedContent,
                  style: pw.TextStyle(fontSize: 14, lineSpacing: 8, color: pdf.PdfColors.black),
                ),

                pw.Spacer(),

                // Dynamic Signatures
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
                if (template.footer.isNotEmpty) ...[
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

  static pw.Widget _buildHeader(FormTemplate template, pw.ImageProvider? logo) {
    final titleInfo = pw.Column(
      crossAxisAlignment: template.logoAlignment == 'center' ? pw.CrossAxisAlignment.center : (template.logoAlignment == 'left' ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end),
      children: [
        pw.Text(
          template.schoolName.toUpperCase(),
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          template.title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: pdf.PdfColors.grey700),
        ),
        if (template.subtitle.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            template.subtitle,
            style: pw.TextStyle(fontSize: 10, color: pdf.PdfColors.grey600),
          ),
        ],
      ],
    );

    if (logo == null) return pw.Center(child: titleInfo);

    final logoWidget = pw.Container(
      width: 70,
      height: 70,
      child: pw.Image(logo),
    );

    if (template.logoAlignment == 'center') {
      return pw.Center(
        child: pw.Column(
          children: [
            logoWidget,
            pw.SizedBox(height: 10),
            titleInfo,
          ],
        ),
      );
    } else if (template.logoAlignment == 'left') {
      return pw.Row(
        children: [
          logoWidget,
          pw.SizedBox(width: 20),
          pw.Expanded(child: titleInfo),
        ],
      );
    } else {
      return pw.Row(
        children: [
          pw.Expanded(child: titleInfo),
          pw.SizedBox(width: 20),
          logoWidget,
        ],
      );
    }
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
