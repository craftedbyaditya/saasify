import 'package:flutter/material.dart';
import '../../bloc/inventory/add_item_bloc.dart';
import '../../constants/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';

class AddNewItemScreen extends StatefulWidget {
  const AddNewItemScreen({super.key});

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final AddItemBloc _addItemBloc = AddItemBloc();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isValid = false;
  String? _nameError;
  String? _descriptionError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _productNameController.addListener(_validateFields);
    _descriptionController.addListener(_validateFields);
    _priceController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final name = _productNameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();

    setState(() {
      _isValid =
          name.isNotEmpty &&
          description.isNotEmpty &&
          price.isNotEmpty &&
          double.tryParse(price) != null;
    });
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _descriptionError = null;
      _priceError = null;

      if (_productNameController.text.trim().isEmpty) {
        _nameError = 'Product name is required';
        isValid = false;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _descriptionError = 'Description is required';
        isValid = false;
      }

      if (_priceController.text.trim().isEmpty) {
        _priceError = 'Price is required';
        isValid = false;
      } else {
        final price = double.tryParse(_priceController.text.trim());
        if (price == null || price <= 0) {
          _priceError = 'Enter a valid price';
          isValid = false;
        }
      }
    });
    return isValid;
  }

  Future<void> _addItem() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      await _addItemBloc.addItem(
        productName: _productNameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
      );
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Failed to add item. Please try again.');
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
            content: const Text('Item added successfully!'),
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
      appBar: CustomAppBar(title: 'Add Item'),
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
                    'Item Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the item details below',
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
                          controller: _productNameController,
                          label: 'Product Name',
                          prefixIcon: const Icon(Icons.inventory_2_outlined),
                          onChanged: (_) => setState(() => _nameError = null),
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          prefixIcon: const Icon(Icons.description_outlined),
                          onChanged:
                              (_) => setState(() => _descriptionError = null),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                        CustomTextField(
                          controller: _priceController,
                          label: 'Price',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isValid && !_isLoading ? _addItem : null,
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
                                'Add Item',
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
