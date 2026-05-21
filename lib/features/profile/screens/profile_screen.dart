import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _status = 'offline';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name   = await AuthService.getRiderName();
    final email  = await AuthService.getRiderEmail();
    final phone  = await AuthService.getRiderPhone();
    final status = await AuthService.getRiderStatus();
    setState(() {
      _name   = name   ?? '';
      _email  = email  ?? '';
      _phone  = phone  ?? '';
      _status = status ?? 'offline';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Avatar + name
        Center(
          child: Column(children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primary,
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'R',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(_name,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (_status == 'online'
                        ? AppTheme.statusDelivered
                        : AppTheme.textSecondary)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _status.toUpperCase(),
                style: TextStyle(
                    color: _status == 'online'
                        ? AppTheme.statusDelivered
                        : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),

        // Info
        _infoCard([
          _infoRow(Icons.email_outlined, 'Email', _email),
          _divider(),
          _infoRow(Icons.phone_outlined, 'Phone', _phone),
          _divider(),
          _infoRow(Icons.badge_outlined, 'Role', 'Delivery Agent'),
        ]),

        const SizedBox(height: 16),

        // App info
        _infoCard([
          _infoRow(Icons.info_outline, 'App Version', '1.0.0'),
          _divider(),
          _infoRow(Icons.business_outlined, 'Platform', 'Bringit Africa'),
        ]),

        const SizedBox(height: 24),

        // Logout
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.statusFailed,
                side: BorderSide(
                    color: AppTheme.statusFailed.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),

        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Column(children: children),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _divider() =>
      Divider(height: 1, color: Colors.white.withOpacity(0.06));
}
