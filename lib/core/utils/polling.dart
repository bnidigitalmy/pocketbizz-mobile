import 'dart:async';

/// Poll a function until a condition is met or timeout
///
/// Example:
/// ```dart
/// final result = await pollUntil<Subscription>(
///   fetch: () => subscriptionApi.getActive(),
///   condition: (sub) => sub.status == 'active',
///   interval: Duration(seconds: 5),
///   timeout: Duration(minutes: 2),
/// );
/// ```
Future<T?> pollUntil<T>({
  required Future<T> Function() fetch,
  required bool Function(T) condition,
  Duration interval = const Duration(seconds: 5),
  Duration timeout = const Duration(minutes: 2),
}) async {
  final endTime = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(endTime)) {
    try {
      final data = await fetch();
      if (condition(data)) {
        return data;
      }
    } catch (e) {
      // Log but continue polling
      print('[Poll] Error: $e');
    }

    await Future.delayed(interval);
  }

  return null; // Timeout reached
}
