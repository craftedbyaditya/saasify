import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/dimensions.dart';
import 'package:saasify_lite/screens/pos/payment_screen.dart';
import 'package:saasify_lite/widgets/custom_button.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';
import 'package:saasify_lite/widgets/custom_appbar.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> checkoutData;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.checkoutData,
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
    _discountedTotal = widget.totalAmount;
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Checkout'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: widget.checkoutData.length,
              itemBuilder: (context, index) {
                final product = widget.checkoutData[index];
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: AppDimensions.marginMedium,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.marginMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Qty: ${product['quantity']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${(product['amount'] * product['quantity']).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF006d77),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _discountController,
                                label: 'Discount (%)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                prefixIcon: const Icon(Icons.discount_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '₹${widget.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                decoration:
                                    _discountController.text.isNotEmpty
                                        ? TextDecoration.lineThrough
                                        : null,
                                color:
                                    _discountController.text.isNotEmpty
                                        ? Colors.grey[600]
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        if (_discountController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount (${_discountController.text}%)',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '-₹${(widget.totalAmount - _discountedTotal).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006d77).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${_discountedTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006d77),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        CustomElevatedButton(
                          text: 'Proceed to Payment',
                          onTap: () {
                            final discountPercent =
                                double.tryParse(_discountController.text) ??
                                0.0;

                            final orderSummary = {
                              'products':
                                  widget.checkoutData
                                      .map(
                                        (product) => {
                                          ...product,
                                          'originalAmount':
                                              product['amount'] *
                                              product['quantity'],
                                          'discountedAmount':
                                              product['amount'] *
                                              product['quantity'] *
                                              (1 - discountPercent / 100),
                                        },
                                      )
                                      .toList(),
                              'subtotal': widget.totalAmount,
                              'discountPercent': discountPercent,
                              'discountAmount':
                                  widget.totalAmount - _discountedTotal,
                              'total': _discountedTotal,
                              'timestamp': DateTime.now().toIso8601String(),
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PaymentScreen(
                                      orderSummary: orderSummary,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
