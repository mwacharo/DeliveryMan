import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  bool _loading = true;
  String? _error;

  final _tabs = ['All', 'Active', 'Delivered', 'Pending'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await OrderService.getOrders();
      setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<OrderModel> get _filtered {
    final tab = _tabs[_tabController.index];
    switch (tab) {
      case 'Active':
        return _orders
            .where((o) =>
                o.statusName.toLowerCase().contains('dispatch') ||
                o.statusName.toLowerCase().contains('transit'))
            .toList();
      case 'Delivered':
        return _orders
            .where((o) => o.statusName.toLowerCase().contains('deliver'))
            .toList();
      case 'Pending':
        return _orders
            .where((o) =>
                o.statusName.toLowerCase().contains('pending') ||
                o.statusName.toLowerCase().contains('scheduled') ||
                o.statusName.toLowerCase().contains('new') ||
                o.statusName.toLowerCase().contains('undispatched'))
            .toList();
      default:
        return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My Orders',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('${_orders.length} orders assigned',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_outlined), onPressed: _loadOrders),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: _loading
          ? _buildShimmer()
          : _error != null
              ? _buildError()
              : _buildList(),
    );
  }

  Widget _buildList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No orders here',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 16)),
        ]),
      );
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) =>
            OrderCard(order: list[i], onStatusChanged: _loadOrders),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off_outlined,
              size: 56, color: AppTheme.statusFailed),
          const SizedBox(height: 16),
          const Text('Could not load orders',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            child: ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.surface,
        highlightColor: AppTheme.surfaceAlt,
        child: Container(
          height: 170,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
