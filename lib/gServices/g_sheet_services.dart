import 'dart:convert';

import 'package:gsheets/gsheets.dart';
import 'package:saasify_lite/gServices/g_sheet_config.dart';

class GSheetsService {
  static final GSheets _gsheets = GSheets(
    jsonEncode(GSheetsConfig.credentials),
  );
  static Worksheet? userSheet;
  static Worksheet? customerSheet;
  static Worksheet? itemSheet;
  static Worksheet? inventorySheet;
  static Worksheet? orderHistorySheet;
  static bool isInitialized = false;

  static Future<void> init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(
        GSheetsConfig.spreadsheetId,
      );

      // Initialize Users worksheet
      userSheet = await _getWorkSheet(spreadsheet, title: 'Users');
      // Initialize Customers worksheet
      customerSheet = await _getWorkSheet(spreadsheet, title: 'Customers');
      // Initialize Items worksheet
      itemSheet = await _getWorkSheet(spreadsheet, title: 'Items');
      // Initialize Inventory worksheet
      inventorySheet = await _getWorkSheet(spreadsheet, title: 'Inventory');
      // Initialize Order History worksheet
      orderHistorySheet = await _getWorkSheet(
        spreadsheet,
        title: 'Order History',
      );

      // Define user worksheet headers
      final userHeaders = [
        'User ID',
        'Password',
        'Name',
        'Email',
        'Mobile',
        'Created At',
        'Updated At',
      ];

      // Insert headers only if the worksheet is empty
      if ((await userSheet!.values.row(1)).isEmpty) {
        await userSheet!.values.insertRow(1, userHeaders);
      }

      // Define customer worksheet headers
      final customerHeaders = [
        'Customer ID',
        'Name',
        'Email',
        'Mobile',
        'Address',
        'Created At',
        'Updated At',
      ];

      // Insert headers only if the worksheet is empty
      if ((await customerSheet!.values.row(1)).isEmpty) {
        await customerSheet!.values.insertRow(1, customerHeaders);
      }

      // Define item worksheet headers
      final itemHeaders = [
        'Item ID',
        'Product Name',
        'Description',
        'Price',
        'Created At',
        'Updated At',
      ];

      // Insert headers only if the worksheet is empty
      if ((await itemSheet!.values.row(1)).isEmpty) {
        await itemSheet!.values.insertRow(1, itemHeaders);
      }

      // Define inventory worksheet headers
      final inventoryHeaders = [
        'Inventory ID',
        'Item ID',
        'Quantity',
        'Location',
        'Created At',
        'Updated At',
      ];

      // Insert headers only if the worksheet is empty
      if ((await inventorySheet!.values.row(1)).isEmpty) {
        await inventorySheet!.values.insertRow(1, inventoryHeaders);
      }

      // Define order history worksheet headers
      final orderHistoryHeaders = [
        'Order ID',
        'Customer ID',
        'Item ID',
        'Quantity',
        'Total Price',
        'Order Date',
        'Status',
      ];

      // Insert headers only if the worksheet is empty
      if ((await orderHistorySheet!.values.row(1)).isEmpty) {
        await orderHistorySheet!.values.insertRow(1, orderHistoryHeaders);
      }

      isInitialized = true;
    } catch (e) {
      print('Init Error: $e');
      rethrow;
    }
  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {
      return spreadsheet.worksheetByTitle(title)!;
    }
  }
}
