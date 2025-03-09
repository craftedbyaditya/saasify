import 'package:saasify_lite/gServices/g_sheet_services.dart';

class PosBloc {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    if (!GSheetsService.isInitialized) {
      await GSheetsService.init();
    }

    final products = await GSheetsService.itemSheet!.values.allRows();
    return products.skip(1).map((row) {
      return {
        'name': row[1],
        'description': row[2],
        'amount': double.tryParse(row[3]) ?? 0.0,
        'quantity': 0,
      };
    }).toList();
  }
}
