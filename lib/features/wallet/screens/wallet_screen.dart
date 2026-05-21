import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Wallet',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Balance card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('Current Balance',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            const Text('KSH 0.00',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              _balanceChip(Icons.check_circle_outline, 'Confirmed', 'KSH 0'),
              const SizedBox(width: 12),
              _balanceChip(
                  Icons.pending_outlined, 'Pending Cash', 'KSH 0'),
            ]),
          ]),
        ),

        const SizedBox(height: 24),

        _sectionLabel('PENDING CASH SUBMISSIONS'),
        const SizedBox(height: 12),
        _emptyState(Icons.payments_outlined, 'No pending cash submissions'),

        const SizedBox(height: 24),

        _sectionLabel('M-PESA TRANSACTIONS'),
        const SizedBox(height: 12),
        _emptyState(Icons.receipt_long_outlined, 'No M-Pesa transactions yet'),

        const SizedBox(height: 24),

        _sectionLabel('EARNINGS HISTORY'),
        const SizedBox(height: 12),
        _emptyState(
            Icons.account_balance_wallet_outlined, 'No earnings history'),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
            const SizedBox(width: 12),
            const Expanded(
                child: Text(
                    'Wallet settlements and withdrawal features coming soon.',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13))),
          ]),
        ),
      ]),
    );
  }

  Widget _balanceChip(IconData icon, String label, String value) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ]),
        ]),
      );

  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2));

  Widget _emptyState(IconData icon, String message) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Row(children: [
          Icon(icon,
              size: 32,
              color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(width: 16),
          Text(message,
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 14)),
        ]),
      );
}
