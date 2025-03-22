import 'package:flutter/material.dart';
import 'package:saasify_lite/bloc/pos/pos_bloc.dart';
import 'package:saasify_lite/screens/inventory/add_new_item.dart';
import 'package:saasify_lite/widgets/custom_appbar.dart';
import 'package:saasify_lite/widgets/custom_textfield.dart';
import 'package:saasify_lite/constants/dimensions.dart';

class AllItemsScreen extends StatefulWidget {
  const AllItemsScreen({super.key});

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'New Bill'),
      backgroundColor: Colors.grey[50],
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
                    : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              alignment: Alignment.center,
                              height: 70,
                              width: 70,
                              child:
                                  (_filteredProducts[index]['product_image'] !=
                                          null)
                                      ? Image.network(
                                        product['product_image'],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                      : Icon(
                                        Icons.inventory_2_outlined,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingSmall,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(product['name']),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AddNewItemScreen(
                                                isEdit: true,
                                                productDetails: {
                                                  'productId': product['id'],
                                                  'productName':
                                                      product['name'],
                                                  'productDescription':
                                                      product['description'],
                                                  'productAmount':
                                                      product['amount'],
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.edit, size: 20),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(product['description']),
                                  Text(product['amount'].toString()),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          const SizedBox(height: AppDimensions.paddingMedium),
        ],
      ),
    );
  }
}
