import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/polling.dart';
import '../data/subscription_api.dart';
import '../domain/subscription.dart';

// Provider for subscription API
final subscriptionApiProvider = Provider<SubscriptionApi>((ref) {
  return SubscriptionApi();
});

// Subscription state
class SubscriptionState {
  final List<Subscription> subscriptions;
  final PlanLimits? limits;
  final bool isPolling;

  SubscriptionState({
    this.subscriptions = const [],
    this.limits,
    this.isPolling = false,
  });

  Subscription? get activeSubscription => subscriptions.firstWhere(
    (s) => s.status == 'active',
    orElse: () => subscriptions.isEmpty
        ? const Subscription(
            id: '',
            userId: '',
            planId: '',
            planName: '',
            status: 'none',
            durationMonths: 0,
            subscriptionStartsAt: null,
            subscriptionEndsAt: null,
            totalPaid: '0',
          )
        : subscriptions.first,
  );

  bool get hasActiveSubscription =>
      subscriptions.any((s) => s.status == 'active');

  SubscriptionState copyWith({
    List<Subscription>? subscriptions,
    PlanLimits? limits,
    bool? isPolling,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      limits: limits ?? this.limits,
      isPolling: isPolling ?? this.isPolling,
    );
  }
}

// Subscription controller
final subscriptionControllerProvider =
    StateNotifierProvider<
      SubscriptionController,
      AsyncValue<SubscriptionState>
    >((ref) {
      return SubscriptionController(ref.watch(subscriptionApiProvider));
    });

class SubscriptionController
    extends StateNotifier<AsyncValue<SubscriptionState>> {
  final SubscriptionApi _api;

  SubscriptionController(this._api)
    : super(const AsyncValue.data(SubscriptionState()));

  Future<void> loadSubscriptionData() async {
    state = const AsyncValue.loading();

    final subsResult = await _api.getSubscriptions();
    final limitsResult = await _api.getPlanLimits();

    state = subsResult.when(
      success: (subscriptions) {
        return limitsResult.when(
          success: (limits) {
            return AsyncValue.data(
              SubscriptionState(subscriptions: subscriptions, limits: limits),
            );
          },
          failure: (message) {
            return AsyncValue.data(
              SubscriptionState(subscriptions: subscriptions),
            );
          },
        );
      },
      failure: (message) {
        return AsyncValue.error(message, StackTrace.current);
      },
    );
  }

  /// Poll for subscription activation after payment
  Future<bool> pollForActivation() async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(currentState.copyWith(isPolling: true));

    final result = await pollUntil<List<Subscription>>(
      fetch: () async {
        final result = await _api.getSubscriptions();
        return result.when(
          success: (subs) => subs,
          failure: (_) => <Subscription>[],
        );
      },
      condition: (subs) => subs.any((s) => s.status == 'active'),
      interval: const Duration(seconds: 5),
      timeout: const Duration(minutes: 2),
    );

    if (result != null && result.any((s) => s.status == 'active')) {
      // Subscription activated, reload data
      await loadSubscriptionData();
      return true;
    } else {
      // Polling timeout, still reload to show current state
      state = AsyncValue.data(currentState.copyWith(isPolling: false));
      await loadSubscriptionData();
      return false;
    }
  }
}
