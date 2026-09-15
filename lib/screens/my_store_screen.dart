import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/app_state.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';
import 'add_product_screen.dart';

class MyStoreScreen extends StatefulWidget {
  const MyStoreScreen({super.key});

  @override
  State<MyStoreScreen> createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    appState.addListener(_languageChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    appState.removeListener(_languageChanged);
    super.dispose();
  }

  void _languageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final products = await _api.getMyProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = AppStrings.t(
          'Unable to load your store.',
          'आपकी दुकान लोड नहीं हो सकी।',
        );
        _loading = false;
      });
    }
  }

  Future<void> _addProduct() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(),
      ),
    );

    if (result == true) {
      await _loadProducts();
    }
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final id = product['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final title = product['title']?.toString() ??
        AppStrings.t('this product', 'इस उत्पाद');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppStrings.t(
              'Delete product?',
              'उत्पाद हटाएँ?',
            ),
          ),
          content: Text(
            AppStrings.t(
              'Are you sure you want to delete "$title"?',
              '"$title" को हटाना चाहते हैं?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                AppStrings.t('Cancel', 'रद्द करें'),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                AppStrings.t('Delete', 'हटाएँ'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _api.deleteProduct(id);

      if (!mounted) return;

      setState(() {
        _products.removeWhere(
          (item) => item['id']?.toString() == id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              'Product deleted successfully.',
              'उत्पाद सफलतापूर्वक हटा दिया गया।',
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              'Unable to delete product.',
              'उत्पाद हटाया नहीं जा सका।',
            ),
          ),
        ),
      );
    }
  }

  String _location(Map<String, dynamic> product) {
    final raw = product['location'];

    if (raw is! Map) return '';

    final location = Map<String, dynamic>.from(raw);

    final village = location['village']?.toString().trim() ?? '';
    final district = location['district']?.toString().trim() ?? '';
    final state = location['state']?.toString().trim() ?? '';

    return [
      village,
      district,
      state,
    ].where((e) => e.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.t('My Store', 'मेरी दुकान'),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.t('Refresh', 'रिफ्रेश'),
            onPressed: _loading ? null : _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: Text(
          AppStrings.t('Add Product', 'उत्पाद जोड़ें'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.storefront_outlined,
            size: 56,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: Text(
                AppStrings.t('Try Again', 'फिर कोशिश करें'),
              ),
            ),
          ),
        ],
      );
    }

    if (_products.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.storefront_outlined,
            size: 64,
          ),
          const SizedBox(height: 18),
          Text(
            AppStrings.t(
              'Your store is empty',
              'आपकी दुकान खाली है',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.t(
              'Add your first farm product to start selling.',
              'बेचना शुरू करने के लिए अपना पहला कृषि उत्पाद जोड़ें।',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: Text(
                AppStrings.t(
                  'Add Your First Product',
                  'पहला उत्पाद जोड़ें',
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _ProductCard(
          product: _products[index],
          location: _location(_products[index]),
          onDelete: () => _deleteProduct(_products[index]),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String location;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.location,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = product['title']?.toString() ??
        AppStrings.t('Farm Product', 'कृषि उत्पाद');

    final category = product['category']?.toString() ?? '';

    final price = product['price']?.toString() ?? '0';
    final unit = product['unit']?.toString() ?? 'kg';

    final quantity =
        product['availableQuantity']?.toString() ?? '0';

    final imageUrl = product['imageUrl']?.toString();

    final status = product['status']?.toString() ?? 'available';

    final available =
        status == 'available' && quantity != '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(imageUrl: imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: AppStrings.t(
                          'Delete',
                          'हटाएँ',
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                      ),
                    ],
                  ),
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '₹$price / $unit',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t(
                      'Stock: $quantity $unit',
                      'स्टॉक: $quantity $unit',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        available
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          available
                              ? AppStrings.t(
                                  'Available',
                                  'उपलब्ध',
                                )
                              : AppStrings.t(
                                  'Sold out',
                                  'बिक गया',
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  size: 34,
                );
              },
            )
          : const Icon(
              Icons.image_outlined,
              size: 34,
            ),
    );
  }
}
