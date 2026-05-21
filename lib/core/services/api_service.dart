import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 30));
      _log('GET', endpoint, response);
      return response;
    } catch (e) {
      _logError('GET', endpoint, e);
      rethrow;
    }
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {bool auth = true}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .post(uri, headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      _log('POST', endpoint, response);
      return response;
    } catch (e) {
      _logError('POST', endpoint, e);
      rethrow;
    }
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http
          .patch(uri, headers: await _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      _log('PATCH', endpoint, response);
      return response;
    } catch (e) {
      _logError('PATCH', endpoint, e);
      rethrow;
    }
  }



static Future<http.Response> put(
  String endpoint,
  Map<String, dynamic> body,
) async {
  try {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    final response = await http
        .put(
          uri,
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    _log('PUT', endpoint, response);
    return response;
  } catch (e) {
    _logError('PUT', endpoint, e);
    rethrow;
  }
}

  static void _log(String method, String endpoint, http.Response res) {
    if (kDebugMode) {
      print('[$method] $endpoint → ${res.statusCode}');
    }
  }

  static void _logError(String method, String endpoint, Object e) {
    if (kDebugMode) {
      print('[$method ERROR] $endpoint → $e');
    }
  }
}
