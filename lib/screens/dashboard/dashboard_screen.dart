import 'package:flutter/material.dart';
import 'package:saasify_lite/screens/customers/add_customer_screen.dart';
import 'package:saasify_lite/screens/inventory/add_new_item.dart';
import 'package:saasify_lite/screens/orders/order_history_screen.dart';
import 'package:saasify_lite/screens/pos/pos_screen.dart';
import 'package:saasify_lite/screens/customers/all_customers_screen.dart';
import 'package:saasify_lite/screens/profile/profile_screen.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../constants/dimensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _dashboardService.getStats();
      if (!mounted) return;

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading dashboard stats')),
      );
    }
  }

  final List<Map<String, dynamic>> _tiles = [
    {
      'icon': Icons.receipt_long,
      'text': 'New Bill',
      'description': 'Create a new bill for customer',
      'screen': PosScreen(),
      'color': const Color(0xFF006d77),
    },
    {
      'icon': Icons.add_box_rounded,
      'text': 'Add New Item',
      'description': 'Add new items to inventory',
      'screen': AddNewItemScreen(),
      'color': const Color(0xFF83c5be),
    },
    // {
    //   'icon': Icons.people_alt_rounded,
    //   'text': 'Add Customer',
    //   'description': 'Add a new customer',
    //   'screen': AddCustomerScreen(),
    //   'color': const Color(0xFFe29578),
    // },
    // {
    //   'icon': Icons.history_rounded,
    //   'text': 'Order History',
    //   'description': 'View all past orders',
    //   'screen': const OrderHistoryScreen(),
    //   'color': const Color(0xFF2a9d8f),
    // },
    // {
    //   'icon': Icons.group_rounded,
    //   'text': 'All Customers',
    //   'description': 'View all your customers',
    //   'screen': const AllCustomersScreen(),
    //   'color': const Color(0xFF264653),
    // },
  ];

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: () => _loadStats(),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _navigateTo(const ProfileScreen()),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF006d77).withOpacity(0.1),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF006d77),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          await _dashboardService.getStats();
          setState(() {
            _isLoading = false;
          });
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Stats Section
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Sales',
                                  _isLoading
                                      ? '...'
                                      : '₹${_stats?.totalAmount.toStringAsFixed(2) ?? '0.00'}',
                                  Icons.trending_up_rounded,
                                  const Color(0xFF006d77),
                                  {'screen': null},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Total Orders',
                                  _isLoading
                                      ? '...'
                                      : '${_stats?.totalOrders ?? 0}',
                                  Icons.shopping_bag_outlined,
                                  const Color(0xFFe29578),
                                  {'screen': const OrderHistoryScreen()},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Pending Amount',
                                  _isLoading
                                      ? '...'
                                      : '₹${_stats?.pendingAmount.toStringAsFixed(2) ?? '0.00'}',
                                  Icons.pending_actions_rounded,
                                  const Color(0xFF2a9d8f),
                                  {'screen': ''},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Total Customers',
                                  _isLoading
                                      ? '...'
                                      : '${_stats?.totalCustomers ?? 0}',
                                  Icons.people_alt_rounded,
                                  const Color(0xFF264653),
                                  {'screen': const AllCustomersScreen()},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _tiles.length,
                  itemBuilder: (context, index) {
                    final tile = _tiles[index];
                    return InkWell(
                      onTap: () => _navigateTo(tile['screen']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: tile['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tile['icon'],
                                size: 32,
                                color: tile['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tile['text'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tile['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Map<String, dynamic>? tile,
  ) {
    return InkWell(
      onTap:
          tile != null && tile['screen'] != null && tile['screen'] is Widget
              ? () => _navigateTo(tile['screen'])
              : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
