import 'package:flutter/material.dart';
import 'package:saasify_lite/bloc/customer/customer_bloc.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';
import 'package:saasify_lite/constants/dimensions.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userContactController = TextEditingController();
  final AddCustomerBloc _addCustomerBloc = AddCustomerBloc();
  String? _errorMessage;

  void _addCustomer() async {
    final userName = _userNameController.text;
    final userContact = _userContactController.text;

    final error = await _addCustomerBloc.addItem(
      userName: userName,
      userContact: userContact,
    );

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
      // Clear the text fields after adding the customer
      _userNameController.clear();
      _userContactController.clear();
      // Show a success message or navigate to another screen
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Customer added successfully')));
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _userNameController,
              label: 'Customer Name',
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            CustomTextField(
              controller: _userContactController,
              label: 'Mobile Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _addCustomer,
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
}
