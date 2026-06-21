import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/order_model.dart';
// import '../models/status_option_model.dart';
import '../models/status_option_model.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onStatusChanged;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;
  bool _itemsExpanded = false;
  bool _stkLoading = false;
  String _paymentStatus = 'idle';
  String? _mpesaCode;


    List<StatusOption> _availableStatuses = [];
  bool _loadingStatuses = false;

  @override
  void initState() {
    super.initState();
        _loadAvailableStatuses();

    _order = widget.order;
    // If order already has a payment, reflect it
    if (_order.latestPayment != null) {
      if (_order.latestPayment!.isConfirmed) {
        _paymentStatus = 'confirmed';
        _mpesaCode = _order.latestPayment!.mpesaReceipt;
      } else if (_order.latestPayment!.isPending) {
        _paymentStatus = 'awaiting';
      }
    }
  }


  IconData _statusIcon(String name) {
  switch (name.toLowerCase()) {
    case 'delivered':
      return Icons.check_circle_outline;
    case 'undispatched':
      return Icons.cancel_outlined;
    case 'rescheduled':
      return Icons.schedule_outlined;
    case 'awaiting return':
      return Icons.keyboard_return;
    case 'in transit':
      return Icons.local_shipping_outlined;
    case 'paid':
      return Icons.payments_outlined;
    default:
      return Icons.radio_button_checked;
  }
}


Color _statusColor(String color) {
  switch (color.toLowerCase()) {
    case 'green':
      return Colors.green;
    case 'red':
      return Colors.red;
    case 'orange':
      return Colors.orange;
    case 'blue':
      return Colors.blue;
    case 'gray':
      return Colors.grey;
    default:
      return AppTheme.primary;
  }
}

Future<void> _loadAvailableStatuses() async {
  try {
    setState(() => _loadingStatuses = true);

    final result = await OrderService.availableStatuses();

    setState(() {
      _availableStatuses = result;
    });
  } catch (e) {
    debugPrint('Failed to load statuses: $e');
  } finally {
    if (mounted) {
      setState(() => _loadingStatuses = false);
    }
  }
}

  // ── Communication ────────────────────────────────────────────────

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _order.customerPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sms([String? body]) async {
    final uri = Uri(
      scheme: 'sms',
      path: _order.customerPhone,
      queryParameters: body != null ? {'body': body} : null,
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp([String? message]) async {
    final phone = _order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final number = phone.startsWith('0') ? '254${phone.substring(1)}' : phone;
    final text = Uri.encodeComponent(message ?? '');
    final uri = Uri.parse('https://wa.me/$number?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── STK Push ─────────────────────────────────────────────────────

  Future<void> _sendStkPush() async {
    setState(() { _stkLoading = true; _paymentStatus = 'awaiting'; });
    final result = await OrderService.triggerStkPush(
      orderId: _order.id,
      // orderNo: _order.orderNo,
        orderNo: _order.orderNo.replaceAll('#', ''),

      phone: _order.customerPhone,
      amount: _order.totalPrice,

    );
    setState(() => _stkLoading = false);
    if (result['success']) {
      _showSnack('STK Push sent to ${_order.customerPhone}', success: true);
    } else {
      setState(() => _paymentStatus = 'failed');
      _showSnack(result['message'] ?? 'STK Push failed', success: false);
    }
  }

  // ── Manual Mpesa ──────────────────────────────────────────────────

  void _showManualMpesaSheet() {
    final codeCtrl = TextEditingController();
    final amountCtrl =
        TextEditingController(text: _order.totalPrice.toStringAsFixed(0));
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            const Text('Enter M-Pesa Code',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Order ${_order.orderNo}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9a-z]'))
              ],
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 20,
                  letterSpacing: 3),
              decoration: InputDecoration(
                labelText: 'M-Pesa Transaction Code',
                hintText: 'e.g. RGH7X3K2QP',
                hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.4),
                    fontSize: 14,
                    letterSpacing: 1),
                prefixIcon: const Icon(Icons.confirmation_number_outlined,
                    color: AppTheme.statusAwaiting),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Amount (KSH)',
                prefixIcon:
                    Icon(Icons.payments_outlined, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusAwaiting),
                onPressed: loading
                    ? null
                    : () async {
                        if (codeCtrl.text.trim().isEmpty) {
                          _showSnack('Enter the M-Pesa transaction code',
                              success: false);
                          return;
                        }
                        setSheet(() => loading = true);
                        final result = await OrderService.submitMpesaCode(
                          orderId: _order.id,
                          code: codeCtrl.text.trim().toUpperCase(),
                          amount: double.tryParse(amountCtrl.text) ??
                              _order.totalPrice,
                        );
                        setSheet(() => loading = false);
                        if (result['success']) {
                          Navigator.pop(ctx);
                          setState(() {
                            _paymentStatus = 'confirmed';
                            _mpesaCode =
                                codeCtrl.text.trim().toUpperCase();
                          });
                          _showSnack('Payment confirmed!', success: true);
                          widget.onStatusChanged();
                        } else {
                          _showSnack(
                              result['message'] ?? 'Could not verify code',
                              success: false);
                        }
                      },
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Payment',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ]),
        ),
      ),
    );
  }




  void _showStatusSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _availableStatuses.length,
          itemBuilder: (_, index) {
            final status = _availableStatuses[index];

            return ListTile(
              leading: Icon(
                _statusIcon(status.name),
                color: _statusColor(status.color),
              ),
              title: Text(status.name),
              subtitle: Text(status.description ?? ''),
              onTap: () {
                Navigator.pop(context);

                _updateStatus(
                  status.id,
                  status.name,
                );
              },
            );
          },
        ),
      );
    },
  );
}


