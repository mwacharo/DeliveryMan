import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/order_model.dart';

class OrderService {
  static Future<List<OrderModel>> getOrders() async {
    final response = await ApiService.get(ApiConstants.orders);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Response: { success: true, data: { data: [...] } }
      final List raw = json['data']['data'] as List;
      return raw.map((o) => OrderModel.fromJson(o)).toList();
    }
    throw Exception('Failed to load orders: ${response.statusCode}');
  }

  static Future<OrderModel> getOrder(int id) async {
    final response = await ApiService.get('${ApiConstants.orders}/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return OrderModel.fromJson(data['data'] ?? data);
    }
    throw Exception('Failed to load order');
  }

  // static Future<bool> updateStatus(int id, String status,
  //     {String? notes}) async {
  //   final response = await ApiService.patch(
  //     '${ApiConstants.orders}/$id/status',
  //     {'status': status, if (notes != null) 'notes': notes},
  //   );
  //   return response.statusCode == 200;
  // }


  static Future<bool> updateStatus(int id, String status,
    {String? notes}) async {

  final response = await ApiService.put(
    '${ApiConstants.orders}/$id',
    {
      'status': status,
      if (notes != null) 'notes': notes,
    },
  );

  return response.statusCode == 200;
}

  static Future<Map<String, dynamic>> triggerStkPush({
    required int orderId,
    required String phone,
    required double amount,
    required String? orderNo,
  }) async {
    final response = await ApiService.post(
      ApiConstants.stkPush,
      {'order_id': orderId, 'phone': phone, 'amount': amount , 'order_no': orderNo},
    );
    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? '',
      'data': data,
    };
  }

  static Future<Map<String, dynamic>> submitMpesaCode({
    required int orderId,
    required String code,
    required double amount,
  }) async {
    final response = await ApiService.post(
      '${ApiConstants.orders}/$orderId/verify-mpesa',
      {'mpesa_code': code, 'amount': amount},
    );
    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? '',
    };
  }
}
