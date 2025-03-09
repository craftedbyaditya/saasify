import 'package:flutter/material.dart';
import 'package:saasify_lite/widgets/custom_button.dart';
import 'package:saasify_lite/widgets/custom_popup.dart';
import '../../bloc/inventory/add_item_bloc.dart';
import '../../constants/dimensions.dart';
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
  bool _isLoading = false;

  void _addItem() async {
    final productName = _productNameController.text;
    final description = _descriptionController.text;
    final price = _priceController.text;

    if (productName.isEmpty || description.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('All fields are mandatory')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _addItemBloc.addItem(
      productName: productName,
      description: description,
      price: price,
    );

    setState(() {
      _isLoading = false;
    });

    // Clear the text fields after adding the item
    _productNameController.clear();
    _descriptionController.clear();
    _priceController.clear();

    // Show a success message or navigate to another screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomOverlayDialog(
          title: 'Success',
          content: 'Item added successfully',
          primaryButtonText: 'OK',
          onPrimaryPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            Navigator.of(
              context,
            ).pop(); // Navigate back to the dashboard screen
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _productNameController,
              label: 'Product Name',
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            CustomTextField(controller: _priceController, label: 'Price'),
            const SizedBox(height: AppDimensions.marginLarge),
            (_isLoading)
                ? Center(child: CircularProgressIndicator())
                : CustomElevatedButton(text: 'Add Item', onTap: _addItem),
          ],
        ),
      ),
    );
  }
}
