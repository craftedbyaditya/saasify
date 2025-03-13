import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../constants/dimensions.dart';
import '../../widgets/custom_textfield.dart';

class AllCustomersScreen extends StatefulWidget {
  const AllCustomersScreen({super.key});

  @override
  State<AllCustomersScreen> createState() => _AllCustomersScreenState();
}

class _AllCustomersScreenState extends State<AllCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await _supabase
          .from('customers')
          .select('''
            *,
            order_history!customer_id(
              total_amount,
              balance_amount,
              payment_status,
              order_date
            )
          ''')
          .order('name');

      setState(() {
        _customers = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error loading customers')));
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _isLoading = true;
    });

    _supabase
        .from('customers')
        .select('''
          *,
          order_history!customer_id(
            total_amount,
            balance_amount,
            payment_status,
            order_date
          )
        ''')
        .ilike('name', '%$query%')
        .then((response) {
          print('response --- $response');
          setState(() {
            _customers = response;
            _isLoading = false;
          });
        })
        .catchError((_) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error filtering customers')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Customers',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
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
                        return Card(
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
                                Text(customer['phone'] ?? ''),
                                if (customer['email'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(customer['email']),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                // TODO: Navigate to edit customer screen
                              },
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
