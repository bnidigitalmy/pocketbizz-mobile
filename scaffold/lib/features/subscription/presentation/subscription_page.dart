import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/subscription_controller.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  static const prices = {1: 27, 3: 79, 6: 146, 12: 259};
  static const urls = {
    1: 'https://bnidigital.bcl.my/form/1-bulan',
    3: 'https://bnidigital.bcl.my/form/3-bulan',
    6: 'https://bnidigital.bcl.my/form/6-bulan',
    12: 'https://bnidigital.bcl.my/form/12-bulan',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(subscriptionProvider.notifier).load());
  }

  Future<void> _openBcl(int months) async {
    final u = urls[months]!;
    final uri = Uri.parse(u);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Start polling for activation after redirect
      if (mounted) ref.read(subscriptionProvider.notifier).pollActivation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);

    final body = state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) {
        final active = data.subscriptions.where((s) => s.status == 'active').toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (active.isNotEmpty) ...[
              const Text('Active Subscription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${active.first.planName} • ${active.first.durationMonths} bulan'),
              Text('Tamat: ${active.first.subscriptionEndsAt}'),
              const SizedBox(height: 16),
            ],
            const Text('Pilih Tempoh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [1, 3, 6, 12].map((m) {
                return ElevatedButton(
                  onPressed: () => _openBcl(m),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$m Bulan'),
                      Text('RM ${prices[m]}'),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (data.limits != null) ...[
              const Text('Plan Limits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Products: ${data.limits!.productsCurrent} / ${data.limits!.productsMax}'),
              Text('Stock Items: ${data.limits!.stockItemsCurrent} / ${data.limits!.stockItemsMax}'),
              Text('Transactions: ${data.limits!.transactionsCurrent} / ${data.limits!.transactionsMax}'),
            ],
          ],
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: body,
    );
  }
}
