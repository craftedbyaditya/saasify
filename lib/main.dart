import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/strings.dart';
import 'package:saasify_lite/constants/theme.dart';
import 'package:saasify_lite/gServices/g_sheet_services.dart';
import 'package:saasify_lite/screens/customers/add_customer_screen.dart';
import 'package:saasify_lite/screens/dashboard/dashboard_screen.dart';
import 'package:saasify_lite/screens/inventory/add_new_item.dart';
import 'package:saasify_lite/screens/pos/checkout_screen.dart';
import 'package:saasify_lite/screens/pos/payment_screen.dart';
import 'package:saasify_lite/screens/pos/pos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GSheetsService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/new-bill': (context) => PosScreen(), // Define NewBillScreen
        '/add-new-item': (context) => const AddNewItemScreen(),
        '/payment':
            (context) =>
                const PaymentScreen(selectedProducts: [], totalAmount: 00.00),
        '/checkout':
            (context) =>
                const CheckoutScreen(selectedProducts: [], totalAmount: 00.00),
        '/add-customers':
            (context) => AddCustomerScreen(), // Define CustomersScreen
      },
    );
  }
}
