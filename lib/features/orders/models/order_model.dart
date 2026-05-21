class OrderModel {
  final int id;
  final String orderNo;
  final String currency;
  final double subTotal;
  final double totalPrice;
  final double shippingCharges;
  final double amountPaid;
  final bool paid;
  final String? customerNotes;
  final String? deliveryDate;
  final String createdAt;
  final String updatedAt;
  final CustomerModel customer;
  final VendorModel vendor;
  final WarehouseModel? warehouse;
  final List<OrderItem> orderItems;
  final List<Assignment> assignments;
  final List<Payment> payments;
  final OrderStatus? latestStatus;
  final List<OrderStatus> statusTimestamps;

  OrderModel({
    required this.id,
    required this.orderNo,
    required this.currency,
    required this.subTotal,
    required this.totalPrice,
    required this.shippingCharges,
    required this.amountPaid,
    required this.paid,
    this.customerNotes,
    this.deliveryDate,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
    required this.vendor,
    this.warehouse,
    required this.orderItems,
    required this.assignments,
    required this.payments,
    this.latestStatus,
    required this.statusTimestamps,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        orderNo: '#${json['order_no'] ?? json['id']}',
        currency: json['currency'] ?? 'KSH',
        subTotal: double.tryParse(json['sub_total'].toString()) ?? 0.0,
        totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
        shippingCharges:
            double.tryParse(json['shipping_charges'].toString()) ?? 0.0,
        amountPaid: double.tryParse(json['amount_paid'].toString()) ?? 0.0,
        paid: json['paid'] ?? false,
        customerNotes: json['customer_notes'],
        deliveryDate: json['delivery_date'],
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        customer: CustomerModel.fromJson(json['customer'] ?? {}),
        vendor: VendorModel.fromJson(json['vendor'] ?? {}),
        warehouse: json['warehouse'] != null
            ? WarehouseModel.fromJson(json['warehouse'])
            : null,
        orderItems: (json['order_items'] as List<dynamic>? ?? [])
            .map((i) => OrderItem.fromJson(i))
            .toList(),
        assignments: (json['assignments'] as List<dynamic>? ?? [])
            .map((a) => Assignment.fromJson(a))
            .toList(),
        payments: (json['payments'] as List<dynamic>? ?? [])
            .map((p) => Payment.fromJson(p))
            .toList(),
        latestStatus: json['latest_status'] != null
            ? OrderStatus.fromJson(json['latest_status'])
            : null,
        statusTimestamps: (json['status_timestamps'] as List<dynamic>? ?? [])
            .map((s) => OrderStatus.fromJson(s))
            .toList(),
      );

  String get statusName => latestStatus?.status?.name ?? 'Unknown';
  String get statusColor => latestStatus?.status?.color ?? 'gray';
  String get customerName => customer.fullName;
  String get customerPhone => customer.phone ?? '';
  String get deliveryAddress =>
      customer.address ?? customer.zone?.name ?? customer.city?.name ?? '';
  String get pickupAddress => warehouse?.name ?? 'HQ';
  bool get hasMpesaPayment => payments.isNotEmpty;
  bool get isFullyPaid => paid;
  Payment? get latestPayment => payments.isNotEmpty ? payments.last : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_no': orderNo.replaceAll('#', ''),
        'currency': currency,
        'sub_total': subTotal,
        'total_price': totalPrice,
        'shipping_charges': shippingCharges,
        'amount_paid': amountPaid,
        'paid': paid,
        'customer_notes': customerNotes,
        'delivery_date': deliveryDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'customer': customer.toJson(),
        'vendor': vendor.toJson(),
        'warehouse': warehouse?.toJson(),
        'order_items': orderItems.map((i) => i.toJson()).toList(),
        'assignments': assignments.map((a) => a.toJson()).toList(),
        'payments': payments.map((p) => p.toJson()).toList(),
        'latest_status': latestStatus?.toJson(),
        'status_timestamps': statusTimestamps.map((s) => s.toJson()).toList(),
      };
}

class CustomerModel {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? address;
  final CityModel? city;
  final ZoneModel? zone;

  CustomerModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.zone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] ?? 0,
        fullName: json['full_name'] ?? json['name'] ?? 'Unknown',
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
        zone: json['zone'] != null ? ZoneModel.fromJson(json['zone']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'address': address,
      };
}

class CityModel {
  final int id;
  final String name;
  CityModel({required this.id, required this.name});
  factory CityModel.fromJson(Map<String, dynamic> json) =>
      CityModel(id: json['id'], name: json['name'] ?? '');
}

