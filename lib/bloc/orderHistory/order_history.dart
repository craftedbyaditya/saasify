import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> insertOrder({
    required String customerId,
    required List<Map<String, dynamic>> selectedProducts,
    required double totalAmount,
    required double paidAmount,
    required double subTotalAmount,
    required double taxAmount,
    required double discountAmount,
    required double discountPercent,
    required double balanceAmount,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    try {
      final response =
          await _supabase.from('order_history').insert({
            'id': const Uuid().v4(), // Generate UUID for unique ID
            'customer_id': customerId,
            'selected_products': selectedProducts,
            'total_amount': totalAmount,
            'paid_amount': paidAmount,
            'sub_total_amount': subTotalAmount,
            'tax_amount': taxAmount,
            'discount_amount': discountAmount,
            'discount_percent': discountPercent,
            'balance_amount': balanceAmount,
            'payment_method': paymentMethod,
            'payment_status': paymentStatus,
            'order_date': DateTime.now().toIso8601String(),
            'user_id': _supabase.auth.currentUser?.id,
          }).select(); // .execute() replaced with .select() to check response

      if (response.isNotEmpty) {
        return true; // Success
      } else {
        print('Error inserting order: Empty response');
        return false; // Failure
      }
    } catch (e) {
      print('Exception: $e');
      return false; // Ensures exception paths also return a value
    }
  }

  Future<List<Map<String, dynamic>>> loadOrders() async {
    try {
      final response = await _supabase
          .from('order_history')
          .select('*, customers(name)')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('order_date', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Error loading orders');
    }
  }

  Future<List<Map<String, dynamic>>> filterOrders(String query) async {
    try {
      final response = await _supabase
          .from('order_history')
          .select('*, customers(name)')
          .ilike('customers.name', '%$query%')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('order_date', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Error filtering orders');
    }
  }
}
