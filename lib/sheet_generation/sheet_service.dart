import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:soroban_app/problem_generation/division.dart';
import 'package:soroban_app/problem_generation/division_source.dart';
import 'package:soroban_app/problem_generation/generation_spec.dart';
import 'package:soroban_app/problem_generation/multiplication.dart';
import 'package:soroban_app/problem_generation/multiplication_source.dart';

typedef ProblemBuilder<TProblem, TSpec> =
    TProblem Function(TSpec spec, ProblemType type);

class SheetService {
  Future<Uint8List> creatMultDivSheet() async {
    final baseDivSpec = DivisionSpec(
      probCount: 15,
      digitCount: 8,
      difficulty: "1kyuu",
    );

    final divisionSet = ProblemSet<DivisionProblem, DivisionSpec>(
      builder: (spec, type) =>
          DivisionProblem(spec: divSpecFromType(spec, type)),
      source: divisionSource,
    );

    final divProblems = divisionSet.generateProblems(base: baseDivSpec);

    final baseMultSpec = MultiplicationSpec(
      probCount: 15,
      digitCount: 9,
      difficulty: "1kyuu",
      integerMultiplier: false,
    );

    final multiplicationSet =
        ProblemSet<MultiplicationProblem, MultiplicationSpec>(
          builder: (spec, type) =>
              MultiplicationProblem(spec: multSpecFromType(spec, type)),
          source: multiplicationSource,
        );

    final multProblems = multiplicationSet.generateProblems(base: baseMultSpec);

    final abacusFont = pw.Font.ttf(await rootBundle.load("assets/abacus5.ttf"));

    final pdf = pw.Document();

    pw.Widget buildVerticalProblemTable(
      String title,
      var problems,
      int startNumber, {
      String operator = '/',
    }) {
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
                      padding: const pw.EdgeInsets.symmetric(vertical: 5),
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
                      padding: const pw.EdgeInsets.only(top: 7),
                      decoration: const pw.BoxDecoration(),
                      child: pw.Text(
                        problems[i].formattedFirst.toString(),
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
                      padding: const pw.EdgeInsets.only(top: 7),
                      child: pw.Text(
                        operator,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    // Divisor (border on right)
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      padding: const pw.EdgeInsets.only(top: 7),
                      decoration: const pw.BoxDecoration(),
                      child: pw.Text(
                        problems[i].formattedSecond.toString(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.only(top: 7),
                      child: pw.Text(
                        '=',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          font: abacusFont,
                        ),
                      ),
                    ),

                    // Answer placeholder (last cell, no right border needed because table border handles it)
                    pw.Expanded(child: pw.SizedBox(height: 25)),
                  ],
                ),
            ],
          ),
        ],
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Multiplication Practice Problems',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      buildVerticalProblemTable(
                        'Problems 1-7',
                        multProblems.sublist(0, 7),
                        1,
                        operator: '*',
                      ),
                      pw.SizedBox(height: 20),
                      buildVerticalProblemTable(
                        'Problems 8-15',
                        multProblems.sublist(7, 15),
                        8,
                        operator: '*',
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),

                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                        divProblems.sublist(0, 7),
                        1,
                        operator: '/',
                      ),
                      pw.SizedBox(height: 20),
                      buildVerticalProblemTable(
                        'Problems 8-15',
                        divProblems.sublist(7, 15),
                        8,
                        operator: '/',
                      ),
                    ],
                  ),
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
                _buildAnswerTable(divProblems),
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
            return service.creatMultDivSheet(); // generates the Uint8List
          },
        ),
      ),
    );
  }
}
