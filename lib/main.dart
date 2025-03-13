import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/strings.dart';
import 'package:saasify_lite/constants/theme.dart';
import 'package:saasify_lite/screens/authentication/authentication_screen.dart';
import 'package:saasify_lite/screens/customers/add_customer_screen.dart';
import 'package:saasify_lite/screens/dashboard/dashboard_screen.dart';
import 'package:saasify_lite/screens/inventory/add_new_item.dart';
import 'package:saasify_lite/screens/pos/checkout_screen.dart';
import 'package:saasify_lite/screens/pos/pos_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cache/cache_servives.dart' show CacheService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dexuhsqkmdvisfhwjbwp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRleHVoc3FrbWR2aXNmaHdqYndwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE2MjczMTAsImV4cCI6MjA1NzIwMzMxMH0.Th0FU0J6B1P8FmI7DlV3l9XmLNcbsNG5rPFbubTdAac',
  );
  final isLoggedIn = await CacheService().isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => (isLoggedIn) ? DashboardScreen() : AuthScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/new-bill': (context) => PosScreen(),
        '/add-new-item': (context) => const AddNewItemScreen(),
        '/checkout': (context) => const CheckoutScreen(checkoutData: [], totalAmount: 00.00),
        '/add-customers': (context) => AddCustomerScreen(),
        // Define CustomersScreen
      },
    );
  }
}
