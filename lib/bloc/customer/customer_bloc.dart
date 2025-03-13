import 'package:supabase_flutter/supabase_flutter.dart';

class AddCustomerService {
  static Future<void> addItem({
    required String userName,
    required String userContact,
  }) async {
    final supabase = Supabase.instance.client;

    // Check if the mobile number already exists
    final existingCustomer =
        await supabase
            .from('customers')
            .select('id')
            .eq('mobile', userContact) // Change 'contact' to 'mobile'
            .maybeSingle();

    if (existingCustomer != null) {
      throw Exception('Customer already exists');
    }

    await supabase.from('customers').insert({
      'name': userName,
      'email': '',

      'mobile': userContact,
      'address': '',
      'created_at': DateTime.now().toIso8601String(),
      'user_id': supabase.auth.currentUser?.id,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchAllCustomers() async {
    final supabase = Supabase.instance.client;

    final customers = await supabase.from('customers').select();

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
    return await AddCustomerService.fetchAllCustomers();
  }
}
