import 'dart:convert';
import 'package:flutter/services.dart';

class GSheetsConfig {
  static late Map<String, dynamic> credentials;
  static late String spreadsheetId;

  static Future<void> loadConfig() async {
    final configData = await rootBundle.loadString('assets/config.json');
    final jsonData = jsonDecode(configData);

    credentials = jsonData['gsheets_credentials'];
    // Ensure the `private_key` has correct line breaks
    credentials['private_key'] =
        (credentials['private_key'] as String).replaceAll(r'\n', '\n');

    spreadsheetId = jsonData['spreadsheet_id'];
  }
}