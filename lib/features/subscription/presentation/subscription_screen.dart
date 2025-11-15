import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  // BCL.my form URLs for PocketBizz subscription
  static const Map<int, String> _bclFormUrls = {
    1: 'https://bnidigital.bcl.my/form/1-bulan',
    3: 'https://bnidigital.bcl.my/form/3-bulan',
    6: 'https://bnidigital.bcl.my/form/6-bulan',
    12: 'https://bnidigital.bcl.my/form/12-bulan',
  };

  static const Map<int, int> _prices = {
    1: 27,
    3: 79,
    6: 146,
    12: 259,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionControllerProvider.notifier).loadSubscriptionData();
    });
  }

  Future<void> _openBclForm(int months) async {
    final url = _bclFormUrls[months];
    if (url == null) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (!mounted) return;
      
      // Show dialog explaining next steps
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pembayaran'),
          content: const Text(
            'Selepas selesai bayar, tekan butang "Dah Bayar" untuk semak status langganan anda.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _checkPaymentStatus() async {
    final notifier = ref.read(subscriptionControllerProvider.notifier);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menyemak status pembayaran...'),
                SizedBox(height: 8),
                Text(
                  'Akan cuba selama 2 minit',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await notifier.pollForActivation();
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Langganan berjaya diaktifkan!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada pembayaran diterima. Cuba lagi sebentar.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Langganan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(subscriptionControllerProvider.notifier)
                  .loadSubscriptionData();
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(subscriptionControllerProvider.notifier)
                      .loadSubscriptionData();
                },
                child: const Text('Cuba Lagi'),
              ),
            ],
          ),
        ),
        data: (subscriptionState) {
          final hasActive = subscriptionState.hasActiveSubscription;
          final active = subscriptionState.activeSubscription;
          final limits = subscriptionState.limits;

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(subscriptionControllerProvider.notifier)
                  .loadSubscriptionData();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current subscription status
                if (hasActive && active != null) ...[
                  _buildActiveSubscriptionCard(active),
                  const SizedBox(height: 16),
                ],

                // Plan limits
                if (limits != null) ...[
                  _buildPlanLimitsCard(limits),
                  const SizedBox(height: 24),
                ],

                // Subscription options
                Text(
                  hasActive ? 'Panjangkan Langganan' : 'Pilih Tempoh Langganan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Duration buttons
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildDurationCard(1),
                    _buildDurationCard(3),
                    _buildDurationCard(6),
                    _buildDurationCard(12),
                  ],
                ),

                const SizedBox(height: 24),

                // "I've paid" button
                FilledButton.icon(
                  onPressed: subscriptionState.isPolling ? null : _checkPaymentStatus,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Dah Bayar? Semak Status'),
                ),

                const SizedBox(height: 16),

                // Important notice
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'PENTING: Gunakan email yang sama semasa isi borang pembayaran untuk aktivasi automatik.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(Subscription subscription) {
    final daysLeft = subscription.subscriptionEndsAt.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 7;

    return Card(
      color: isExpiringSoon ? Colors.orange[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: isExpiringSoon ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Langganan Aktif',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text('${subscription.durationMonths} bulan'),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tamat: ${DateFormat('dd MMM yyyy').format(subscription.subscriptionEndsAt)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '$daysLeft hari lagi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isExpiringSoon ? Colors.orange[700] : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanLimitsCard(PlanLimits limits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Had Penggunaan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildLimitRow(
              'Produk',
              limits.productsCurrent,
              limits.productsMax,
            ),
            _buildLimitRow(
              'Stok',
              limits.stockItemsCurrent,
              limits.stockItemsMax,
            ),
            _buildLimitRow(
              'Transaksi',
              limits.transactionsCurrent,
              limits.transactionsMax,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitRow(String label, int current, int max) {
    final percentage = max > 0 ? (current / max * 100) : 0.0;
    final isUnlimited = max >= 999999;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                isUnlimited ? '$current / ∞' : '$current / $max',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!isUnlimited)
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
            ),
        ],
      ),
    );
  }

  Widget _buildDurationCard(int months) {
    final price = _prices[months]!;
    final perMonth = (price / months).toStringAsFixed(0);

    return Card(
      child: InkWell(
        onTap: () => _openBclForm(months),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$months Bulan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RM $price',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                '~RM$perMonth/bulan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
