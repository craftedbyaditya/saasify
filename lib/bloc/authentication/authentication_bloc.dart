import 'package:flutter/material.dart';
import 'package:saasify_lite/cache/cache_servives.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationBloc {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> authenticate({
    required String email,
    required String password,
    required bool isSignUp,
    required BuildContext context,
    required TextEditingController? usernameController,
    required Function(bool) setLoading,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setLoading(true);

    try {
      if (isSignUp) {
        // 1. Sign up the user with Supabase Auth
        final response = await _supabase.auth.signUp(
          email: email.trim(),
          password: password.trim(),
        );

        if (response.user != null) {
          // 2. Create user record in the users table
          await _supabase.from('users').insert({
            'id': response.user!.id, // Use the auth user's UUID
            'name': usernameController?.text.trim(),
            'email': email.trim(),
            'created_at': DateTime.now().toIso8601String(),
          });

          // 3. Save login details and navigate
          await CacheService().saveLoginDetails(
            email: email.trim(),
            password: password.trim(),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        final response = await _supabase.auth.signInWithPassword(
          email: email.trim(),
          password: password.trim(),
        );

        if (response.user != null) {
          await CacheService().saveLoginDetails(
            email: email.trim(),
            password: password.trim(),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on PostgrestException catch (e) {
      print('❗ Database Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: ${e.message}')),
      );
    } catch (e) {
      print('❗ Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setLoading(false);
    }
  }
}
