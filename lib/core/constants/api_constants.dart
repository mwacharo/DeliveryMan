class ApiConstants {
  // 10.0.2.2 = localhost from Android emulator
  // For physical device, change to your machine's local IP e.g. http://192.168.1.100
  // static const String baseUrl = 'http://10.0.2.2/CustomerService/api';

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String login         = '/v1/rider/login';
  static const String logout        = '/v1/rider/logout';
  static const String riderStatus   = '/v1/rider/status';
  static const String orders        = '/v1/orders';
  static const String stkPush       = '/v1/payments/mpesa/stk-push';
  static const String whatsapp      = '/v1/whatsapp/send-message';
}
