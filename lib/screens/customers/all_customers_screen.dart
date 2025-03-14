import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saasify_lite/bloc/orderHistory/order_history.dart';
import 'package:saasify_lite/screens/customers/add_customer_screen.dart';
import 'package:saasify_lite/widgets/custom_appbar.dart';
import '../../constants/dimensions.dart';
import '../../widgets/custom_textfield.dart';
import '../../bloc/customer/customer_bloc.dart';

class AllCustomersScreen extends StatefulWidget {
  final bool? onlyPendingCustomers;

  const AllCustomersScreen({super.key, this.onlyPendingCustomers = false});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AddCustomerBloc _customerBloc = AddCustomerBloc();
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _allCustomers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (widget.onlyPendingCustomers!) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _orderService.loadOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      print('orders - $orders');
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error loading orders')));
      }
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _customerBloc.fetchAllCustomers();
      print('customers - $customers');
      setState(() {
        _customers = customers;
        _allCustomers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading customers')),
        );
      }
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _customers = _allCustomers;
      } else {
        _customers =
            _allCustomers
                .where(
                  (customer) => customer['name']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: 'All Customers',
        actions: [
          (widget.onlyPendingCustomers!) ?  TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCustomerScreen(),
                ),
              );
            },
            child: const Text(' + Add new customer'),
          ):SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              onChanged: _filterCustomers,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _customers.isEmpty
                    ? const Center(child: Text('No customers found'))
                    : ListView.builder(
                      itemCount: _customers.length,
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        final customerId = customer['id'];
                        double totalBalanceAmount = 0;
                        // Calculate pending amount
                        if (widget.onlyPendingCustomers!) {
                          final customerOrders =
                              _orders
                                  .where(
                                    (order) =>
                                        order['customer_id'] == customerId,
                                  )
                                  .toList();

                          totalBalanceAmount = customerOrders.fold(
                            0,
                            (sum, order) =>
                                sum +
                                ((order['payment_status']
                                            ?.toString()
                                            .toLowerCase() !=
                                        'paid')
                                    ? (order['balance_amount'] as num?)
                                            ?.toDouble() ??
                                        0
                                    : 0),
                          );
                        }

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              customer['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(customer['contact'] ?? ''),
                                if (customer['email'] != null &&
                                    customer['email'].isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(customer['email']),
                                ],
                                if (widget.onlyPendingCustomers! &&
                                    totalBalanceAmount > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pending: ${_currencyFormat.format(totalBalanceAmount)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.sms,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerStats(Map<String, dynamic> customer) {
    final orders = (customer['order_history'] as List?) ?? [];
    final totalOrders = orders.length;

    double totalAmount = 0;
    double totalBalanceAmount = 0;

    for (final order in orders) {
      totalAmount += (order['total_amount'] as num?)?.toDouble() ?? 0;
      if (order['payment_status']?.toString().toLowerCase() != 'paid') {
        totalBalanceAmount +=
            (order['balance_amount'] as num?)?.toDouble() ?? 0;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Orders',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                totalOrders.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                _currencyFormat.format(totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (totalBalanceAmount > 0) ...[
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance Due',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  _currencyFormat.format(totalBalanceAmount),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
