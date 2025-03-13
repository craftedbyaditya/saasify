import 'package:supabase_flutter/supabase_flutter.dart';

class PosBloc {
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final supabase = Supabase.instance.client;

    // Get logged-in user's ID
    final user = supabase.auth.currentUser;
    print('user $user');
    if (user == null) {
      print('❗ User not logged in');
      return [];
    }

    try {
      final response = await supabase
          .from('items')
          .select()
          .eq('user_id', user.id) // Filter by logged-in user
          .order('created_at', ascending: false); // Optional: Sort by latest

      return response.map((product) {
        return {
          'name': product['name'] ?? '',
          'description': product['description'] ?? '',
          'amount': product['price'] ?? 0.0,
          'quantity': 0,
          'product_image': product['product_image'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❗ Error fetching user-specific products: $e');
      return [];
    }
  }
}
