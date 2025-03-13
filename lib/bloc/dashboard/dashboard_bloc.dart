// import 'package:supabase_flutter/supabase_flutter.dart';

// class DashboardStats {
//   final double totalAmount;
//   final double pendingAmount;
//   final int totalOrders;
//   final int totalCustomers;

//   DashboardStats({
//     required this.totalAmount,
//     required this.pendingAmount,
//     required this.totalOrders,
//     required this.totalCustomers,
//   });
// }

// class DashboardService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   Future<DashboardStats> getStats() async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) {
//         throw Exception('User not logged in');
//       }

//       final userId = user.id;

//       // Fetch all orders for the logged-in user
//       final ordersResponse = await _supabase
//           .from('order_history')
//           .select('total_amount, balance_amount')
//           .eq('user_id', userId);

//       double totalAmount = 0;
//       double pendingAmount = 0;
//       int totalOrders = ordersResponse.length;

//       for (var order in ordersResponse) {
//         totalAmount += (order['total_amount'] as num?)?.toDouble() ?? 0.0;
//         pendingAmount += (order['balance_amount'] as num?)?.toDouble() ?? 0.0;
//       }

//       // Fetch total customers count
//       final customersResponse = await _supabase
//           .from('customers')
//           .select('id')
//           .eq('user_id', userId);

//       int totalCustomers = customersResponse.length;

//       return DashboardStats(
//         totalAmount: totalAmount,
//         pendingAmount: pendingAmount,
//         totalOrders: totalOrders,
//         totalCustomers: totalCustomers,
//       );
//     } catch (e) {
//       print('❗ Error fetching dashboard stats: $e');
//       return DashboardStats(
//         totalAmount: 0,
//         pendingAmount: 0,
//         totalOrders: 0,
//         totalCustomers: 0,
//       );
//     }
//   }
// }
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardStats {
  final double totalAmount;
  final double pendingAmount;
  final int totalOrders;
  final int totalCustomers;

  DashboardStats({
    required this.totalAmount,
    required this.pendingAmount,
    required this.totalOrders,
    required this.totalCustomers,
  });
}

class DashboardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<DashboardStats> getStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final userId = user.id;

      // Fetch all orders for the logged-in user
      final ordersResponse = await _supabase
          .from('order_history')
          .select('total_amount, balance_amount')
          .eq('user_id', userId);

      double totalAmount = 0;
      double pendingAmount = 0;
      int totalOrders = ordersResponse.length;

      for (var order in ordersResponse) {
        totalAmount += (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        pendingAmount += (order['balance_amount'] as num?)?.toDouble() ?? 0.0;
      }

      // Fetch total customers count
      final customersResponse = await _supabase
          .from('customers')
          .select()
          .eq('user_id', userId);

      return DashboardStats(
        totalAmount: totalAmount,
        pendingAmount: pendingAmount,
        totalOrders: totalOrders,
        totalCustomers: customersResponse.length,
      );
    } catch (e) {
      print('❗ Error fetching dashboard stats: $e');
      rethrow; // Propagate the error to handle it in the UI
    }
  }
}
