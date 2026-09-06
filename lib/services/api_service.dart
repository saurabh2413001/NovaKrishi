import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Central REST client for NovaKrishi.
///
/// Configure the backend at build/run time:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
///
/// Android emulator -> 10.0.2.2, iOS simulator -> 127.0.0.1.
/// For a physical phone use the computer's LAN IP, e.g. http://192.168.1.20:5000/api.
class ApiService {
  const ApiService();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.79.181.215:5000/api',
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
    return Uri.parse('$baseUrl/$normalized').replace(queryParameters: query);
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
    if (body != null) request.body = jsonEncode(body);

    final streamed = await request.send().timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamed);

    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      decoded = {'message': response.body};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Request failed (${response.statusCode})';
      throw ApiException(message, response.statusCode);
    }
    if (authRequired && _token == null) {
      throw const ApiException('Authentication required.', 401);
    }
    return decoded;
  }

  Future<bool> healthCheck() async {
    try {
      final data = await _request('GET', 'health');
      return data is Map && data['status'] == 'online';
    } catch (_) {
      return false;
    }
  }

  Future<void> sendOtp(String mobile) async {
    final value = mobile.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      throw const ApiException('Enter exactly 10 digits.', 400);
    }
    await _request('POST', 'auth/send-otp', body: {'identifier': value});
  }

  /// Verifies the 6-digit OTP, stores the returned JWT and returns the user.
  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    final value = mobile.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      throw const ApiException('Enter exactly 10 digits.', 400);
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      throw const ApiException('Enter the 6-digit OTP.', 400);
    }

    final data = await _request(
      'POST',
      'auth/verify-otp',
      body: {'identifier': value, 'otp': otp},
    );

    if (data is! Map || data['success'] != true || data['token'] == null) {
      throw const ApiException('OTP verification failed.', 400);
    }
    setToken(data['token']?.toString());
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    if (idToken.trim().isEmpty) {
      throw const ApiException('Google authentication token is missing.', 400);
    }
    final data = await _request('POST', 'auth/google', body: {'idToken': idToken});
    if (data is! Map || data['token'] == null) {
      throw const ApiException('Google sign-in failed.', 401);
    }
    setToken(data['token']?.toString());
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final data = await _request('GET', 'auth/me', authRequired: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _request('POST', 'auth/logout');
      }
    } finally {
      setToken(null);
    }
  }

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
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getMarketRates({String? state, String? district}) async {
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
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> getWeather() async {
    final data = await _request('GET', 'weather');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getAlerts({String? state, String? district, String? crop}) async {
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
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final data = await _request('GET', 'orders', authRequired: true);
    final list = data is Map ? (data['orders'] ?? data['data'] ?? []) : data;
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> analyzeCropPhoto(File image) async {
    final bytes = await image.readAsBytes();
    final encoded = base64Encode(bytes);
    final data = await _request(
      'POST',
      'ai/crop-scan',
      authRequired: true,
      body: {'imageBase64': encoded, 'filename': image.path.split('/').last},
    );
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final data = await _request('GET', 'cart', authRequired: true);
    final list = data is Map ? (data['items'] ?? data['cart'] ?? data['data'] ?? []) : data;
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> addToCart({required String productId, required int quantity}) async {
    final data = await _request('POST', 'cart', authRequired: true, body: {'productId': productId, 'quantity': quantity});
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> removeFromCart(String productId) async {
    await _request('DELETE', 'cart/$productId', authRequired: true);
  }

  Future<Map<String, dynamic>> createOrder({required List<Map<String, dynamic>> items, required Map<String, dynamic> deliveryAddress}) async {
    final data = await _request('POST', 'orders', authRequired: true, body: {'items': items, 'deliveryAddress': deliveryAddress});
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getOrderTracking(String orderId) async {
    final data = await _request('GET', 'orders/$orderId/tracking', authRequired: true);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getDemandForecast({String? crop, String? state, String? district}) async {
    final data = await _request('GET', 'ai/demand-forecast', query: {
      if (crop != null && crop.isNotEmpty) 'crop': crop,
      if (state != null && state.isNotEmpty) 'state': state,
      if (district != null && district.isNotEmpty) 'district': district,
    });
    final list = data is Map ? (data['forecasts'] ?? data['forecast'] ?? data['data'] ?? data['predictions'] ?? []) : data;
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> optimizeRoute(Map<String, dynamic> payload) async {
    final data = await _request('POST', 'ai/optimize-route', authRequired: true, body: payload);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getScans() async {
    final data = await _request('GET', 'scans', authRequired: true);
    final list = data is Map ? (data['scans'] ?? data['data'] ?? []) : data;
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> saveScan(Map<String, dynamic> payload) async {
    final data = await _request('POST', 'scans', authRequired: true, body: payload);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> payload) async {
    final data = await _request('POST', 'products', authRequired: true, body: payload);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> payload) async {
    final data = await _request('PUT', 'products/$id', authRequired: true, body: payload);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> deleteProduct(String id) async {
    await _request('DELETE', 'products/$id', authRequired: true);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
