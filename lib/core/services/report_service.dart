import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportService {
  Future<Uint8List> buildPdf({required String title, required List<List<String>> rows, required String dateRange}) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (_) => pw.Container(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Row(children: [pw.Expanded(child: pw.Text('MOVBOT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))), pw.Text(dateRange)])),
      footer: (ctx) => pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}')),
      build: (_) => [pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 12), pw.Table.fromTextArray(data: rows, headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold), cellPadding: const pw.EdgeInsets.all(5))],
    ));
    return doc.save();
  }

  Future<Uint8List> buildXlsx({required String sheetName, required List<List<String>> rows}) async {
    final book = Excel.createExcel();
    final sheet = book[sheetName];
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r)).value = TextCellValue(rows[r][c]);
      }
    }
    final bytes = book.encode();
    if (bytes == null) throw StateError('XLSX generation failed');
    return Uint8List.fromList(bytes);
  }

  Future<void> printPdf(Uint8List bytes) => Printing.layoutPdf(onLayout: (_) async => bytes);
}
