import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:soroban_app/problem_generation/division.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';

class SheetService {
  Future<Uint8List> createDivisionSheet() async {
    final generator = DivisionProblemSet();
    final baseSpec = DivisionSpec(
      probCount: 15,
      digitCount: 8,
      difficulty: "1kyuu",
    );

    final problems = generator.generateProblems(base: baseSpec);
    final abacusFont = pw.Font.ttf(await rootBundle.load("assets/abacus5.ttf"));

    final pdf = pw.Document();

    pw.Widget buildVerticalProblemTable(
      String title,
      List<DivisionProblem> problems,
      int startNumber,
    ) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder(
              top: const pw.BorderSide(width: 2, color: PdfColors.black),
              left: const pw.BorderSide(width: 2, color: PdfColors.black),
              right: const pw.BorderSide(width: 2, color: PdfColors.black),
              bottom: const pw.BorderSide(width: 2, color: PdfColors.black),
              horizontalInside: const pw.BorderSide(
                width: 0.5,
                color: PdfColors.black,
              ),
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(30), // problem number
              1: const pw.FlexColumnWidth(), // dividend
              2: const pw.FixedColumnWidth(20), // ÷
              3: const pw.FlexColumnWidth(), // divisor
              4: const pw.FixedColumnWidth(20), // =
              5: const pw.FixedColumnWidth(30), // answer space
            },
            children: [
              for (var i = 0; i < problems.length; i++)
                pw.TableRow(
                  children: [
                    // Problem number cell (border on right)
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(8.0),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(
                            width: 0.5,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      child: pw.Text(
                        '${startNumber + i}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),

                    // Dividend (border on right)
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.only(top: 10.0),
                      decoration: const pw.BoxDecoration(),
                      child: pw.Text(
                        problems[i].formattedDividend.toString(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    // ÷ (no side borders)
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.only(top: 9.0),
                      child: pw.Text(
                        '/',
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    // Divisor (border on right)
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.only(top: 10.0),
                      decoration: const pw.BoxDecoration(),
                      child: pw.Text(
                        problems[i].formattedDivisor.toString(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    // = (no side borders)
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(8.0),
                      child: pw.Text(
                        '=',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    // Answer placeholder (last cell, no right border needed because table border handles it)
                    pw.SizedBox(height: 25),
                  ],
                ),
            ],
          ),
        ],
      );
    }

    // Problem page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20.0),
            child: pw.Column(
              children: [
                pw.Text(
                  'Division Practice Problems',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                buildVerticalProblemTable(
                  'Problems 1-7',
                  problems.sublist(0, 7),
                  1,
                ),
                pw.SizedBox(height: 20),
                buildVerticalProblemTable(
                  'Problems 8-15',
                  problems.sublist(7, 15),
                  8,
                ),
              ],
            ),
          );
        },
      ),
    );

    // Answer sheet page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20.0),
            child: pw.Column(
              children: [
                pw.Text(
                  'Answer Sheet',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                _buildAnswerTable(problems),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildAnswerTable(List<DivisionProblem> problems) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.0),
      children: [
        // Header row
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              color: PdfColors.grey200,
              child: pw.Center(
                child: pw.Text(
                  'Problem #',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8.0),
              color: PdfColors.grey200,
              child: pw.Center(
                child: pw.Text(
                  'Quotient',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        // Answer rows
        ...problems.asMap().entries.map((entry) {
          final index = entry.key;
          final problem = entry.value;
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Center(child: pw.Text('${index + 1}')),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Center(child: pw.Text(problem.quotient.toString())),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}

void main() {
  runApp(const PdfPreviewApp());
}

class PdfPreviewApp extends StatelessWidget {
  const PdfPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Preview Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('PDF Preview')),
        body: PdfPreview(
          build: (format) async {
            final service = SheetService();
            return service.createDivisionSheet(); // generates the Uint8List
          },
        ),
      ),
    );
  }
}
