import 'package:flutter/material.dart';
import 'package:saasify_lite/bloc/pos/pos_bloc.dart';
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
      appBar: AppBar(title: const Text('POS Screen')),

      bottomNavigationBar:
          totalAmount > 0
              ? Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF006d77),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.11,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      child: Text(
                        'Total: ₹ $totalAmount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CheckoutScreen(
                                    selectedProducts: _getSelectedProducts(),
                                    totalAmount: totalAmount,
                                  ),
                            ),
                          );
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              )
              : null,

      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            CustomTextField(
              controller: _searchController,
              label: 'Search Products',
              suffixIconData: Icons.search,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppDimensions.paddingSmall,
                          mainAxisSpacing: AppDimensions.paddingSmall,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.all(AppDimensions.marginSmall),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        elevation: 4.0,
                        shadowColor: Colors.black.withOpacity(0.25),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingSmall,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: AppDimensions.paddingSmall,
                              ),
                              Text(
                                product['description'],
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: AppDimensions.paddingLarge,
                              ),
                              Text(
                                '₹${product['amount']}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: AppDimensions.paddingMedium,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => _decrementQuantity(index),
                                  ),
                                  Text(
                                    '${product['quantity']}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _incrementQuantity(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
