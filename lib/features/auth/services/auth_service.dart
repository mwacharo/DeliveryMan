import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/rider_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await ApiService.post(
        ApiConstants.login,
        {
          'email': email,
          'password': password,
          'device_name': 'Bringit Rider App',
        },
        auth: false,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: 'auth_token', value: data['token']);
        final rider = RiderModel.fromJson(data['user']);
        await _storage.write(key: 'rider_id', value: rider.id.toString());
        await _storage.write(key: 'rider_name', value: rider.name);
        await _storage.write(key: 'rider_email', value: rider.email);
        await _storage.write(key: 'rider_phone', value: rider.phoneNumber);
        await _storage.write(
            key: 'rider_team_id', value: rider.currentTeamId.toString());
        await _storage.write(key: 'rider_status', value: rider.status);
        return {'success': true, 'rider': rider};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login failed. Check your credentials.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server. Check your network.',
      };
    }
  }

  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConstants.logout, {});
    } catch (_) {}
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getRiderName() async =>
      _storage.read(key: 'rider_name');
  static Future<String?> getRiderPhone() async =>
      _storage.read(key: 'rider_phone');
  static Future<String?> getRiderEmail() async =>
      _storage.read(key: 'rider_email');
  static Future<String?> getRiderStatus() async =>
      _storage.read(key: 'rider_status');
  static Future<void> saveRiderStatus(String status) async =>
      _storage.write(key: 'rider_status', value: status);
}
