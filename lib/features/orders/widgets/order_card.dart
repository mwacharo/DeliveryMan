import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/order_model.dart';
import '../screens/order_detail_screen.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: order.customerPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sms() async {
    final uri = Uri(scheme: 'sms', path: order.customerPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final phone = order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final number = phone.startsWith('0') ? '254${phone.substring(1)}' : phone;
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
              order: order, onStatusChanged: onStatusChanged),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              Expanded(
                child: Text(order.orderNo,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5)),
              ),
              StatusBadge(
                  statusName: order.statusName,
                  statusColor: order.statusColor),
            ]),
          ),

          const SizedBox(height: 10),

          // Customer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Icon(Icons.person_outline,
                  size: 15, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(order.customerName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ),
              _paymentChip(),
            ]),
          ),

          const SizedBox(height: 8),

          // Addresses
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              _addressRow(Icons.trip_origin, AppTheme.accent, 'From',
                  order.pickupAddress),
              const SizedBox(height: 4),
              _addressRow(Icons.location_on_outlined, AppTheme.primary, 'To',
                  order.deliveryAddress),
            ]),
          ),

          const SizedBox(height: 10),

          // Vendor chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Icon(Icons.store_outlined,
                  size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(order.vendor.name,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ]),
          ),

          const SizedBox(height: 10),

          Divider(height: 1, color: Colors.white.withOpacity(0.06)),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(children: [
              _actionBtn(Icons.call_outlined, 'Call',
                  AppTheme.statusDispatched, _call),
              _actionBtn(Icons.sms_outlined, 'SMS',
                  AppTheme.textSecondary, _sms),
              _actionBtn(Icons.chat_outlined, 'WhatsApp',
                  const Color(0xFF25D366), _whatsapp),
              const Spacer(),
              Text('KSH ${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(width: 8),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _paymentChip() {
    final hasMpesa = order.hasMpesaPayment;
    final isPaid = order.isFullyPaid;
    Color color;
    String label;
    if (isPaid) {
      color = AppTheme.statusDelivered;
      label = 'Paid';
    } else if (hasMpesa) {
      color = AppTheme.statusAwaiting;
      label = 'M-Pesa';
    } else {
      color = AppTheme.accent;
      label = 'Cash';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _addressRow(
      IconData icon, Color color, String label, String address) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 5),
      Text('$label  ',
          style:
              const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      Expanded(
          child: Text(address,
              style:
                  const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
