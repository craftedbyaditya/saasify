import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:saasify_lite/bloc/customer/customer_bloc.dart';
import 'package:saasify_lite/screens/pos/bill_pdf_screen.dart';
import 'package:saasify_lite/widgets/custom_button.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';
import 'package:saasify_lite/constants/dimensions.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.selectedProducts,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final AddCustomerBloc _addCustomerBloc = AddCustomerBloc();
  String _selectedPaymentOption = 'Pay later';
  double _paidAmount = 0.0;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = true;
  bool _showAllResults = false;
  bool _showCustomerList = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _mobileNumberController.dispose();
    _searchController.dispose();
    _paidAmountController.dispose();
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

  void _updatePaidAmount(String value) {
    setState(() {
      _paidAmount = double.tryParse(value) ?? 0.0;
    });
  }

  Future<void> _generateAndOpenBill(BuildContext context) async {
    final pdfGenerator = BillPdfGenerator();
    final file = await pdfGenerator.generateBill(
      selectedProducts: widget.selectedProducts,
      totalAmount: widget.totalAmount,
      customerName: _customerNameController.text,
      customerContact: _mobileNumberController.text,
      paymentOption: _selectedPaymentOption,
      paidAmount: _paidAmount,
    );

    if (await file.exists()) {
      await OpenFile.open(
        file.path,
      ); // Ensure to import the `open_file` package
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to generate bill.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),

      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _searchController,
              label: 'Search Customer',
              suffixIconData: Icons.search,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Show customer results with scrollbar and height limit
            if (_showCustomerList)
              Container(
                height: 200.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount:
                        _showAllResults
                            ? _filteredCustomers.length
                            : (_filteredCustomers.length > 4
                                ? 4
                                : _filteredCustomers.length),
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return ListTile(
                        title: Text(customer['name']),
                        subtitle: Text(customer['contact']),
                        onTap: () {
                          _customerNameController.text = customer['name'];
                          _mobileNumberController.text = customer['contact'];
                          setState(() => _showCustomerList = false);
                        },
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Divider(thickness: 0.5),
            const SizedBox(height: AppDimensions.paddingSmall),

            CustomTextField(
              controller: _customerNameController,
              label: 'Customer Name',
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            CustomTextField(
              controller: _mobileNumberController,
              label: 'Mobile Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Options'),
                DropdownButton<String>(
                  value: _selectedPaymentOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPaymentOption = newValue!;
                    });
                  },
                  items:
                      <String>[
                        'Pay later',
                        'UPI - Paid',
                        'Cash - Paid',
                        'Half amount',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),

            if (_selectedPaymentOption == 'Half amount' ||
                _selectedPaymentOption == 'Pay later') ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              (_selectedPaymentOption == 'Half amount')
                  ? CustomTextField(
                    controller: _paidAmountController,
                    label: 'Paid Amount',
                    keyboardType: TextInputType.number,
                    onChanged: _updatePaidAmount,
                  )
                  : SizedBox(),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                'Balance Amount: ₹${(widget.totalAmount - _paidAmount).toStringAsFixed(2)}',
              ),
            ],
            const SizedBox(height: AppDimensions.paddingMedium),
            Text('Total Amount: ₹${(widget.totalAmount).toStringAsFixed(2)}'),
            const SizedBox(height: AppDimensions.paddingMedium),
            CustomElevatedButton(
              text: 'Generate Bill',
              onTap: () async => await _generateAndOpenBill(context),
            ),
          ],
        ),
      ),
    );
  }
}
