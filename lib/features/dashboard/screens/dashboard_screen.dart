import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../orders/screens/orders_screen.dart';
import '../../orders/services/order_service.dart';
import '../../orders/models/order_model.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _riderName = '';
  bool _isOnline = false;
  List<OrderModel> _orders = [];
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadRider();
    _loadOrders();
  }

  Future<void> _loadRider() async {
    final name = await AuthService.getRiderName();
    final status = await AuthService.getRiderStatus();
    setState(() {
      _riderName = name ?? 'Rider';
      _isOnline = status == 'online';
    });
  }

  Future<void> _loadOrders() async {
    setState(() => _loadingOrders = true);
    try {
      final orders = await OrderService.getOrders();
      setState(() { _orders = orders; _loadingOrders = false; });
    } catch (_) {
      setState(() => _loadingOrders = false);
    }
  }

  Future<void> _toggleOnline() async {
    final newStatus = _isOnline ? 'offline' : 'online';
    try {
      await ApiService.patch('/v1/rider/status', {'status': newStatus});
      await AuthService.saveRiderStatus(newStatus);
      setState(() => _isOnline = !_isOnline);
    } catch (_) {
      setState(() => _isOnline = !_isOnline);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sign Out',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await AuthService.logout();
                if (!mounted) return;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.statusFailed))),
        ],
      ),
    );
  }

  int get _totalOrders => _orders.length;
  int get _activeOrders => _orders
      .where((o) =>
          o.statusName.toLowerCase().contains('dispatch') ||
          o.statusName.toLowerCase().contains('transit'))
      .length;
  int get _completedOrders => _orders
      .where((o) => o.statusName.toLowerCase().contains('deliver'))
      .length;
  int get _pendingOrders => _orders
      .where((o) =>
          o.statusName.toLowerCase().contains('pending') ||
          o.statusName.toLowerCase().contains('new') ||
          o.statusName.toLowerCase().contains('schedule'))
      .length;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHome(),
      const OrdersScreen(),
      const WalletScreen(),
      const NotificationsScreen(),
      ProfileScreen(onLogout: _logout),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet'),
          NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alerts'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, $_riderName',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          Text(
            _isOnline ? '● Online' : '○ Offline',
            style: TextStyle(
              fontSize: 12,
              color: _isOnline
                  ? AppTheme.statusDelivered
                  : AppTheme.textSecondary,
            ),
          ),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout_outlined), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _loadOrders,
        child: ListView(padding: const EdgeInsets.all(16), children: [

          // Online/Offline toggle
          GestureDetector(
            onTap: _toggleOnline,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isOnline
                      ? [AppTheme.primary, AppTheme.primaryLight]
                      : [AppTheme.surfaceAlt, AppTheme.surface],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle),
                  child: Icon(
                    _isOnline
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text(
                    _isOnline ? 'You are Online' : 'You are Offline',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    _isOnline
                        ? 'Tap to go offline'
                        : 'Tap to start accepting orders',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12),
                  ),
                ])),
                Icon(
                  _isOnline ? Icons.toggle_on : Icons.toggle_off,
                  color: Colors.white,
                  size: 36,
                ),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // Summary label
          const Text("TODAY'S SUMMARY",
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),

          // Stats grid
          _loadingOrders
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ))
              : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _statCard('Total Orders', _totalOrders.toString(),
                        Icons.inventory_2_outlined,
                        AppTheme.statusDispatched),
                    _statCard('Active', _activeOrders.toString(),
                        Icons.local_shipping_outlined, AppTheme.statusPink),
                    _statCard('Completed', _completedOrders.toString(),
                        Icons.check_circle_outline,
                        AppTheme.statusDelivered),
                    _statCard('Pending', _pendingOrders.toString(),
                        Icons.pending_outlined,
                        AppTheme.statusUndispatched),
                  ],
                ),

          const SizedBox(height: 24),

          // Quick actions
          const Text('QUICK ACTIONS',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(
                child: _quickAction(Icons.inventory_2_outlined, 'Orders',
                    AppTheme.statusDispatched,
                    () => setState(() => _currentIndex = 1))),
            const SizedBox(width: 12),
            Expanded(
                child: _quickAction(
                    Icons.account_balance_wallet_outlined,
                    'Wallet',
                    AppTheme.accent,
                    () => setState(() => _currentIndex = 2))),
            const SizedBox(width: 12),
            Expanded(
                child: _quickAction(Icons.notifications_outlined, 'Alerts',
                    AppTheme.statusRescheduled,
                    () => setState(() => _currentIndex = 3))),
          ]),

          const SizedBox(height: 24),

          // Recent orders
          if (_orders.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              const Text('RECENT ORDERS',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              TextButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: const Text('View All',
                      style: TextStyle(
                          color: AppTheme.primary, fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            ..._orders.take(3).map((o) => _recentOrderTile(o)),
          ],
        ]),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Icon(icon, color: color, size: 22),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _quickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _recentOrderTile(OrderModel order) {
    final color = AppTheme.fromApiColor(order.statusColor);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Text('${order.orderNo} — ${order.customerName}',
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13)),
          Text(order.deliveryAddress,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
        Text(order.statusName,
            style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }
}
