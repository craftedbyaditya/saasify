import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, String>> fetchUserData() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get data from Supabase
      final userData =
          await _supabase
              .from('users')
              .select()
              .eq('id', currentUser.id)
              .single();

      // Cache the data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userData['name'] ?? '');
      await prefs.setString('userEmail', currentUser.email ?? '');
      await prefs.setString('userPhone', userData['mobile'] ?? '');
      await prefs.setString('businessName', userData['business_name'] ?? '');

      return {
        'name': userData['name'] ?? '',
        'email': currentUser.email ?? '',
        'phone': userData['mobile'] ?? '',
        'businessName': userData['business_name'] ?? '',
      };
    } catch (e) {
      // If user data doesn't exist, create an empty record
      if (e is PostgrestException && e.code == 'PGRST116') {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser != null) {
          try {
            await _supabase.from('users').insert({
              'id': currentUser.id,
              'email': currentUser.email,
              'name': '',
              'mobile': '',
              'business_name': '',
              'created_at': DateTime.now().toIso8601String(),
            });
          } catch (insertError) {
            print('Error creating user record: $insertError');
          }
        }
      }

      // Fallback to cached data if network fails
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString('userName') ?? '',
        'email': prefs.getString('userEmail') ?? '',
        'phone': prefs.getString('userPhone') ?? '',
        'businessName': prefs.getString('businessName') ?? '',
      };
    }
  }

  static Future<void> updateUserData({
    required String name,
    required String email,
    required String phone,
    required String businessName,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update data in Supabase
      final response =
          await _supabase.from('users').upsert({
            'id': currentUser.id,
            'email': email, // Added email field
            'name': name,
            'mobile': phone,
            'business_name': businessName,
          }).select();

      print('Supabase update response: $response');

      // Cache the updated data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);
      await prefs.setString('userPhone', phone);
      await prefs.setString('businessName', businessName);
    } catch (e) {
      print('Error updating user data: $e');
      if (e is PostgrestException) {
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      print('Error full details: ${e.toString()}');
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }
}

class ProfileBloc {
  Future<Map<String, String>> getUserData() async {
    return ProfileService.fetchUserData();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String businessName,
  }) async {
    await ProfileService.updateUserData(
      name: name,
      email: email,
      phone: phone,
      businessName: businessName,
    );
  }
}
