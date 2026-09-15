import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Central REST client for NovaKrishi.
///
/// Configure the backend at build/run time:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
///
/// Android emulator -> 10.0.2.2, iOS simulator -> 127.0.0.1.
/// For a physical phone use the computer's LAN IP.
class ApiService {
  const ApiService();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://novakrishi-8ayt.onrender.com/api',
  );

  static String? _token;

  static void setToken(String? token) => _token = token;

  static String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse('$baseUrl/$normalized').replace(
      queryParameters: query,
    );
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool authRequired = false,
  }) async {
    final uri = _uri(path, query);

    final request = http.Request(method, uri)..headers.addAll(_headers);

    if (body != null) {
      request.body = jsonEncode(body);
    }

    // ------------------------------------------------------------
    // IMPORTANT:
    // Do not print Authorization header or JWT token.
    // ------------------------------------------------------------

    debugPrint('NOVAKRISHI API: $method $uri');

    if (body is Map) {
      // Don't print potentially huge imageBase64 data.
      final safeBody = Map<String, dynamic>.from(body);

      if (safeBody.containsKey('imageBase64')) {
        final imageBase64 = safeBody['imageBase64'];

        safeBody['imageBase64'] =
            '[base64 omitted: ${imageBase64 is String ? imageBase64.length : 0} chars]';
      }

      debugPrint('NOVAKRISHI API BODY: $safeBody');
    }

    try {
      final streamed =
          await request.send().timeout(const Duration(seconds: 30));

      final response = await http.Response.fromStream(streamed);

      debugPrint(
        'NOVAKRISHI API STATUS: ${response.statusCode}',
      );

      // Avoid dumping a massive response into the console.
      if (response.body.length > 5000) {
        debugPrint(
          'NOVAKRISHI API RESPONSE: '
          '${response.body.substring(0, 5000)}... [truncated]',
        );
      } else {
        debugPrint(
          'NOVAKRISHI API RESPONSE: ${response.body}',
        );
      }

      dynamic decoded;

      try {
        decoded = response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body);
      } catch (_) {
        decoded = {
          'message': response.body,
        };
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map && decoded['message'] != null
            ? decoded['message'].toString()
            : 'Request failed (${response.statusCode})';

        debugPrint(
          'NOVAKRISHI API ERROR: '
          'HTTP ${response.statusCode}: $message',
        );

        throw ApiException(
          message,
          response.statusCode,
        );
      }

      if (authRequired && _token == null) {
        debugPrint(
          'NOVAKRISHI API ERROR: Authentication required '
          'but no token is available.',
        );

        throw const ApiException(
          'Authentication required.',
          401,
        );
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on SocketException catch (error) {
      debugPrint(
        'NOVAKRISHI API SOCKET ERROR: $error',
      );

      throw const ApiException(
        'Unable to connect to the NovaKrishi server.',
        0,
      );
    } on http.ClientException catch (error) {
      debugPrint(
        'NOVAKRISHI API CLIENT ERROR: $error',
      );

      throw const ApiException(
        'Network error while connecting to NovaKrishi.',
        0,
      );
    } on FormatException catch (error) {
      debugPrint(
        'NOVAKRISHI API FORMAT ERROR: $error',
      );

      throw const ApiException(
        'Invalid response received from server.',
        0,
      );
    } catch (error) {
      debugPrint(
        'NOVAKRISHI API UNKNOWN ERROR: $error',
      );

      rethrow;
    }
  }

  // ------------------------------------------------------------
  // HEALTH
  // ------------------------------------------------------------

  Future<bool> healthCheck() async {
    try {
      final data = await _request(
        'GET',
        'health',
      );

      return data is Map && data['status'] == 'online';
    } catch (error) {
      debugPrint(
        'NOVAKRISHI HEALTH ERROR: $error',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // OTP
  // ------------------------------------------------------------

  Future<void> sendOtp(String mobile) async {
    final value = mobile.replaceAll(RegExp(r'\D'), '');

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      throw const ApiException(
        'Enter exactly 10 digits.',
        400,
      );
    }

    await _request(
      'POST',
      'auth/send-otp',
      body: {
        'identifier': value,
      },
    );
  }

  /// Verifies the 6-digit OTP,
  /// stores the returned JWT,
  /// and returns the user response.
  Future<Map<String, dynamic>> verifyOtp(
    String mobile,
    String otp,
  ) async {
    final value = mobile.replaceAll(RegExp(r'\D'), '');

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      throw const ApiException(
        'Enter exactly 10 digits.',
        400,
      );
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      throw const ApiException(
        'Enter the 6-digit OTP.',
        400,
      );
    }

    final data = await _request(
      'POST',
      'auth/verify-otp',
      body: {
        'identifier': value,
        'otp': otp,
      },
    );

    if (data is! Map || data['success'] != true || data['token'] == null) {
      throw const ApiException(
        'OTP verification failed.',
        400,
      );
    }

    setToken(
      data['token']?.toString(),
    );

    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // GOOGLE LOGIN
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> googleSignIn(
    String idToken,
  ) async {
    if (idToken.trim().isEmpty) {
      throw const ApiException(
        'Google authentication token is missing.',
        400,
      );
    }

    final data = await _request(
      'POST',
      'auth/google',
      body: {
        'idToken': idToken,
      },
    );

    if (data is! Map || data['token'] == null) {
      throw const ApiException(
        'Google sign-in failed.',
        401,
      );
    }

    setToken(
      data['token']?.toString(),
    );

    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // CURRENT USER
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> getCurrentUser() async {
    final data = await _request(
      'GET',
      'auth/me',
      authRequired: true,
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _request(
          'POST',
          'auth/logout',
        );
      }
    } finally {
      setToken(null);
    }
  }

  // ------------------------------------------------------------
  // PRODUCTS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getProducts({
    String? search,
    String? category,
    int limit = 6,
  }) async {
    final data = await _request(
      'GET',
      'products',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        'limit': '$limit',
      },
    );

    final list = data is Map ? data['products'] : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getMyProducts() async {
    final data = await _request(
      'GET',
      'products/my-products',
      authRequired: true,
    );

    final list = data is Map ? data['products'] : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // MARKET RATES
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getMarketRates({
    String? state,
    String? district,
  }) async {
    final data = await _request(
      'GET',
      'market-rates',
      query: {
        if (state != null && state.isNotEmpty) 'state': state,
        if (district != null && district.isNotEmpty) 'district': district,
      },
    );

    final list = data is Map
        ? (data['data'] ?? data['records'] ?? data['rates'] ?? [])
        : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // WEATHER
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> getWeather() async {
    final data = await _request(
      'GET',
      'weather',
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // ALERTS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAlerts({
    String? state,
    String? district,
    String? crop,
  }) async {
    final data = await _request(
      'GET',
      'alerts',
      query: {
        if (state != null && state.isNotEmpty) 'state': state,
        if (district != null && district.isNotEmpty) 'district': district,
        if (crop != null && crop.isNotEmpty) 'crop': crop,
      },
    );

    final list = data is Map ? data['alerts'] : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // ORDERS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getOrders() async {
    final data = await _request(
      'GET',
      'orders',
      authRequired: true,
    );

    final list = data is Map ? (data['orders'] ?? data['data'] ?? []) : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // AI CROP SCAN
  // ------------------------------------------------------------

  Future<Map<String, dynamic>?> analyzeCropPhoto(
    File image,
  ) async {
    final bytes = await image.readAsBytes();

    final encoded = base64Encode(bytes);

    final data = await _request(
      'POST',
      'ai/crop-scan',
      authRequired: true,
      body: {
        'imageBase64': encoded,
        'filename': image.path.split('/').last,
      },
    );

    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // ------------------------------------------------------------
  // CART
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCart() async {
    final data = await _request(
      'GET',
      'cart',
      authRequired: true,
    );

    final list = data is Map
        ? (data['items'] ?? data['cart'] ?? data['data'] ?? [])
        : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    final data = await _request(
      'POST',
      'cart',
      authRequired: true,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  Future<void> removeFromCart(
    String productId,
  ) async {
    await _request(
      'DELETE',
      'cart/$productId',
      authRequired: true,
    );
  }

  // ------------------------------------------------------------
  // CREATE ORDER
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    final data = await _request(
      'POST',
      'orders',
      authRequired: true,
      body: {
        'items': items,
        'deliveryAddress': deliveryAddress,
      },
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // ORDER TRACKING
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> getOrderTracking(
    String orderId,
  ) async {
    final data = await _request(
      'GET',
      'orders/$orderId/tracking',
      authRequired: true,
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // DEMAND FORECAST
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getDemandForecast({
    String? crop,
    String? state,
    String? district,
  }) async {
    final data = await _request(
      'GET',
      'ai/demand-forecast',
      query: {
        if (crop != null && crop.isNotEmpty) 'crop': crop,
        if (state != null && state.isNotEmpty) 'state': state,
        if (district != null && district.isNotEmpty) 'district': district,
      },
    );

    final list = data is Map
        ? (data['forecasts'] ??
            data['forecast'] ??
            data['data'] ??
            data['predictions'] ??
            [])
        : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // ROUTE OPTIMIZATION
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> optimizeRoute(
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'POST',
      'ai/optimize-route',
      authRequired: true,
      body: payload,
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // SCANS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getScans() async {
    final data = await _request(
      'GET',
      'scans',
      authRequired: true,
    );

    final list = data is Map ? (data['scans'] ?? data['data'] ?? []) : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  Future<Map<String, dynamic>> saveScan(
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'POST',
      'scans',
      authRequired: true,
      body: payload,
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // BULK BUYER REQUESTS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getBulkRequests() async {
    final data = await _request(
      'GET',
      'bulk-requests',
      authRequired: true,
    );

    final list =
        data is Map ? (data['bulkRequests'] ?? data['data'] ?? []) : data;

    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  Future<Map<String, dynamic>> createBulkRequest({
    required String productTitle,
    String category = 'Vegetables',
    required double targetQuantity,
    String unit = 'kg',
    required String deliveryCity,
    String deliveryState = '',
    required String requiredByDate,
    double? targetPricePerUnit,
  }) async {
    if (productTitle.trim().isEmpty) {
      throw Exception('Crop name is required');
    }

    if (targetQuantity <= 0) {
      throw Exception('Required quantity must be greater than 0');
    }

    if (deliveryCity.trim().isEmpty) {
      throw Exception('Delivery city is required');
    }

    final response = await _request(
      'POST',
      'bulk-requests',
      body: {
        'productTitle': productTitle.trim(),
        'category': category.trim().isEmpty ? 'Vegetables' : category.trim(),
        'targetQuantity': targetQuantity,
        'unit': unit.trim().isEmpty ? 'kg' : unit.trim(),
        'deliveryCity': deliveryCity.trim(),
        'deliveryState': deliveryState.trim(),
        'requiredByDate': requiredByDate,
        if (targetPricePerUnit != null && targetPricePerUnit > 0)
          'targetPricePerUnit': targetPricePerUnit,
      },
      authRequired: true,
    );

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Invalid bulk request response');
  }

  Future<Map<String, dynamic>> acceptFarmerOffer({
    required String requestId,
    required String offerId,
  }) async {
    if (requestId.trim().isEmpty) {
      throw Exception('Invalid buyer request');
    }

    if (offerId.trim().isEmpty) {
      throw Exception('Invalid farmer offer');
    }

    final response = await _request(
      'POST',
      'bulk-requests/$requestId/offers/$offerId/accept',
      authRequired: true,
    );

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Invalid accept offer response');
  }

  // ------------------------------------------------------------
  // FARMER OFFER
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> createFarmerOffer({
    required String requestId,
    required double offeredQuantity,
    required double offeredPricePerUnit,
    bool logisticsIncluded = false,
    String notes = '',
  }) async {
    if (requestId.trim().isEmpty) {
      throw Exception(
        'Invalid buyer request',
      );
    }

    if (offeredQuantity <= 0) {
      throw Exception(
        'Offered quantity must be greater than 0',
      );
    }

    if (offeredPricePerUnit <= 0) {
      throw Exception(
        'Offered price must be greater than 0',
      );
    }

    final response = await _request(
      'POST',
      'bulk-requests/$requestId/offers',
      body: {
        'offeredQuantity': offeredQuantity,
        'offeredPricePerUnit': offeredPricePerUnit,
        'logisticsIncluded': logisticsIncluded,
        'notes': notes.trim(),
      },
      authRequired: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return <String, dynamic>{};
  }

  // ------------------------------------------------------------
  // PRODUCT IMAGE UPLOAD
  // ------------------------------------------------------------

  Future<String> uploadProductImage(
    File imageFile,
  ) async {
    final bytes = await imageFile.readAsBytes();

    debugPrint(
      'NOVAKRISHI IMAGE BYTES: ${bytes.length}',
    );

    final base64Image = base64Encode(bytes);

    debugPrint(
      'NOVAKRISHI IMAGE BASE64 CHARS: '
      '${base64Image.length}',
    );

    final extension = imageFile.path.split('.').last.toLowerCase();

    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' || 'heif' => 'image/heic',
      _ => 'image/jpeg',
    };

    debugPrint(
      'NOVAKRISHI IMAGE TYPE: $contentType',
    );

    final response = await _request(
      'POST',
      'product-images',
      body: {
        'imageBase64': base64Image,
        'contentType': contentType,
        'fileName': imageFile.path.split('/').last,
      },
      authRequired: true,
    );

    if (response is! Map) {
      throw const ApiException(
        'Product image upload failed.',
        500,
      );
    }

    final imageUrl = response['imageUrl']?.toString();

    if (imageUrl == null || imageUrl.isEmpty) {
      throw const ApiException(
        'Product image upload failed.',
        500,
      );
    }

    debugPrint(
      'NOVAKRISHI IMAGE URL: $imageUrl',
    );

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    final serverBaseUrl = baseUrl.endsWith('/api')
        ? baseUrl.substring(
            0,
            baseUrl.length - 4,
          )
        : baseUrl;

    final fullImageUrl = '$serverBaseUrl$imageUrl';

    debugPrint(
      'NOVAKRISHI FULL IMAGE URL: '
      '$fullImageUrl',
    );

    return fullImageUrl;
  }

  // ------------------------------------------------------------
  // CREATE PRODUCT
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> payload,
  ) async {
    debugPrint(
      'NOVAKRISHI CREATE PRODUCT START',
    );

    final data = await _request(
      'POST',
      'products',
      authRequired: true,
      body: payload,
    );

    debugPrint(
      'NOVAKRISHI CREATE PRODUCT SUCCESS',
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // UPDATE PRODUCT
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'PUT',
      'products/$id',
      authRequired: true,
      body: payload,
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ------------------------------------------------------------
  // DELETE PRODUCT
  // ------------------------------------------------------------

  Future<void> deleteProduct(
    String id,
  ) async {
    await _request(
      'DELETE',
      'products/$id',
      authRequired: true,
    );
  }
}

// ============================================================
// API EXCEPTION
// ============================================================

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(
    this.message,
    this.statusCode,
  );

  @override
  String toString() {
    if (statusCode > 0) {
      return 'HTTP $statusCode: $message';
    }

    return message;
  }
}
