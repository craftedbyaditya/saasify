import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class BillPdfGenerator {
  Future<File> generateBill({
    required List<Map<String, dynamic>> selectedProducts,
    required double totalAmount,
    required String customerName,
    required String customerContact,
    required String paymentOption,
    required double paidAmount,
    required double subtotalAmount,
    required double discountAmount,
    required double discountPercent,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final invoiceNumber =
        'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(7)}';

    final balanceAmount = totalAmount - paidAmount;

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Business Name & Contact
                pw.Text(
                  'BUSINESS NAME',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Customer Name: $customerName'),
                        pw.SizedBox(height: 5),
                        pw.Text('Contact: +91 $customerContact'),
                        pw.SizedBox(height: 5),
                        pw.Text('Date: ${dateFormat.format(now)}'),
                        pw.SizedBox(height: 5),
                      ],
                    ),
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Invoice No: $invoiceNumber'),
                        pw.SizedBox(height: 5),
                        pw.Text('Payment Mode: $paymentOption'),
                        pw.SizedBox(height: 5),
                        if (paymentOption.contains('Half amount') ||
                            paymentOption.contains('Pay later'))
                          _buildPriceRow(
                            'Balance Amount: ',
                            (totalAmount - paidAmount).toStringAsFixed(2),
                          ),
                        pw.SizedBox(height: 5),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 300,
                          child: pw.Text(
                            'Items',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        pw.SizedBox(width: 80),
                        pw.Text('Qty', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),

                    pw.Text('Price', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 2),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      selectedProducts.map((product) {
                        return pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Container(
                                  width: 300,
                                  child: pw.Text(
                                    product['name'] ?? 'Unknown Item',
                                    style: const pw.TextStyle(fontSize: 12),
                                  ),
                                ),
                                pw.SizedBox(width: 85),
                                pw.Text(
                                  product['quantity'].toString(),
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ],
                            ),

                            pw.Text(
                              '${(product['amount'] * product['quantity']).toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                ),
                pw.SizedBox(height: 2),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 5),

                // Summary
                pw.Container(
                  width: 250,
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(left: 300),
                  child: pw.Column(
                    children: [
                      _buildSummaryRow(
                        'Subtotal:',
                        '${subtotalAmount.toStringAsFixed(2)}',
                      ),
                      if (discountAmount > 0) ...[
                        _buildSummaryRow(
                          'Discount (${discountPercent.toStringAsFixed(1)}%):',
                          '${discountAmount.toStringAsFixed(2)}',
                        ),
                      ],
                      pw.Container(
                        margin: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Divider(),
                      ),
                      _buildSummaryRow(
                        'Total Amount:',
                        '${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                      if (paymentOption == 'Partial Payment' ||
                          paymentOption == 'Pay Later') ...[
                        _buildSummaryRow(
                          'Paid Amount:',
                          '₹${paidAmount.toStringAsFixed(2)}',
                        ),
                        _buildSummaryRow(
                          'Balance Due:',
                          '₹${balanceAmount.toStringAsFixed(2)}',
                        ),
                      ],
                    ],
                  ),
                ),

                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 20),

                      pw.Text(
                        'Thank You For Supporting Our Business!',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('Contact Us : +91 8329197228'),
                      pw.SizedBox(height: 20),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),
              ],
            ),
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final file = File('${outputDir.path}/$customerName-Invoice.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Helper function to create formatted rows
  pw.Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    // pw.Color? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              // color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
