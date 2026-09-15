import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/localization.dart';
import '../services/api_service.dart';

class BuyerOfferScreen extends StatefulWidget {
  const BuyerOfferScreen({super.key});

  @override
  State<BuyerOfferScreen> createState() => _BuyerOfferScreenState();
}

class _BuyerOfferScreenState extends State<BuyerOfferScreen> {
  final ApiService _api = ApiService();

  final crop = TextEditingController();
  final qty = TextEditingController();
  final price = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();

  bool _submitting = false;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    crop.dispose();
    qty.dispose();
    price.dispose();
    city.dispose();
    state.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final requests = await _api.getBulkRequests();

      if (!mounted) return;

      setState(() {
        _requests = requests;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> submitOffer() async {
    FocusScope.of(context).unfocus();

    final cropName = crop.text.trim();
    final quantity = double.tryParse(qty.text.trim());
    final targetPrice = double.tryParse(price.text.trim());
    final deliveryCity = city.text.trim();
    final deliveryState = state.text.trim();

    if (cropName.isEmpty) {
      _showMessage(
        AppStrings.t("Please enter crop name", "कृपया फसल का नाम दर्ज करें"),
        isError: true,
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      _showMessage(
        AppStrings.t(
          "Please enter a valid quantity",
          "कृपया सही मात्रा दर्ज करें",
        ),
        isError: true,
      );
      return;
    }

    if (targetPrice == null || targetPrice <= 0) {
      _showMessage(
        AppStrings.t(
          "Please enter a valid target price",
          "कृपया सही लक्ष्य कीमत दर्ज करें",
        ),
        isError: true,
      );
      return;
    }

    if (deliveryCity.isEmpty) {
      _showMessage(
        AppStrings.t(
          "Please enter delivery city",
          "कृपया डिलीवरी शहर दर्ज करें",
        ),
        isError: true,
      );
      return;
    }

    if (deliveryState.isEmpty) {
      _showMessage(
        AppStrings.t(
          "Please enter delivery state",
          "कृपया डिलीवरी राज्य दर्ज करें",
        ),
        isError: true,
      );
      return;
    }

    try {
      setState(() => _submitting = true);

      final requiredByDate =
          DateTime.now().add(const Duration(days: 7)).toIso8601String();

      await _api.createBulkRequest(
        productTitle: cropName,
        category: 'Vegetables',
        targetQuantity: quantity,
        unit: 'kg',
        deliveryCity: deliveryCity,
        deliveryState: deliveryState,
        requiredByDate: requiredByDate,
        targetPricePerUnit: targetPrice,
      );

      crop.clear();
      qty.clear();
      price.clear();

      await _loadRequests();

      if (!mounted) return;

      _showMessage(
        AppStrings.t(
          "Crop requirement posted successfully",
          "फसल की आवश्यकता सफलतापूर्वक पोस्ट हो गई",
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red.shade700 : null,
        content: Text(message),
      ),
    );
  }

  String _formatQuantity(Map<String, dynamic> request) {
    final quantity = request['targetQuantity'];
    final unit = request['unit'] ?? 'kg';
    return '${quantity ?? '-'} $unit';
  }

  String _formatPrice(Map<String, dynamic> request) {
    final value = request['targetPricePerUnit'];
    if (value == null) {
      return AppStrings.t("Price on request", "कीमत बातचीत के अनुसार");
    }

    return '₹$value/${request['unit'] ?? 'kg'}';
  }

  String _statusText(dynamic status) {
    final value = status?.toString().toUpperCase();

    switch (value) {
      case 'OPEN':
        return AppStrings.t("Open", "खुली");
      case 'QUOTES_RECEIVED':
        return AppStrings.t("Offers received", "ऑफर प्राप्त हुए");
      case 'ACCEPTED':
        return AppStrings.t("Accepted", "स्वीकृत");
      case 'CLOSED':
        return AppStrings.t("Closed", "बंद");
      default:
        return status?.toString() ?? '-';
    }
  }

  Color _statusColor(dynamic status) {
    switch (status?.toString().toUpperCase()) {
      case 'OPEN':
        return Colors.green;
      case 'QUOTES_RECEIVED':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'CLOSED':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  Widget _inputCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _requestCard(Map<String, dynamic> request) {
    final cropName = request['productTitle']?.toString() ?? '-';
    final status = request['status'];

    final rawOffers = request['offers'];
    final offers = rawOffers is List
        ? rawOffers
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.mintTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatQuantity(request),
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatPrice(request),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${request['deliveryCity'] ?? '-'}, ${request['deliveryState'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 105),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusText(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (offers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.t(
                      "Offers Received (${offers.length})",
                      "प्राप्त ऑफर (${offers.length})",
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...offers.asMap().entries.map(
                  (entry) => _offerCard(
                    request,
                    entry.value,
                    entry.key,
                  ),
                ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.t(
                        "Waiting for farmer offers",
                        "किसानों के ऑफर की प्रतीक्षा है",
                      ),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _offerCard(
    Map<String, dynamic> request,
    Map<String, dynamic> offer,
    int index,
  ) {
    final farmerName = offer['farmerName']?.toString().trim().isNotEmpty == true
        ? offer['farmerName'].toString()
        : AppStrings.t("Farmer", "किसान");

    final fpoName = offer['fpoName']?.toString() ?? '';

    final quantity = _numberValue(offer['offeredQuantity']);
    final price = _numberValue(offer['offeredPricePerUnit']);
    final total = _numberValue(offer['totalOfferAmount']);

    final unit = request['unit']?.toString() ?? 'kg';
    final logistics = offer['logisticsIncluded'] == true;

    final notes = offer['notes']?.toString().trim() ?? '';
    final offerStatus = offer['status']?.toString().toUpperCase() ?? 'PENDING';

    final offerId = offer['_id']?.toString() ?? offer['id']?.toString() ?? '';

    final requestId =
        request['id']?.toString() ?? request['_id']?.toString() ?? '';

    final accepted = offerStatus == 'ACCEPTED' ||
        request['acceptedOfferId']?.toString() == offerId;

    return Container(
      margin: EdgeInsets.only(
        bottom: index == 0 ? 0 : 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              accepted ? Colors.green.withOpacity(.35) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.mintTint,
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (fpoName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        fpoName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accepted
                      ? Colors.green.withOpacity(.12)
                      : Colors.orange.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  accepted
                      ? AppStrings.t("Accepted", "स्वीकृत")
                      : AppStrings.t("Pending", "लंबित"),
                  style: TextStyle(
                    color: accepted ? Colors.green : Colors.orange.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _offerInfoChip(
                Icons.scale_outlined,
                '${_cleanNumber(quantity)} $unit',
              ),
              _offerInfoChip(
                Icons.currency_rupee,
                '₹${_cleanNumber(price)}/$unit',
              ),
              if (total > 0)
                _offerInfoChip(
                  Icons.account_balance_wallet_outlined,
                  '₹${_cleanNumber(total)}',
                ),
            ],
          ),
          if (logistics) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppStrings.t(
                      "Logistics included",
                      "लॉजिस्टिक्स शामिल",
                    ),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              notes,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
          if (!accepted && offerId.isNotEmpty && requestId.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _acceptOffer(
                  requestId: requestId,
                  offerId: offerId,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  AppStrings.t(
                    "Accept Offer",
                    "ऑफर स्वीकार करें",
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _offerInfoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _numberValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  Future<void> _acceptOffer({
    required String requestId,
    required String offerId,
  }) async {
    try {
      await _api.acceptFarmerOffer(
        requestId: requestId,
        offerId: offerId,
      );

      if (!mounted) return;

      await _loadRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              "Farmer offer accepted successfully",
              "किसान का ऑफर सफलतापूर्वक स्वीकार किया गया",
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              "Could not accept offer: $e",
              "ऑफर स्वीकार नहीं हो सका: $e",
            ),
          ),
        ),
      );
    }
  }

  Widget _requirementsSection() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 38,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh),
              label: Text(
                AppStrings.t("Retry", "फिर कोशिश करें"),
              ),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.t(
                "No requirements posted yet",
                "अभी कोई आवश्यकता पोस्ट नहीं हुई है",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          return _requestCard(_requests[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          AppStrings.t(
            "Buyer Dashboard",
            "खरीदार डैशबोर्ड",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRequests,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.t(
                          "Buy directly from farmers",
                          "किसानों से सीधे खरीदें",
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.t(
                          "Create bulk crop requirements and receive farmer offers",
                          "अपनी बड़ी फसल जरूरत पोस्ट करें और किसानों से ऑफर पाएं",
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.t(
                    "Post New Requirement",
                    "नई आवश्यकता पोस्ट करें",
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _inputCard(
                  child: TextField(
                    controller: crop,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.eco),
                      labelText: AppStrings.t(
                        "Crop Name",
                        "फसल का नाम",
                      ),
                      hintText: "Wheat, Rice",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _inputCard(
                  child: TextField(
                    controller: qty,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.inventory),
                      labelText: AppStrings.t(
                        "Required Quantity (kg)",
                        "जरूरी मात्रा (किलो)",
                      ),
                      hintText: "500",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _inputCard(
                  child: TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.currency_rupee),
                      labelText: AppStrings.t(
                        "Target Price / kg",
                        "लक्ष्य कीमत / किलो",
                      ),
                      hintText: "24",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _inputCard(
                  child: TextField(
                    controller: city,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_city),
                      labelText: AppStrings.t(
                        "Delivery City",
                        "डिलीवरी शहर",
                      ),
                      hintText: "Ghaziabad",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _inputCard(
                  child: TextField(
                    controller: state,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.map_outlined),
                      labelText: AppStrings.t(
                        "Delivery State",
                        "डिलीवरी राज्य",
                      ),
                      hintText: "Uttar Pradesh",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : submitOffer,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _submitting
                          ? AppStrings.t(
                              "Posting...",
                              "पोस्ट हो रहा है...",
                            )
                          : AppStrings.t(
                              "Submit Requirement",
                              "जरूरत भेजें",
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  AppStrings.t(
                    "My Active Requirements",
                    "मेरी सक्रिय आवश्यकताएं",
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _requirementsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
