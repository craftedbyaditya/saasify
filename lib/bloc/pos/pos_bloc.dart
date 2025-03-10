import 'package:supabase_flutter/supabase_flutter.dart';

class PosBloc {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('items').select();

      return response.map((product) {
        return {
          'name': product['name'] ?? '',
          'description': product['description'] ?? '',
          'amount': product['price'] ?? 0.0,
          'quantity': 0,
        };
      }).toList();
        } catch (e) {
      print('❗ Error fetching products: $e');
      return [];
    }
  }
}