import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:saasify_lite/screens/authentication/authentication_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolTest(
    'Add customer flow test',
    config: PatrolTesterConfig(
      settleTimeout: const Duration(seconds: 10),
      existsTimeout: const Duration(seconds: 10),
    ),
    ($) async {
      // Launch the app with your preferred UI style
      await $.pumpWidget(
        MaterialApp(
          home: const AuthScreen(),
          theme: ThemeData(
            cardTheme: CardTheme(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
      );
      await $.pumpAndSettle();

      // Test data
      const testName = 'Test Customer';
      const testContact = '1234567890';

      // Verify we're on the login screen and perform login
      expect($('Login'), findsOneWidget);

      // Enter login credentials
      await $(TextField).at(0).enterText('your-test-email@example.com');
      await $.pumpAndSettle();
      await $(TextField).at(1).enterText('your-test-password');
      await $.pumpAndSettle();

      // Tap login button
      await $(ElevatedButton).containing(Text('Login')).tap();
      await $.pumpAndSettle();

      // Wait for dashboard to load and tap add customer
      await $(IconButton).containing(Icon(Icons.add)).tap();
      await $.pumpAndSettle();

      // Fill customer details
      await $(
        TextField,
      ).containing(RegExp('name', caseSensitive: false)).enterText(testName);
      await $.pumpAndSettle();
      await $(TextField)
          .containing(RegExp('contact', caseSensitive: false))
          .enterText(testContact);
      await $.pumpAndSettle();

      // Save customer
      await $(ElevatedButton).containing(Text('Save')).tap();
      await $.pumpAndSettle();

      // Verify success message
      expect($(SnackBar), findsOneWidget);

      // Navigate to customers list
      await $(ListTile).containing(Text('Customers')).tap();
      await $.pumpAndSettle();

      // Verify the new customer appears
      expect($(Text).containing(testName), findsOneWidget);
      expect($(Text).containing(testContact), findsOneWidget);
    },
  );
}
