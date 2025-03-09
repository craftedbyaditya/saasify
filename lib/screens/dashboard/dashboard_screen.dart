import 'package:flutter/material.dart';
import 'package:saasify_lite/screens/customers/add_customer_screen.dart';
import 'package:saasify_lite/screens/inventory/add_new_item.dart';
import 'package:saasify_lite/screens/pos/pos_screen.dart';
import '../../constants/dimensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> _tiles = [
    {'icon': Icons.receipt, 'text': 'New Bill', 'screen': PosScreen()},
    {
      'icon': Icons.add_box,
      'text': 'Add New Item',
      'screen': AddNewItemScreen(),
    },
    // {'icon': Icons.history, 'text': 'Order History', 'screen': OrderHistoryScreen()},
    // {'icon': Icons.inventory, 'text': 'Inventory', 'screen': InventoryScreen()},
    {'icon': Icons.people, 'text': 'Customers', 'screen': AddCustomerScreen()},
  ];
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(_tiles.length, (index) {
                  return Card(
                    margin: const EdgeInsets.all(AppDimensions.marginSmall),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    elevation: 4.0,
                    shadowColor: Colors.black.withOpacity(0.25),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () => _navigateTo(_tiles[index]['screen']),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimensions.paddingMedium,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _tiles[index]['icon'],
                              size: 48.0,
                              color: Color(0xFF006d77),
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Text(
                              _tiles[index]['text'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
