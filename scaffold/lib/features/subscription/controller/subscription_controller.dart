import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/poll_until.dart';
import '../data/subscription_api.dart';
import '../domain/subscription.dart';

final subscriptionProvider = StateNotifierProvider<SubscriptionController, AsyncValue<SubscriptionState>>((ref) {
  return SubscriptionController(SubscriptionApi());
});

class SubscriptionState {
  final List<Subscription> subscriptions;
  final PlanLimits? limits;
  const SubscriptionState({this.subscriptions = const [], this.limits});
}

class SubscriptionController extends StateNotifier<AsyncValue<SubscriptionState>> {
  SubscriptionController(this._api) : super(const AsyncValue.loading());
  final SubscriptionApi _api;

  Future<void> load() async {
    try {
      final subs = await _api.getSubscriptions();
      final limits = await _api.getPlanLimits();
      state = AsyncValue.data(SubscriptionState(subscriptions: subs, limits: limits));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pollActivation() async {
    final result = await pollUntil<List<Subscription>>(
      () => _api.getSubscriptions(),
      condition: (subs) => subs.any((s) => s.status == 'active'),
    );
    if (result != null) {
      await load();
    }
  }
}
