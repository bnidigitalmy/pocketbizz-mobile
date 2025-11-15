import '../../../core/network/result.dart';
import '../domain/user.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _api;

  AuthRepository(this._api);

  Future<Result<User>> login(String email, String password) {
    return _api.login(email, password);
  }

  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _api.register(name: name, email: email, password: password);
  }

  Future<Result<User>> getCurrentUser() {
    return _api.me();
  }

  Future<Result<void>> logout() {
    return _api.logout();
  }
}
