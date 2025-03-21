import 'package:flutter/material.dart';
import 'package:saasify_lite/bloc/customer/customer_bloc.dart';
import 'package:saasify_lite/screens/pos/bill_pdf_screen.dart';
import 'package:saasify_lite/widgets/custom_button.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';
import 'package:saasify_lite/constants/dimensions.dart';
import 'package:saasify_lite/widgets/custom_appbar.dart';

import '../../bloc/orderHistory/order_history.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> orderSummary;

  const PaymentScreen({super.key, required this.orderSummary});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final AddCustomerBloc _addCustomerBloc = AddCustomerBloc();
  final OrderService _orderService = OrderService();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedPaymentOption = 'Pay Later';
  double _paidAmount = 0.0;
  double _balanceAmount = 0.0;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;
  bool _showAllResults = false;
  bool _showCustomerList = false;
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _searchController.addListener(_filterCustomers);
    _paidAmountController.addListener(_updateBalanceAmount);
    _balanceAmount = widget.orderSummary['total'];
  }

  void _updateBalanceAmount() {
    final paid = double.tryParse(_paidAmountController.text) ?? 0.0;
    setState(() {
      _paidAmount = paid;
      _balanceAmount = widget.orderSummary['total'] - paid;
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileNumberController.dispose();
    _searchController.dispose();
    _paidAmountController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    final customers = await _addCustomerBloc.fetchAllCustomers();
    setState(() {
      _customers = customers;
      _filteredCustomers = customers;
      _isLoading = false;
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.length > 3) {
        _filteredCustomers =
            _customers
                .where(
                  (customer) =>
                      customer['name'].toLowerCase().contains(query) ||
                      customer['contact'].toLowerCase().contains(query),
                )
                .toList();
        _showCustomerList = true;
        _showAllResults = false;
      } else {
        _filteredCustomers = [];
        _showCustomerList = false;
      }
    });
  }

  void _showAllCustomers() {
    setState(() {
      _filteredCustomers = _customers;
      _showAllResults = true;
      _showCustomerList = true;
    });
  }

  Future<bool> _generateAndOpenBill(BuildContext context) async {
    try {
      final bool isInserted = await _orderService.insertOrder(
        customerId: _selectedCustomerId!,
        selectedProducts: widget.orderSummary['products'],
        totalAmount: widget.orderSummary['total'],
        paidAmount: _paidAmount,
        subTotalAmount: widget.orderSummary['subtotal'],
        taxAmount: 0,
        discountAmount: widget.orderSummary['discountAmount'],
        discountPercent: widget.orderSummary['discountPercent'],
        balanceAmount: _balanceAmount,
        paymentMethod: _selectedPaymentOption,
        paymentStatus:
            _selectedPaymentOption.startsWith('Paid') ? 'Paid' : 'Pending',
      );

      if (isInserted) {
        final pdfGenerator = BillPdfGenerator();
        try {
          await pdfGenerator.generateBill(
            selectedProducts: widget.orderSummary['products'],
            totalAmount: widget.orderSummary['total'],
            customerName: _customerNameController.text,
            customerContact: _mobileNumberController.text,
            paymentOption: _selectedPaymentOption,
            paidAmount:
                _selectedPaymentOption == 'Partial Payment'
                    ? _paidAmount
                    : widget.orderSummary['total'],
            subtotalAmount: widget.orderSummary['subtotal'],
            discountAmount: widget.orderSummary['discountAmount'],
            discountPercent: widget.orderSummary['discountPercent'],
            context: context,
          );
          return true; // Return true if PDF generation was successful
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place an order')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Payment'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                label: 'Search Customer',
                suffixIconData: Icons.search,
                onChanged: (value) {
                  _filterCustomers();
                  setState(() {
                    if (value.isEmpty) {
                      _showCustomerList = false;
                    }
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              (_searchController.text.isNotEmpty)
                  ? Text(
                    'Selected Customer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  )
                  : const SizedBox.shrink(),
              (_searchController.text.isNotEmpty)
                  ? SizedBox(height: AppDimensions.paddingMedium)
                  : const SizedBox.shrink(),
              if (_selectedCustomerId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customerNameController.text,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              _mobileNumberController.text,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCustomerId = null;
                            _customerNameController.clear();
                            _mobileNumberController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
              ],

              if (_showCustomerList)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Scrollbar(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount:
                          _showAllResults
                              ? _filteredCustomers.length
                              : (_filteredCustomers.length > 4
                                  ? 4
                                  : _filteredCustomers.length),
                      separatorBuilder:
                          (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return ListTile(
                          leading: Icon(
                            Icons.person_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            customer['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(customer['contact']),
                          onTap: () {
                            setState(() {
                              _customerNameController.text = customer['name'];
                              _mobileNumberController.text =
                                  customer['contact'];
                              _selectedCustomerId = customer['id'];
                              _showCustomerList = false;
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

              if (!_showAllResults && _filteredCustomers.length > 4)
                TextButton(
                  onPressed: _showAllCustomers,
                  child: const Text('Show all results'),
                ),

              const SizedBox(height: AppDimensions.paddingMedium),

              const Text(
                'Payment Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          '${widget.orderSummary['subtotal'].toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount (${widget.orderSummary['discountPercent']}%)',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${widget.orderSummary['discountAmount'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006d77).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
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
                            '${widget.orderSummary['total'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006d77),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Paid - Cash',
                        groupValue: _selectedPaymentOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentOption = value!;
                            _paidAmount = widget.orderSummary['total'];
                            _balanceAmount = 0.0;
                            _paidAmountController.text = _paidAmount
                                .toStringAsFixed(2);
                          });
                        },
                        activeColor: const Color(0xFF006d77),
                      ),
                      const Text('Paid - Cash'),
                      Radio<String>(
                        value: 'Paid - UPI',
                        groupValue: _selectedPaymentOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentOption = value!;
                            _paidAmount = widget.orderSummary['total'];
                            _balanceAmount = 0.0;
                            _paidAmountController.text = _paidAmount
                                .toStringAsFixed(2);
                          });
                        },
                        activeColor: const Color(0xFF006d77),
                      ),
                      const Text('Paid - UPI'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Pay Later',
                        groupValue: _selectedPaymentOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentOption = value!;
                            _paidAmount = 0.0;
                            _balanceAmount = widget.orderSummary['total'];
                            _paidAmountController.text = '';
                          });
                        },
                        activeColor: const Color(0xFF006d77),
                      ),
                      const Text('Pay Later'),
                      const SizedBox(width: 24),
                      Radio<String>(
                        value: 'Partial Payment',
                        groupValue: _selectedPaymentOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentOption = value!;
                            _paidAmount = 0.0;
                            _balanceAmount = widget.orderSummary['total'];
                            _paidAmountController.text = '';
                          });
                        },
                        activeColor: const Color(0xFF006d77),
                      ),
                      const Text('Partial Payment'),
                    ],
                  ),
                ],
              ),

              if (_selectedPaymentOption == 'Partial Payment') ...[
                const SizedBox(height: AppDimensions.paddingLarge),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _paidAmountController,
                        label: 'Amount Paid',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance Amount',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      Text(
                        _balanceAmount.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006d77),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.paddingLarge),
              CustomElevatedButton(
                text: 'Generate Bill',
                onTap: () async {
                  if (_selectedCustomerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a customer first'),
                      ),
                    );
                    return;
                  }

                  if (_selectedPaymentOption == 'Partial Payment' &&
                      (_paidAmount <= 0 ||
                          _paidAmount >= widget.orderSummary['total'])) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a valid partial payment amount',
                        ),
                      ),
                    );
                    return;
                  }

                  final bool success = await _generateAndOpenBill(context);
                  if (success) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
