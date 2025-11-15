import 'dart:async';

Future<T?> pollUntil<T>(
  Future<T> Function() fetch, {
  required bool Function(T) condition,
  Duration interval = const Duration(seconds: 5),
  Duration timeout = const Duration(minutes: 2),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    try {
      final data = await fetch();
      if (condition(data)) return data;
    } catch (_) {
      // ignore transient errors
    }
    await Future.delayed(interval);
  }
  return null;
}
