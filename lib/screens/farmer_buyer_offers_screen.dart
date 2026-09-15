import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/localization.dart';

class FarmerBuyerOffersScreen extends StatefulWidget {
  const FarmerBuyerOffersScreen({super.key});

  @override
  State<FarmerBuyerOffersScreen> createState() =>
      _FarmerBuyerOffersScreenState();
}

class _FarmerBuyerOffersScreenState extends State<FarmerBuyerOffersScreen> {
  final ApiService _api = const ApiService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
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
        _error = e.toString();
      });
    }
  }

  String _text(String en, String hi) => AppStrings.t(en, hi);

  String _string(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  String _formatPrice(dynamic value) {
    if (value == null) return _text('Price not specified', 'कीमत उपलब्ध नहीं');

    final number =
        value is num ? value.toDouble() : double.tryParse(value.toString());

    if (number == null) {
      return _string(value);
    }

    return '₹${number.toStringAsFixed(number % 1 == 0 ? 0 : 2)}';
  }

  String _formatDate(dynamic value) {
    if (value == null) return _text('Date not specified', 'तारीख उपलब्ध नहीं');

    final date = DateTime.tryParse(value.toString());
    if (date == null) return _string(value);

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.green;
      case 'QUOTES_RECEIVED':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.blue;
      case 'CLOSED':
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return _text('Open', 'खुला');
      case 'QUOTES_RECEIVED':
        return _text('Offers Received', 'ऑफर प्राप्त');
      case 'ACCEPTED':
        return _text('Accepted', 'स्वीकृत');
      case 'CLOSED':
        return _text('Closed', 'बंद');
      case 'EXPIRED':
        return _text('Expired', 'समाप्त');
      default:
        return status;
    }
  }

  void _showDetails(Map<String, dynamic> request) {
    final buyer = request['buyer'] is Map
        ? Map<String, dynamic>.from(request['buyer'] as Map)
        : <String, dynamic>{};

    final product = _string(
      request['productTitle'],
      _text('Crop not specified', 'फसल उपलब्ध नहीं'),
    );

    final buyerName = _string(
      buyer['organizationName'],
      _string(
        buyer['name'],
        _text('Bulk Buyer', 'थोक खरीदार'),
      ),
    );

    final quantity =
        '${_string(request['targetQuantity'], '—')} ${_string(request['unit'], 'kg')}';

    final location = [
      _string(request['deliveryCity']),
      _string(request['deliveryState']),
    ].where((e) => e.isNotEmpty).join(', ');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  buyerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 18),
                _DetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: _text('Required quantity', 'आवश्यक मात्रा'),
                  value: quantity,
                ),
                _DetailRow(
                  icon: Icons.currency_rupee,
                  label: _text('Buyer target price', 'खरीदार की लक्षित कीमत'),
                  value:
                      '${_formatPrice(request['targetPricePerUnit'])}/${_string(request['unit'], 'kg')}',
                ),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: _text('Delivery location', 'डिलीवरी स्थान'),
                  value: location.isEmpty
                      ? _text('Not specified', 'उल्लेख नहीं')
                      : location,
                ),
                _DetailRow(
                  icon: Icons.event_outlined,
                  label: _text('Required by', 'आवश्यक तारीख'),
                  value: _formatDate(request['requiredByDate']),
                ),
                _DetailRow(
                  icon: Icons.tag_outlined,
                  label: _text('Request number', 'रिक्वेस्ट नंबर'),
                  value: _string(request['requestNumber'], '—'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showOfferForm(request);
                    },
                    icon: const Icon(Icons.local_offer_outlined),
                    label: Text(
                      _text('Make an Offer', 'ऑफर दें'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOfferForm(Map<String, dynamic> request) async {
    final requestId = _string(request['id'], '');
    final crop = _string(
      request['productTitle'],
      _text('Crop', 'फसल'),
    );
    final unit = _string(
      request['unit'],
      'Q',
    );

    if (requestId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              'Buyer request ID is missing.',
              'खरीदार अनुरोध ID उपलब्ध नहीं है।',
            ),
          ),
        ),
      );
      return;
    }

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FarmerOfferFormSheet(
        api: _api,
        requestId: requestId,
        crop: crop,
        unit: unit,
        englishText: (english, hindi) => _text(english, hindi),
      ),
    );

    if (!mounted || submitted != true) return;

    await _loadRequests();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _text(
            'Your offer was submitted successfully.',
            'आपका ऑफर सफलतापूर्वक भेज दिया गया।',
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> request) {
    final buyer = request['buyer'] is Map
        ? Map<String, dynamic>.from(request['buyer'] as Map)
        : <String, dynamic>{};

    final crop = _string(
      request['productTitle'],
      _text('Crop not specified', 'फसल उपलब्ध नहीं'),
    );

    final buyerName = _string(
      buyer['organizationName'],
      _string(
        buyer['name'],
        _text('Bulk Buyer', 'थोक खरीदार'),
      ),
    );

    final unit = _string(request['unit'], 'kg');
    final quantity = _string(request['targetQuantity'], '—');
    final city = _string(request['deliveryCity']);
    final state = _string(request['deliveryState']);
    final location = [city, state].where((e) => e.isNotEmpty).join(', ');

    final status = _string(request['status'], 'OPEN');
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(request),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      crop,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusText(status),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                buyerName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.inventory_2_outlined,
                    text: '$quantity $unit',
                  ),
                  _InfoChip(
                    icon: Icons.currency_rupee,
                    text:
                        '${_formatPrice(request['targetPricePerUnit'])}/$unit',
                  ),
                  if (location.isNotEmpty)
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      text: location,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 17),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_text('Required by', 'आवश्यक तारीख')}: ${_formatDate(request['requiredByDate'])}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showDetails(request),
                    child: Text(
                      _text('Details', 'विवरण'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      return RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 80),
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              _text(
                'Could not load buyer offers.',
                'खरीदारों के ऑफर लोड नहीं हो सके।',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: _loadRequests,
                icon: const Icon(Icons.refresh),
                label: Text(
                  _text('Try Again', 'फिर कोशिश करें'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 100),
            const Icon(
              Icons.local_offer_outlined,
              size: 58,
            ),
            const SizedBox(height: 16),
            Text(
              _text(
                'No buyer offers available right now.',
                'अभी कोई खरीदार ऑफर उपलब्ध नहीं है।',
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _text(
                'New bulk purchase requirements will appear here.',
                'नई थोक खरीद आवश्यकताएं यहां दिखाई देंगी।',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _requests.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                _text(
                  '${_requests.length} buyer requirement${_requests.length == 1 ? '' : 's'}',
                  '${_requests.length} खरीदार आवश्यकताएं',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            );
          }

          return _buildCard(_requests[index - 1]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text('Buyer Offers', 'खरीदार ऑफर'),
        ),
        actions: [
          IconButton(
            tooltip: _text('Refresh', 'रिफ्रेश'),
            onPressed: _loading ? null : _loadRequests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
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

class _FarmerOfferFormSheet extends StatefulWidget {
  const _FarmerOfferFormSheet({
    required this.api,
    required this.requestId,
    required this.crop,
    required this.unit,
    required this.englishText,
  });

  final ApiService api;
  final String requestId;
  final String crop;
  final String unit;
  final String Function(String english, String hindi) englishText;

  @override
  State<_FarmerOfferFormSheet> createState() => _FarmerOfferFormSheetState();
}

class _FarmerOfferFormSheetState extends State<_FarmerOfferFormSheet> {
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;

  bool _logisticsIncluded = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );
    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (quantity == null || quantity <= 0) {
      _showMessage(
        widget.englishText(
          'Enter a valid quantity.',
          'सही मात्रा दर्ज करें।',
        ),
      );
      return;
    }

    if (price == null || price <= 0) {
      _showMessage(
        widget.englishText(
          'Enter a valid offer price.',
          'सही ऑफर भाव दर्ज करें।',
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _submitting = true;
    });

    try {
      await widget.api.createFarmerOffer(
        requestId: widget.requestId,
        offeredQuantity: quantity,
        offeredPricePerUnit: price,
        logisticsIncluded: _logisticsIncluded,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage(
        widget.englishText(
          'Could not submit offer. Please try again.',
          'ऑफर भेजा नहीं जा सका। कृपया फिर प्रयास करें।',
        ),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.englishText(
                    'Make an Offer',
                    'ऑफर दें',
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.crop,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _quantityController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: widget.englishText(
                      'Your quantity',
                      'आपकी मात्रा',
                    ),
                    hintText: 'e.g. 100',
                    suffixText: widget.unit,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _priceController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: widget.englishText(
                      'Your offer price',
                      'आपका ऑफर भाव',
                    ),
                    hintText: 'e.g. 24',
                    prefixText: '₹ ',
                    suffixText: '/${widget.unit}',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _logisticsIncluded,
                  onChanged: _submitting
                      ? null
                      : (value) {
                          setState(() {
                            _logisticsIncluded = value;
                          });
                        },
                  title: Text(
                    widget.englishText(
                      'Logistics included',
                      'डिलीवरी/लॉजिस्टिक्स शामिल',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _notesController,
                  enabled: !_submitting,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: widget.englishText(
                      'Notes (optional)',
                      'नोट्स (वैकल्पिक)',
                    ),
                    hintText: widget.englishText(
                      'Add any terms or details',
                      'कोई अतिरिक्त शर्त या जानकारी लिखें',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _submitting
                          ? widget.englishText(
                              'Submitting...',
                              'भेजा जा रहा है...',
                            )
                          : widget.englishText(
                              'Submit Offer',
                              'ऑफर भेजें',
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
