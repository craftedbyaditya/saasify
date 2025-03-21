import 'dart:io';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as universal_html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class BillPdfGenerator {
  Future<void> generateBill({
    required List<Map<String, dynamic>> selectedProducts,
    required double totalAmount,
    required String customerName,
    required String customerContact,
    required String paymentOption,
    required double paidAmount,
    required double subtotalAmount,
    required double discountAmount,
    required double discountPercent,
    required BuildContext context,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final invoiceNumber =
        'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(7)}';

    final balanceAmount = totalAmount - paidAmount;

    final businessDetails = await _getBusinessDetails();
    final businessName = businessDetails['businessName']?.trim();
    final contactNumber = businessDetails['phone']?.trim();

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Business Name & Contact
                if (businessName?.isNotEmpty ?? false)
                  pw.Text(
                    businessName!,
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
                        subtotalAmount.toStringAsFixed(2),
                      ),
                      if (discountAmount > 0) ...[
                        _buildSummaryRow(
                          'Discount (${discountPercent.toStringAsFixed(1)}%):',
                          discountAmount.toStringAsFixed(2),
                        ),
                      ],
                      pw.Container(
                        margin: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Divider(),
                      ),
                      _buildSummaryRow(
                        'Total Amount:',
                        totalAmount.toStringAsFixed(2),
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

                      if (contactNumber?.isNotEmpty ?? false)
                        pw.Text(
                          'Contact Us : $contactNumber',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Thank You For Supporting Our Business!',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),
              ],
            ),
      ),
    );

    try {
      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web platform handling
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.document.createElement('a') as html.AnchorElement
              ..href = url
              ..style.display = 'none'
              ..download = 'invoice_$invoiceNumber.pdf';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        // Show success dialog with clean UI
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                backgroundColor: Colors.white,
                title: Text('Success'),
                content: Text('Invoice has been downloaded successfully.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        // Mobile platform handling
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/invoice_$invoiceNumber.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        await Share.shareFiles([filePath], text: 'Invoice $invoiceNumber');
      }
    } catch (e) {
      // Show error in a clean, minimal style
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _showSuccessDialog(
    BuildContext context,
    VoidCallback onShare,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Invoice Generated Successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your invoice is ready to be shared',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {
                        onShare();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      icon: Icon(
                        Icons.share_rounded,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        'Share Invoice',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, String>> _getBusinessDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'businessName': prefs.getString('businessName') ?? '',
      'phone': prefs.getString('userPhone') ?? '',
    };
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
