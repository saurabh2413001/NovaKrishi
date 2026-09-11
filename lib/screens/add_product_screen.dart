import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _fpoController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ApiService _api = ApiService();
  final ImagePicker _imagePicker = ImagePicker();
  File? _productImage;

  String _category = 'vegetables';
  String _unit = 'kg';
  bool _organic = false;
  bool _fpoVerified = false;
  bool _deliveryAvailable = true;
  bool _saving = false;

  final List<Map<String, String>> _categories = const [
    {'value': 'vegetables', 'label': 'Vegetables / सब्ज़ियाँ'},
    {'value': 'fruits', 'label': 'Fruits / फल'},
    {'value': 'grains', 'label': 'Grains / अनाज'},
    {'value': 'pulses', 'label': 'Pulses / दालें'},
    {'value': 'spices', 'label': 'Spices / मसाले'},
    {'value': 'other', 'label': 'Other / अन्य'},
  ];

  final List<String> _units = const [
    'kg',
    'quintal',
    'ton',
    'piece',
    'litre',
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minOrderController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _fpoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _positiveNumber(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return 'Enter a valid number greater than 0 / 0 से अधिक संख्या डालें';
    }

    return null;
  }

  Future<void> _pickProductImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  AppStrings.t('Take a photo', 'फोटो लें'),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  AppStrings.t('Choose from gallery', 'गैलरी से चुनें'),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (image != null && mounted) {
      setState(() {
        _productImage = File(image.path);
      });
    }
  }

  void _removeProductImage() {
    setState(() {
      _productImage = null;
    });
  }

  Future<void> _saveProduct() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_productImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              'Please add a product photo.',
              'कृपया उत्पाद की फोटो जोड़ें।',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Upload the selected product photo to the backend first.
      final imageUrl = await _api.uploadProductImage(_productImage!);

      final payload = <String, dynamic>{
        'title': _productNameController.text.trim(),
        'category': _category,
        'price': double.parse(_priceController.text.trim()),
        'unit': _unit,
        'availableQuantity': double.parse(_stockController.text.trim()),
        'minOrderQuantity':
            double.tryParse(_minOrderController.text.trim()) ?? 1,
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'fpoName': _fpoController.text.trim(),
        'isVerifiedFPO': _fpoVerified,
        'isOrganicCertified': _organic,
        'village': _villageController.text.trim(),
        'district': _districtController.text.trim(),
        'state': _stateController.text.trim(),
      };

      await _api.createProduct(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.t(
              'Product listed successfully',
              'उत्पाद सफलतापूर्वक लिस्ट हो गया',
            ),
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.t('Could not list product', 'उत्पाद लिस्ट नहीं हो सका')}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: AppStrings.t(
        label,
        _hindiLabel(label),
      ),
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  String _hindiLabel(String label) {
    const labels = {
      'Product name': 'उत्पाद का नाम',
      'Price': 'कीमत',
      'Stock quantity': 'स्टॉक मात्रा',
      'Minimum order quantity': 'न्यूनतम ऑर्डर मात्रा',
      'Village': 'गाँव',
      'District': 'ज़िला',
      'State': 'राज्य',
      'FPO name': 'FPO का नाम',
      'Description': 'विवरण',
      'Image URL': 'इमेज URL',
    };

    return labels[label] ?? label;
  }

  Widget _sectionTitle(String english, String hindi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        AppStrings.t(english, hindi),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.t(
            'Add Product',
            'उत्पाद जोड़ें',
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.agriculture,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.t(
                          'Create a professional product listing for buyers.',
                          'खरीदारों के लिए अपना उत्पाद लिस्ट करें।',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle('Product details', 'उत्पाद की जानकारी'),

              TextFormField(
                controller: _productNameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  'Product name',
                  Icons.inventory_2_outlined,
                ),
                validator: (value) => _required(
                  value,
                  'Product name is required / उत्पाद का नाम जरूरी है',
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _decoration(
                  'Category',
                  Icons.category_outlined,
                ),
                items: _categories
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['value'],
                        child: Text(item['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 520) {
                    return Column(
                      children: [
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration(
                            'Price',
                            Icons.currency_rupee,
                          ),
                          validator: (value) => _positiveNumber(
                            value,
                            'Price is required / कीमत जरूरी है',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _unit,
                          decoration: _decoration(
                            'Unit',
                            Icons.scale_outlined,
                          ),
                          items: _units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _unit = value);
                            }
                          },
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration(
                            'Price',
                            Icons.currency_rupee,
                          ),
                          validator: (value) => _positiveNumber(
                            value,
                            'Price is required / कीमत जरूरी है',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _unit,
                          decoration: _decoration(
                            'Unit',
                            Icons.scale_outlined,
                          ),
                          items: _units
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _unit = value);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 520) {
                    return Column(
                      children: [
                        TextFormField(
                          controller: _stockController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration(
                            'Stock quantity',
                            Icons.inventory_outlined,
                          ),
                          validator: (value) => _positiveNumber(
                            value,
                            'Stock is required / स्टॉक जरूरी है',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _minOrderController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration(
                            'Minimum order quantity',
                            Icons.shopping_cart_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return _positiveNumber(value, '');
                          },
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration(
                            'Stock quantity',
                            Icons.inventory_outlined,
                          ),
                          validator: (value) => _positiveNumber(
                            value,
                            'Stock is required / स्टॉक जरूरी है',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _minOrderController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration(
                            'Minimum order quantity',
                            Icons.shopping_cart_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return _positiveNumber(value, '');
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),
              _sectionTitle('Location', 'स्थान'),

              TextFormField(
                controller: _villageController,
                decoration: _decoration(
                  'Village',
                  Icons.home_work_outlined,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _districtController,
                decoration: _decoration(
                  'District',
                  Icons.location_city_outlined,
                ),
                validator: (value) => _required(
                  value,
                  'District is required / ज़िला जरूरी है',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _stateController,
                decoration: _decoration(
                  'State',
                  Icons.map_outlined,
                ),
                validator: (value) => _required(
                  value,
                  'State is required / राज्य जरूरी है',
                ),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Quality & FPO', 'गुणवत्ता और FPO'),

              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppStrings.t(
                    'Organic certified',
                    'ऑर्गेनिक प्रमाणित',
                  ),
                ),
                value: _organic,
                onChanged: (value) {
                  setState(() => _organic = value);
                },
              ),

              TextFormField(
                controller: _fpoController,
                decoration: _decoration(
                  'FPO name',
                  Icons.groups_outlined,
                ),
              ),

              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppStrings.t(
                    'Verified FPO',
                    'सत्यापित FPO',
                  ),
                ),
                value: _fpoVerified,
                onChanged: (value) {
                  setState(() => _fpoVerified = value);
                },
              ),

              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppStrings.t(
                    'Delivery available',
                    'डिलीवरी उपलब्ध',
                  ),
                ),
                value: _deliveryAvailable,
                onChanged: (value) {
                  setState(() => _deliveryAvailable = value);
                },
              ),

              const SizedBox(height: 20),
              _sectionTitle('Product image', 'उत्पाद की फोटो'),

              GestureDetector(
                onTap: _pickProductImage,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _productImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppStrings.t(
                                'Tap to add product photo',
                                'उत्पाद की फोटो जोड़ने के लिए टैप करें',
                              ),
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.t(
                                'Camera or Gallery',
                                'कैमरा या गैलरी',
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _productImage!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Row(
                                children: [
                                  Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      tooltip: AppStrings.t(
                                        'Change photo',
                                        'फोटो बदलें',
                                      ),
                                      onPressed: _pickProductImage,
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Material(
                                    color: Colors.black54,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      tooltip: AppStrings.t(
                                        'Remove photo',
                                        'फोटो हटाएँ',
                                      ),
                                      onPressed: _removeProductImage,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                AppStrings.t(
                  'A clear product photo helps buyers understand your listing.',
                  'साफ उत्पाद फोटो से खरीदार आपके उत्पाद को बेहतर समझ सकते हैं।',
                ),
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 20),
              _sectionTitle('Description', 'विवरण'),

              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  'Description',
                  Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveProduct,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _saving
                        ? AppStrings.t(
                            'Publishing...',
                            'पब्लिश हो रहा है...',
                          )
                        : AppStrings.t(
                            'Publish Product',
                            'उत्पाद पब्लिश करें',
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
