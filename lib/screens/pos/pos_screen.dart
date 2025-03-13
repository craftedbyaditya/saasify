import 'package:flutter/material.dart';
import 'package:saasify_lite/bloc/pos/pos_bloc.dart';
import 'package:saasify_lite/widgets/custom_appbar.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';
import 'package:saasify_lite/constants/dimensions.dart';
import 'package:saasify_lite/screens/pos/checkout_screen.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PosBloc _posBloc = PosBloc();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts); // Added search listener
  }

  Future<void> _fetchProducts() async {
    final products = await _posBloc.fetchProducts();
    setState(() {
      _products = products;
      _filteredProducts = products; // Initialize filtered products list
      _isLoading = false;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts =
            _products
                .where(
                  (product) =>
                      product['name'].toLowerCase().contains(query) ||
                      product['description'].toLowerCase().contains(query),
                )
                .toList();
      }
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      _filteredProducts[index]['quantity']++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_filteredProducts[index]['quantity'] > 0) {
        _filteredProducts[index]['quantity']--;
      }
    });
  }

  double _calculateTotal() {
    return _filteredProducts.fold<double>(
      0,
      (sum, product) => sum + (product['amount'] * product['quantity']),
    );
  }

  List<Map<String, dynamic>> _getSelectedProducts() {
    return _filteredProducts
        .where((product) => product['quantity'] > 0)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotal();

    return Scaffold(
      appBar: CustomAppBar(title: 'New Bill'),
      backgroundColor: Colors.grey[50],
      bottomNavigationBar:
          totalAmount > 0
              ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF006d77),
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CheckoutScreen(
                                    checkoutData: _getSelectedProducts(),
                                    totalAmount: totalAmount,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006d77),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingLarge,
                            vertical: AppDimensions.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.paddingSmall),
                CustomTextField(
                  controller: _searchController,
                  label: 'Search Products',
                  suffixIconData: Icons.search,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search by name or description...',
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredProducts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.paddingMedium,
                            mainAxisSpacing: AppDimensions.paddingMedium,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final quantity = product['quantity'] ?? 0;

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingMedium,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${product['amount']}',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF006d77),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.paddingSmall,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed:
                                                () => _decrementQuantity(index),
                                            color:
                                                quantity > 0
                                                    ? const Color(0xFF006d77)
                                                    : Colors.grey,
                                            iconSize: 20,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  AppDimensions.paddingSmall,
                                            ),
                                            child: Text(
                                              quantity.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed:
                                                () => _incrementQuantity(index),
                                            color: const Color(0xFF006d77),
                                            iconSize: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
