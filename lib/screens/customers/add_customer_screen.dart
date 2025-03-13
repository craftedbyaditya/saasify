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
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isValid = false;
  String? _nameError;
  String? _contactError;

  @override
  void initState() {
    super.initState();
    _userNameController.addListener(_validateFields);
    _userContactController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userContactController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final name = _userNameController.text.trim();
    final contact = _userContactController.text.trim();

    setState(() {
      _isValid = name.length >= 3 && contact.length == 10;
    });
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _contactError = null;

      if (_userNameController.text.trim().isEmpty) {
        _nameError = 'Customer name is required';
        isValid = false;
      } else if (_userNameController.text.trim().length < 3) {
        _nameError = 'Name must be at least 3 characters';
        isValid = false;
      }

      if (_userContactController.text.trim().isEmpty) {
        _contactError = 'Mobile number is required';
        isValid = false;
      } else if (!RegExp(
        r'^\d{10}$',
      ).hasMatch(_userContactController.text.trim())) {
        _contactError = 'Enter a valid 10-digit mobile number';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _addCustomer() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final error = await _addCustomerBloc.addItem(
        userName: _userNameController.text.trim(),
        userContact: _userContactController.text.trim(),
      );

      if (error != null) {
        _showErrorDialog(error);
      } else {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF006d77)),
                const SizedBox(width: 8),
                const Text('Success'),
              ],
            ),
            content: const Text('Customer added successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.of(context).pop(); // Return to dashboard
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Error'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Add Customer',
          style: TextStyle(
            color: Color(0xFF006d77),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006d77)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the customer\'s details below',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _userNameController,
                          label: 'Customer Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          onChanged: (_) => setState(() => _nameError = null),
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        CustomTextField(
                          controller: _userContactController,
                          label: 'Mobile Number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          onChanged:
                              (_) => setState(() => _contactError = null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isValid && !_isLoading ? _addCustomer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006d77),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Add Customer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