class ZoneModel {
  final int id;
  final String name;
  ZoneModel({required this.id, required this.name});
  factory ZoneModel.fromJson(Map<String, dynamic> json) =>
      ZoneModel(id: json['id'], name: json['name'] ?? '');
}

class VendorModel {
  final int id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? profilePhotoUrl;

  VendorModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.profilePhotoUrl,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        phoneNumber: json['phone_number'],
        email: json['email'],
        profilePhotoUrl: json['profile_photo_url'],
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'phone_number': phoneNumber};
}

class WarehouseModel {
  final int id;
  final String name;
  final String? location;
  final String? phone;

  WarehouseModel(
      {required this.id, required this.name, this.location, this.phone});

  factory WarehouseModel.fromJson(Map<String, dynamic> json) => WarehouseModel(
        id: json['id'],
        name: json['name'] ?? 'Warehouse',
        location: json['location'],
        phone: json['phone'],
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'location': location};
}

class OrderItem {
  final int id;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final String currency;
  final ProductModel? product;

  OrderItem({
    required this.id,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    required this.currency,
    this.product,
  });

  String get productName => product?.productName ?? sku;
  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'],
        sku: json['sku'] ?? '',
        quantity: json['quantity'] ?? 1,
        unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0.0,
        totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
        discount: double.tryParse(json['discount'].toString()) ?? 0.0,
        currency: json['currency'] ?? 'KSH',
        product: json['product'] != null
            ? ProductModel.fromJson(json['product'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
      };
}

class ProductModel {
  final int id;
  final String sku;
  final String productName;
  final String? description;

  ProductModel(
      {required this.id,
      required this.sku,
      required this.productName,
      this.description});

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        sku: json['sku'] ?? '',
        productName: json['product_name'] ?? json['sku'] ?? '',
        description: json['description'],
      );
}

class Assignment {
  final int id;
  final int orderId;
  final int userId;
  final String role;
  final String status;

  Assignment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.role,
    required this.status,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        id: json['id'],
        orderId: json['order_id'],
        userId: json['user_id'],
        role: json['role'] ?? '',
        status: json['status'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'user_id': userId,
        'role': role,
        'status': status,
      };
}

class Payment {
  final int id;
  final int orderId;
  final String? transactionId;
  final String? checkoutRequestId;
  final String? mpesaReceipt;
  final String phone;
  final double amount;
  final int status;
  final String? resultDesc;
  final String createdAt;

  Payment({
    required this.id,
    required this.orderId,
    this.transactionId,
    this.checkoutRequestId,
    this.mpesaReceipt,
    required this.phone,
    required this.amount,
    required this.status,
    this.resultDesc,
    required this.createdAt,
  });

  bool get isConfirmed => status == 1 || mpesaReceipt != null;
  bool get isPending => status == 0 && mpesaReceipt == null;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        orderId: json['order_id'],
        transactionId: json['transaction_id'],
        checkoutRequestId: json['checkout_request_id'],
        mpesaReceipt: json['mpesa_receipt'],
        phone: json['phone'] ?? '',
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        status: json['status'] ?? 0,
        resultDesc: json['result_desc'],
        createdAt: json['created_at'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'amount': amount,
        'status': status,
        'mpesa_receipt': mpesaReceipt,
      };
}

class OrderStatus {
  final int id;
  final int orderId;
  final int statusId;
  final String? statusNotes;
  final String? createdAt;
  final StatusDetail? status;

  OrderStatus({
    required this.id,
    required this.orderId,
    required this.statusId,
    this.statusNotes,
    this.createdAt,
    this.status,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) => OrderStatus(
        id: json['id'] ?? 0,
        orderId: json['order_id'] ?? 0,
        statusId: json['status_id'] ?? 0,
        statusNotes: json['status_notes'],
        createdAt: json['created_at'],
        status: json['status'] != null
            ? StatusDetail.fromJson(json['status'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'status_id': statusId,
        'status_notes': statusNotes,
        'created_at': createdAt,
        'status': status?.toJson(),
      };
}

class StatusDetail {
  final int id;
  final String name;
  final String? statusCategory;
  final String? description;
  final String color;

  StatusDetail({
    required this.id,
    required this.name,
    this.statusCategory,
    this.description,
    required this.color,
  });

  factory StatusDetail.fromJson(Map<String, dynamic> json) => StatusDetail(
        id: json['id'],
        name: json['name'] ?? '',
        statusCategory: json['status_category'],
        description: json['description'],
        color: json['color'] ?? 'gray',
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
}