// define updateStatus method 


Future<void> _updateStatus(int statusId, String statusName) async {
  try {
    final ok = await OrderService.updateStatus(
      widget.order.id,
      statusId,
    );

    if (ok) {
      widget.onStatusChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $statusName')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}




  Widget _statusTile(_SO s, BuildContext sheetCtx) {
    final isCurrent =
        _order.statusName.toLowerCase() == s.label.toLowerCase();
    return InkWell(
      onTap: isCurrent
          ? null
          : () {
              Navigator.pop(sheetCtx);
              if (s.label == 'Rescheduled') {
                _showRescheduleSheet();
              } else {
                  // _applyStatus(s.label);
                  _updateStatus(s.id, s.label);
              }
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? s.color.withOpacity(0.15)
              : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: isCurrent ? s.color : Colors.transparent),
        ),
        child: Row(children: [
          Icon(s.icon, color: s.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(s.label,
                    style: TextStyle(
                        color: s.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(s.desc,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ])),
          if (isCurrent) Icon(Icons.check_circle, color: s.color, size: 18),
        ]),
      ),
    );
  }

  void _showRescheduleSheet() {
    final notesCtrl = TextEditingController();
    bool loading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            const Text('Reschedule Delivery',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Add a note explaining the reschedule reason',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              controller: notesCtrl,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Reason / Notes',
                hintText: 'e.g. Client not home, retry tomorrow at 2pm',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusRescheduled),
                onPressed: loading
                    ? null
                    : () async {
                        if (notesCtrl.text.trim().isEmpty) {
                          _showSnack('Please add a note', success: false);
                          return;
                        }
                        setSheet(() => loading = true);
                      
                        // final rescheduledStatus = availableStatuses.firstWhere(
//   (s) => s.label == 'Rescheduled',
// );

final rescheduledStatus = _availableStatuses.firstWhere(
  (s) => s.name.toLowerCase() == 'rescheduled',
);

final ok = await OrderService.updateStatus(
  _order.id,
  rescheduledStatus.id,
  notes: notesCtrl.text.trim(),
);
                        setSheet(() => loading = false);
                        if (ok) {
                          Navigator.pop(ctx);
                          _showSnack('Order rescheduled', success: true);
                          widget.onStatusChanged();
                        } else {
                          _showSnack('Update failed', success: false);
                        }
                      },
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Reschedule',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }









  

  // ── Release code ──────────────────────────────────────────────────

  void _showReleaseCodeSheet() {
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          const Text('Delivery Release Code',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
              'Ask the client for their release code to confirm delivery',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          TextField(
            controller: codeCtrl,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
                fontSize: 28,
                letterSpacing: 6,
                fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Release Code',
              hintText: '- - - - - -',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                if (codeCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await _updateStatus(5, 'Delivered'); // Assuming 5 is the ID for 'Delivered' status
              },
              child: const Text('Confirm Delivery',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── WhatsApp templates ────────────────────────────────────────────

  void _showMessageTemplates() {
    final templates = [
      'Hi, I am on my way with your order ${_order.orderNo}.',
      'Hi, I have arrived at your delivery location.',
      'Hi, please confirm your delivery address.',
      'Hi, I will be there in approximately 10 minutes.',
      'Hi, I tried to reach you. Please call me back.',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          const Text('Quick Messages',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...templates.map((t) => InkWell(
                onTap: () { Navigator.pop(ctx); _whatsapp(t); },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.chat_outlined,
                        color: Color(0xFF25D366), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(t,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13))),
                  ]),
                ),
              )),
        ]),
      ),
    );
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor:
          success ? AppTheme.statusDelivered : AppTheme.statusFailed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  Widget _sheetHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2)),
        ),
      );

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_order.orderNo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.swap_horiz_outlined),
              tooltip: 'Update Status',
              onPressed: _showStatusSheet),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── 1. Order Summary ───────────────────────────────────
          _sectionCard(children: [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(_order.orderNo,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5)),
                const SizedBox(height: 3),
                Text(_order.createdAt,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ])),
              StatusBadge(
                  statusName: _order.statusName,
                  statusColor: _order.statusColor),
            ]),
            const SizedBox(height: 14),
            Divider(color: Colors.white.withOpacity(0.06)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _infoChip(Icons.payments_outlined,
                  _order.hasMpesaPayment ? 'M-Pesa' : 'Cash',
                  _order.hasMpesaPayment
                      ? AppTheme.statusAwaiting
                      : AppTheme.accent),
              _infoChip(Icons.receipt_outlined,
                  '${_order.currency} ${_order.totalPrice.toStringAsFixed(0)}',
                  AppTheme.textSecondary),
              _infoChip(Icons.store_outlined, _order.vendor.name,
                  AppTheme.textSecondary),
            ]),
          ]),

          const SizedBox(height: 12),

          // ── 2. Client ────────────────────────────────────────
          _sectionLabel('Client'),
          _sectionCard(children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryLight,
                radius: 22,
                child: Text(
                  _order.customerName.isNotEmpty
                      ? _order.customerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(_order.customerName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(_order.customerPhone,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ])),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _commBtn(Icons.call, 'Call',
                      AppTheme.statusDispatched, _call)),
              const SizedBox(width: 8),
              Expanded(
                  child: _commBtn(Icons.sms_outlined, 'SMS',
                      AppTheme.textSecondary, () => _sms())),
              const SizedBox(width: 8),
              Expanded(
                  child: _commBtn(Icons.chat_outlined, 'WhatsApp',
                      const Color(0xFF25D366), _showMessageTemplates)),
            ]),
            const SizedBox(height: 14),
            Divider(color: Colors.white.withOpacity(0.06)),
            const SizedBox(height: 12),
            _addressRow(Icons.trip_origin, AppTheme.accent, 'Pickup',
                _order.pickupAddress),
            const SizedBox(height: 8),
            _addressRow(Icons.location_on_outlined, AppTheme.primary,
                'Deliver To', _order.deliveryAddress),
            if (_order.customer.city != null) ...[
              const SizedBox(height: 4),
              _addressRow(Icons.location_city_outlined,
                  AppTheme.textSecondary, 'City',
                  _order.customer.city!.name),
            ],
            if (_order.customer.zone != null) ...[
              const SizedBox(height: 4),
              _addressRow(Icons.map_outlined, AppTheme.textSecondary,
                  'Zone', _order.customer.zone!.name),
            ],
          ]),

          const SizedBox(height: 12),

          // ── 3. Products ──────────────────────────────────────
          _sectionLabel('Order Items (${_order.orderItems.length})'),
          _sectionCard(children: [
            ..._order.orderItems
                .take(_itemsExpanded ? _order.orderItems.length : 5)
                .map((item) => _itemRow(item)),
            if (_order.orderItems.length > 5) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _itemsExpanded = !_itemsExpanded),
                child: Text(
                  _itemsExpanded
                      ? 'Show less'
                      : 'Show ${_order.orderItems.length - 5} more items',
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.06)),
            const SizedBox(height: 12),
            _totalRow('Subtotal',
                '${_order.currency} ${_order.subTotal.toStringAsFixed(0)}'),
            const SizedBox(height: 6),
            _totalRow('Delivery Fee',
                '${_order.currency} ${_order.shippingCharges.toStringAsFixed(0)}'),
            const SizedBox(height: 10),
            _totalRow(
                'Total',
                '${_order.currency} ${_order.totalPrice.toStringAsFixed(0)}',
                isTotal: true),
            if (_order.customerNotes != null &&
                _order.customerNotes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.06)),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.sticky_note_2_outlined,
                    size: 15, color: AppTheme.accent),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_order.customerNotes!,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic))),
              ]),
            ],
          ]),

          const SizedBox(height: 12),

          // ── 4. M-Pesa Payment ────────────────────────────────
          if (_order.hasMpesaPayment || true) ...[
            _sectionLabel('M-Pesa Payment'),
            _sectionCard(children: [
              _paymentStatusBar(),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.statusAwaiting,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _stkLoading ? null : _sendStkPush,
                      icon: _stkLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_to_mobile, size: 18),
                      label: const Text('STK Push',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.statusAwaiting,
                          side: const BorderSide(
                              color: AppTheme.statusAwaiting, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _showManualMpesaSheet,
                      icon: const Icon(Icons.keyboard_outlined, size: 18),
                      label: const Text('Enter Code',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ]),
              if (_mpesaCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.statusDelivered.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.statusDelivered.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppTheme.statusDelivered, size: 16),
                    const SizedBox(width: 8),
                    Text('Code: $_mpesaCode',
                        style: const TextStyle(
                            color: AppTheme.statusDelivered,
                            fontFamily: 'monospace',
                            fontSize: 13,
                            letterSpacing: 1)),
                  ]),
                ),
              ],
              // Show existing payment details
              if (_order.latestPayment != null) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.06)),
                const SizedBox(height: 8),
                _totalRow('STK Request',
                    _order.latestPayment!.checkoutRequestId ?? 'N/A'),
                const SizedBox(height: 4),
                _totalRow('Result',
                    _order.latestPayment!.resultDesc ?? 'Pending'),
              ],
            ]),
            const SizedBox(height: 12),
          ],

          // ── 5. Status History ────────────────────────────────
          if (_order.statusTimestamps.isNotEmpty) ...[
            _sectionLabel('Status History'),
            _sectionCard(children: [
              ..._order.statusTimestamps.reversed
                  .take(5)
                  .map((s) => _historyRow(s)),
            ]),
            const SizedBox(height: 12),
          ],

          // ── 6. Release Code ──────────────────────────────────
          _sectionLabel('Delivery Confirmation'),
          _sectionCard(children: [
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                const Text('Release Code',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 3),
                const Text(
                    'Ask the client for their code to confirm delivery',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ])),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: _showReleaseCodeSheet,
                child: const Text('Enter Code',
                    style: TextStyle(fontSize: 13)),
              ),
            ]),
          ]),

          const SizedBox(height: 12),

          // ── 7. Update Status button ──────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _showStatusSheet,
              icon: const Icon(Icons.swap_horiz_outlined),
              label: const Text('Update Delivery Status'),
            ),
          ),

          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _paymentStatusBar() {
    Color color;
    IconData icon;
    String label;
    switch (_paymentStatus) {
      case 'awaiting':
        color = AppTheme.statusAwaiting;
        icon = Icons.hourglass_top_outlined;
        label = 'Waiting for client to confirm on their phone...';
        break;
      case 'confirmed':
        color = AppTheme.statusDelivered;
        icon = Icons.check_circle_outline;
        label = 'Payment confirmed';
        break;
      case 'failed':
        color = AppTheme.statusFailed;
        icon = Icons.error_outline;
        label = 'STK Push failed — use Enter Code instead';
        break;
      default:
        color = AppTheme.textSecondary;
        icon = Icons.payments_outlined;
        label = 'No payment initiated yet';
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: TextStyle(color: color, fontSize: 13))),
      ]),
    );
  }

  Widget _historyRow(OrderStatus s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4, right: 10),
            decoration: BoxDecoration(
              color: AppTheme.fromApiColor(s.status?.color ?? 'gray'),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(s.status?.name ?? 'Unknown',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                if (s.statusNotes != null && s.statusNotes!.isNotEmpty)
                  Text(s.statusNotes!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                Text(s.createdAt ?? '',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10)),
              ])),
        ]),
      );

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label.toUpperCase(),
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      );

  Widget _sectionCard({required List<Widget> children}) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );

  Widget _infoChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _commBtn(
          IconData icon, String label, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _addressRow(
          IconData icon, Color color, String label, String address) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text('$label  ',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
        Expanded(
            child: Text(address,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13))),
      ]);

  Widget _itemRow(OrderItem item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.productName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13)),
                Text('SKU: ${item.sku}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ])),
          Text('x${item.quantity}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(width: 12),
          Text('${item.currency} ${item.lineTotal.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _totalRow(String label, String value, {bool isTotal = false}) =>
      Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: isTotal
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: isTotal ? 14 : 13,
                    fontWeight: isTotal
                        ? FontWeight.bold
                        : FontWeight.normal))),
        Text(value,
            style: TextStyle(
                color: isTotal ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: isTotal ? 16 : 13,
                fontWeight:
                    isTotal ? FontWeight.bold : FontWeight.w500)),
      ]);
}




class _SO {
  final int id;
  final String label;
  final IconData icon;
  final Color color;
  final String desc;

  _SO(
    this.id,
    this.label,
    this.icon,
    this.color,
    this.desc,
  );
}