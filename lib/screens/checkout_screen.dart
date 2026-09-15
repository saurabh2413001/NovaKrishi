import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/api_service.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.subtotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _api = ApiService();
  final Razorpay _razorpay = Razorpay();

  final _formKey = GlobalKey<FormState>();

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _landmarkController = TextEditingController();

  bool _creatingOrder = false;
  bool _verifyingPayment = false;

  String? _razorpayOrderId;

  @override
  void initState() {
    super.initState();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpay.clear();

    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();

    super.dispose();
  }

  String _text(String english, String hindi) {
    return AppStrings.t(english, hindi);
  }

  String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double get _deliveryCharge {
    return widget.subtotal > 5000 ? 0 : 150;
  }

  double get _total {
    return widget.subtotal + _deliveryCharge;
  }

  Future<void> _placeOrder() async {
    if (_creatingOrder || _verifyingPayment) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.items.isEmpty) {
      _showMessage(
        _text(
          'Your cart is empty.',
          'आपकी कार्ट खाली है।',
        ),
      );
      return;
    }

    setState(() {
      _creatingOrder = true;
    });

    try {
      final orderItems = widget.items.map((item) {
        return {
          'productId': item['productId']?.toString() ?? '',
          'quantity': _number(item['quantity']).round(),
        };
      }).where((item) {
        return (item['productId'] as String).isNotEmpty &&
            (item['quantity'] as int) > 0;
      }).toList();

      if (orderItems.isEmpty) {
        throw const ApiException(
          'No valid products found in your cart.',
          400,
        );
      }

      final orderResponse = await _api.createOrder(
        items: orderItems,
        deliveryAddress: {
          'streetAddress': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          if (_landmarkController.text.trim().isNotEmpty)
            'landmark': _landmarkController.text.trim(),
        },
      );

      final orders = orderResponse['orders'];

      if (orders is! List || orders.isEmpty) {
        throw const ApiException(
          'Order could not be created.',
          0,
        );
      }

      final firstOrder = orders.first;

      if (firstOrder is! Map) {
        throw const ApiException(
          'Invalid order response from server.',
          0,
        );
      }

      final orderId =
          firstOrder['_id']?.toString() ?? firstOrder['id']?.toString() ?? '';

      if (orderId.isEmpty) {
        throw const ApiException(
          'Order ID was not returned by the server.',
          0,
        );
      }

      final paymentResponse = await _api.createPayment(
        orderId: orderId,
      );

      final keyId = paymentResponse['keyId']?.toString() ?? '';
      final razorpayOrderId =
          paymentResponse['razorpayOrderId']?.toString() ?? '';
      final amountInPaise = _number(
        paymentResponse['amountInPaise'],
      ).round();

      if (keyId.isEmpty || razorpayOrderId.isEmpty || amountInPaise <= 0) {
        throw const ApiException(
          'Payment information is incomplete.',
          0,
        );
      }

      _razorpayOrderId = razorpayOrderId;

      if (mounted) {
        setState(() {
          _creatingOrder = false;
        });
      }

      final options = {
        'key': keyId,
        'amount': amountInPaise,
        'currency': paymentResponse['currency']?.toString() ?? 'INR',
        'name': 'NovaKrishi',
        'description': _text(
          'Farm produce order',
          'कृषि उपज का ऑर्डर',
        ),
        'order_id': razorpayOrderId,
        'timeout': 300,
        'theme': {
          'color': '#2E7D32',
        },
      };

      _razorpay.open(options);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _creatingOrder = false;
        });
        _showMessage(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _creatingOrder = false;
        });
        _showMessage(
          _text(
            'Unable to start checkout. Please try again.',
            'चेकआउट शुरू नहीं हो सका। कृपया फिर प्रयास करें।',
          ),
        );
      }
    }
  }

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    final razorpayOrderId = response.orderId ?? _razorpayOrderId ?? '';
    final razorpayPaymentId = response.paymentId ?? '';
    final razorpaySignature = response.signature ?? '';

    if (razorpayOrderId.isEmpty ||
        razorpayPaymentId.isEmpty ||
        razorpaySignature.isEmpty) {
      _showMessage(
        _text(
          'Payment details are incomplete.',
          'पेमेंट विवरण अधूरा है।',
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _verifyingPayment = true;
    });

    try {
      await _api.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      if (!mounted) return;

      setState(() {
        _verifyingPayment = false;
      });

      await _showOrderSuccess();
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _verifyingPayment = false;
      });

      _showMessage(
        '${_text('Payment verification failed', 'पेमेंट सत्यापन विफल')}: ${e.message}',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _verifyingPayment = false;
      });

      _showMessage(
        _text(
          'Payment verification failed. Please contact support.',
          'पेमेंट सत्यापन विफल हुआ। कृपया सपोर्ट से संपर्क करें।',
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    setState(() {
      _creatingOrder = false;
      _verifyingPayment = false;
    });

    _showMessage(
      _text(
        'Payment was not completed. You can try again.',
        'पेमेंट पूरा नहीं हुआ। आप फिर से प्रयास कर सकते हैं।',
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;

    _showMessage(
      _text(
        'External wallet selected. Complete the payment there.',
        'एक्सटर्नल वॉलेट चुना गया है। वहां पेमेंट पूरा करें।',
      ),
    );
  }

  Future<void> _showOrderSuccess() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _text(
                    'Order Confirmed',
                    'ऑर्डर कन्फर्म हो गया',
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            _text(
              'Your payment was verified and your order has been confirmed.',
              'आपका पेमेंट सत्यापित हो गया है और आपका ऑर्डर कन्फर्म हो गया है।',
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                _text('View Orders', 'ऑर्डर देखें'),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  InputDecoration _decoration(
    String english,
    String hindi, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: _text(english, hindi),
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String english,
    required String hindi,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: _decoration(
        english,
        hindi,
        icon: icon,
      ),
    );
  }

  String? _required(String? value, String english, String hindi) {
    if (value == null || value.trim().isEmpty) {
      return _text(
        '$english is required.',
        '$hindi जरूरी है।',
      );
    }
    return null;
  }

  String? _validatePincode(String? value) {
    final text = value?.trim() ?? '';

    if (!RegExp(r'^\d{6}$').hasMatch(text)) {
      return _text(
        'Enter a valid 6-digit pincode.',
        'सही 6 अंकों का पिनकोड डालें।',
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final busy = _creatingOrder || _verifyingPayment;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          _text('Checkout', 'चेकआउट'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 16),
              _buildAddressCard(),
              const SizedBox(height: 16),
              _buildPaymentCard(),
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : _placeOrder,
                  icon: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.lock_outline),
                  label: Text(
                    _verifyingPayment
                        ? _text(
                            'Verifying Payment...',
                            'पेमेंट सत्यापित हो रहा है...',
                          )
                        : _creatingOrder
                            ? _text(
                                'Preparing Payment...',
                                'पेमेंट तैयार हो रहा है...',
                              )
                            : _text(
                                'Place Order & Pay',
                                'ऑर्डर करें और पेमेंट करें',
                              ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _text(
                  'Your payment is verified securely before the order is confirmed.',
                  'ऑर्डर कन्फर्म होने से पहले आपका पेमेंट सुरक्षित रूप से सत्यापित किया जाता है।',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.items.take(8).map((item) {
            final title = item['title']?.toString() ?? 'Produce';
            final quantity = _number(item['quantity']).round();
            final unit = item['unit']?.toString() ?? 'kg';
            final subtotal = _number(item['subtotal']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$title × $quantity $unit',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '₹${_cleanNumber(subtotal)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (widget.items.length > 8)
            Text(
              '+ ${widget.items.length - 8} ${_text('more items', 'और आइटम')}',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          const Divider(height: 24),
          _summaryRow(
            _text('Produce subtotal', 'उपज का सबटोटल'),
            '₹${_cleanNumber(widget.subtotal)}',
          ),
          const SizedBox(height: 7),
          _summaryRow(
            _text('Delivery', 'डिलीवरी'),
            _deliveryCharge == 0
                ? _text('FREE', 'मुफ्त')
                : '₹${_cleanNumber(_deliveryCharge)}',
          ),
          const Divider(height: 24),
          _summaryRow(
            _text('Total', 'कुल'),
            '₹${_cleanNumber(_total)}',
            bold: true,
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
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 17 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
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
            _text('Delivery Address', 'डिलीवरी पता'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _field(
            controller: _streetController,
            english: 'Street / House Address',
            hindi: 'गली / घर का पता',
            icon: Icons.home_outlined,
            validator: (value) => _required(value, 'Address', 'पता'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _cityController,
            english: 'City',
            hindi: 'शहर',
            icon: Icons.location_city_outlined,
            validator: (value) => _required(value, 'City', 'शहर'),
          ),
          const SizedBox(height: 12),
          _field(
            controller: _stateController,
            english: 'State',
            hindi: 'राज्य',
            icon: Icons.map_outlined,
            validator: (value) => _required(value, 'State', 'राज्य'),
          ),
          const SizedBox(height: 12),
          _field(
            controller: _pincodeController,
            english: 'Pincode',
            hindi: 'पिनकोड',
            icon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: _validatePincode,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _landmarkController,
            english: 'Landmark (Optional)',
            hindi: 'लैंडमार्क (वैकल्पिक)',
            icon: Icons.place_outlined,
            validator: (_) => null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    'Secure Online Payment',
                    'सुरक्षित ऑनलाइन पेमेंट',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _text(
                    'Pay securely using Razorpay. UPI, cards and supported payment methods will appear in the payment window.',
                    'Razorpay से सुरक्षित पेमेंट करें। UPI, कार्ड और उपलब्ध पेमेंट विकल्प पेमेंट विंडो में दिखाई देंगे।',
                  ),
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
