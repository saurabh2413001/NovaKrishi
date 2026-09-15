import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _items = [];
  double _subtotal = 0;
  int _totalItems = 0;
  bool _loading = true;
  String? _error;
  final Set<String> _updating = <String>{};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final data = await _api.getCart();

      double subtotal = 0;
      int totalItems = 0;

      for (final item in data) {
        subtotal += _number(item['subtotal']);
        totalItems += _number(item['quantity']).round();
      }

      if (!mounted) return;

      setState(() {
        _items = data;
        _subtotal = subtotal;
        _totalItems = totalItems;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _text(String english, String hindi) {
    return AppStrings.t(english, hindi);
  }

  Future<void> _changeQuantity(
    Map<String, dynamic> item,
    int delta,
  ) async {
    final productId = item['productId']?.toString() ?? '';
    if (productId.isEmpty || _updating.contains(productId)) return;

    final currentQuantity = _number(item['quantity']).round();
    final availableQuantity = _number(item['availableQuantity']).round();

    final newQuantity = currentQuantity + delta;

    if (newQuantity < 1) {
      return;
    }

    if (availableQuantity > 0 && newQuantity > availableQuantity) {
      _showMessage(
        _text(
          'Only $availableQuantity units are available.',
          'केवल $availableQuantity यूनिट उपलब्ध हैं।',
        ),
      );
      return;
    }

    setState(() => _updating.add(productId));

    try {
      await _api.updateCartQuantity(
        productId: productId,
        quantity: newQuantity,
      );

      await _loadCart();
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _updating.remove(productId));
      }
    }
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    final productId = item['productId']?.toString() ?? '';
    if (productId.isEmpty || _updating.contains(productId)) return;

    setState(() => _updating.add(productId));

    try {
      await _api.removeFromCart(productId);
      await _loadCart();

      if (mounted) {
        _showMessage(
          _text(
            'Item removed from cart.',
            'आइटम कार्ट से हटा दिया गया।',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _updating.remove(productId));
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _proceedToCheckout() {
    _showMessage(
      _text(
        'Checkout will be connected next.',
        'चेकआउट अगले चरण में जोड़ा जाएगा।',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          _text('My Cart', 'मेरी कार्ट'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_loading && _items.isNotEmpty)
            IconButton(
              tooltip: _text('Refresh cart', 'कार्ट रीफ्रेश करें'),
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_items.isEmpty) {
      return _buildEmptyCart();
    }

    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _buildSummaryHeader(),
          const SizedBox(height: 14),
          ..._items.map(_buildCartItem),
          const SizedBox(height: 8),
          _buildPriceSummary(),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.green,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    'Your selected produce',
                    'आपकी चुनी हुई उपज',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_totalItems ${_text('items', 'आइटम')}',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final productId = item['productId']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'Farm Produce';
    final category = item['category']?.toString() ?? '';
    final farmerName = item['farmerName']?.toString() ?? '';
    final fpoName = item['fpoName']?.toString() ?? '';
    final imageUrl = item['imageUrl']?.toString() ?? '';
    final unit = item['unit']?.toString() ?? 'kg';

    final price = _number(item['price']);
    final quantity = _number(item['quantity']).round();
    final subtotal = _number(item['subtotal']);
    final available = _number(item['availableQuantity']).round();

    final updating = _updating.contains(productId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        category,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (farmerName.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fpoName.isNotEmpty
                                  ? '$farmerName • $fpoName'
                                  : farmerName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 7),
                    Text(
                      '₹${_cleanNumber(price)} / $unit',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: _text('Remove', 'हटाएं'),
                onPressed: updating ? null : () => _removeItem(item),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _text('Quantity', 'मात्रा'),
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              _quantityButton(
                icon: Icons.remove,
                enabled: !updating && quantity > 1,
                onTap: () => _changeQuantity(item, -1),
              ),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 44,
                ),
                alignment: Alignment.center,
                child: updating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '$quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              _quantityButton(
                icon: Icons.add,
                enabled: !updating && (available <= 0 || quantity < available),
                onTap: () => _changeQuantity(item, 1),
              ),
              const SizedBox(width: 12),
              Text(
                '₹${_cleanNumber(subtotal)}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: AppColors.mintTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.agriculture_outlined,
          color: Colors.green,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 78,
            height: 78,
            color: AppColors.mintTint,
            child: const Icon(
              Icons.agriculture_outlined,
              color: Colors.green,
              size: 32,
            ),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 78,
            height: 78,
            color: AppColors.mintTint,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text('Order Summary', 'ऑर्डर सारांश'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            _text('Items', 'आइटम'),
            '$_totalItems',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            _text('Produce subtotal', 'उपज का कुल मूल्य'),
            '₹${_cleanNumber(_subtotal)}',
          ),
          const SizedBox(height: 8),
          _summaryRow(
            _text('Delivery', 'डिलीवरी'),
            _text(
              'Calculated at checkout',
              'चेकआउट पर तय होगा',
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 10),
          _summaryRow(
            _text('Total', 'कुल'),
            '₹${_cleanNumber(_subtotal)}',
            bold: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _proceedToCheckout,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                _text(
                  'Proceed to Checkout',
                  'चेकआउट पर जाएं',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: bold ? null : AppColors.textMuted,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : null,
              fontSize: bold ? 18 : 14,
              color: bold ? AppColors.primary : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 70),
          Icon(
            Icons.remove_shopping_cart_outlined,
            size: 72,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 18),
          Text(
            _text(
              'Your cart is empty',
              'आपकी कार्ट खाली है',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              'Add fresh produce from the marketplace to get started.',
              'शुरू करने के लिए बाज़ार से ताज़ी उपज कार्ट में जोड़ें।',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return RefreshIndicator(
      onRefresh: _loadCart,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 70),
          const Icon(
            Icons.cloud_off,
            size: 58,
            color: Colors.orange,
          ),
          const SizedBox(height: 14),
          Text(
            _text(
              'Could not load your cart',
              'कार्ट लोड नहीं हो सकी',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
              label: Text(
                _text('Retry', 'फिर कोशिश करें'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
