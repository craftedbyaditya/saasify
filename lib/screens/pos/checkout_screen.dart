import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/dimensions.dart';
import 'package:saasify_lite/screens/pos/payment_screen.dart';
import 'package:saasify_lite/widgets/custom_button.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.selectedProducts,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _discountController = TextEditingController();
  double _discountedTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _discountedTotal = widget.totalAmount; // Initially set to original total
    _discountController.addListener(_calculateDiscountedTotal);
  }

  void _calculateDiscountedTotal() {
    final discountPercent = double.tryParse(_discountController.text) ?? 0.0;

    if (discountPercent >= 0 && discountPercent <= 100) {
      setState(() {
        _discountedTotal =
            widget.totalAmount - (widget.totalAmount * (discountPercent / 100));
      });
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),

      bottomNavigationBar: Container(
        height: MediaQuery.sizeOf(context).height * 0.25,
        decoration: BoxDecoration(
          color: Colors.white, // Primary color
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3), // Top shadow for lifted effect
            ),
          ],
        ),
        padding: const EdgeInsets.only(
          right: AppDimensions.paddingMedium,
          left: AppDimensions.paddingMedium,
          bottom: AppDimensions.paddingLarge,
          top: AppDimensions.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Price:', style: TextStyle(fontSize: 16)),
                Text(
                  '₹ ${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    decoration:
                        (_discountController.text.isEmpty)
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                    fontSize: (_discountController.text.isEmpty) ? 18 : 12,
                    fontWeight:
                        (_discountController.text.isEmpty)
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ],
            ),
            (_discountController.text.isNotEmpty)
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discounted Price:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '₹ ${_discountedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : SizedBox(),
            SizedBox(height: AppDimensions.marginMedium),
            CustomElevatedButton(
              text: 'Proceed to Payment',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentScreen(
                          selectedProducts: widget.selectedProducts,
                          totalAmount: _discountedTotal,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: widget.selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = widget.selectedProducts[index];
                  return ListTile(
                    title: Text(
                      product['name'],
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    subtitle: Text(
                      '${product['description']}    |   Quantity : ${product['quantity']}',
                    ),
                    trailing: Text(
                      '₹${(product['amount'] * product['quantity']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            Spacer(),
            CustomTextField(
              controller: _discountController,
              label: 'Discount (%)',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }
}
