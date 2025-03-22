import 'package:supabase_flutter/supabase_flutter.dart';

class AddItemService {
  static Future<void> addItem({
    required String productName,
    required String description,
    required String price,
    String? productId,
    bool? isEdit,
  }) async {
    final supabase = Supabase.instance.client;
    if (!isEdit!) {
      final response = await supabase.from('items').insert({
        'name': productName,
        'description': description,
        'price': double.parse(price),
        'user_id': supabase.auth.currentUser?.id,
      });
      if (response is List && response.isEmpty) {
        throw Exception('Failed to add item. No data was inserted.');
      }
    } else {
      final response = await supabase.from('items').update({
        'id': productId,
        'name': productName,
        'description': description,
        'price': double.parse(price),
        'user_id': supabase.auth.currentUser?.id,
      });
      if (response is List && response.isEmpty) {
        throw Exception('Failed to update item. No data was updated.');
      }
    }
  }
}

class AddItemBloc {
  Future<void> addItem({
    required String productName,
    required String description,
    required String price,
    bool? isEdit,
    String? productId,
  }) async {
    await AddItemService.addItem(
      productName: productName,
      description: description,
      price: price,
      isEdit: isEdit,
      productId: productId,
    );
  }
}
