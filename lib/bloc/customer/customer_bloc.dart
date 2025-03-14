import 'package:supabase_flutter/supabase_flutter.dart';

class AddCustomerService {
  static Future<void> addItem({
    required String userName,
    required String userContact,
  }) async {
    final supabase = Supabase.instance.client;

    // Check if user is authenticated
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      // First check if the user exists in the users table
      final userExists =
          await supabase
              .from('users')
              .select('id')
              .eq('id', currentUser.id)
              .maybeSingle();

      if (userExists == null) {
        // Create the user if they don't exist
        await supabase.from('users').insert({
          'id': currentUser.id,
          'email': currentUser.email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Check if the mobile number already exists for this specific user
      final existingCustomer =
          await supabase
              .from('customers')
              .select('id')
              .eq('mobile', userContact)
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (existingCustomer != null) {
        throw Exception('You already have a customer with this mobile number');
      }

      // Now add the customer
      await supabase.from('customers').insert({
        'name': userName,
        'email': '',
        'mobile': userContact,
        'address': '',
        'created_at': DateTime.now().toIso8601String(),
        'user_id': currentUser.id,
      });
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception('Database error occurred. Please try again.');
      }
      rethrow; // Re-throw the original exception if it's our custom one
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllCustomers() async {
    final supabase = Supabase.instance.client;

    // Check if user is authenticated
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final customers = await supabase
          .from('customers')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return customers.map((customer) {
        return {
          'id': customer['id'],
          'name': customer['name'],
          'email': customer['email'],
          'contact': customer['mobile'],
          'address': customer['address'],
          'createdAt': customer['created_at'],
        };
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch customers: ${e.toString()}');
    }
  }
}

class AddCustomerBloc {
  Future<String?> addItem({
    required String userName,
    required String userContact,
  }) async {
    try {
      await AddCustomerService.addItem(
        userName: userName,
        userContact: userContact,
      );
      return null; // No error
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllCustomers() async {
    try {
      return await AddCustomerService.fetchAllCustomers();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
