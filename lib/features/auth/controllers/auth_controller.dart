import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../domain/user.dart';

// Provider for auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(AuthApi());
});

// Auth state notifier
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    // Check auth status on initialization
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    final result = await _repository.getCurrentUser();
    
    state = result.when(
      success: (user) => AsyncValue.data(user),
      failure: (_) => const AsyncValue.data(null),
    );
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repository.login(email, password);
    
    return result.when(
      success: (user) {
        state = AsyncValue.data(user);
        return true;
      },
      failure: (message) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
    );
    
    return result.when(
      success: (user) {
        state = AsyncValue.data(user);
        return true;
      },
      failure: (message) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
