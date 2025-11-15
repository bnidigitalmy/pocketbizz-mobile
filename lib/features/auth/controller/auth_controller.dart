import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api.dart';
import '../domain/user.dart';

final authProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(AuthApi());
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this._api) : super(const AsyncValue.loading());
  final AuthApi _api;

  Future<void> hydrate() async {
    try {
      final u = await _api.me();
      state = AsyncValue.data(u);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _api.login(email, password);
      final u = await _api.me();
      state = AsyncValue.data(u);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _api.register(name, email, password);
      final u = await _api.me();
      state = AsyncValue.data(u);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = const AsyncValue.data(null);
  }
}
