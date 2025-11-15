import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/user.dart';

class AuthApi {
  Future<User> me() async {
    final d = await DioClient.instance.dio;
    final r = await d.get('/api/auth/me');
    if (r.statusCode == 200 && r.data is Map && (r.data as Map).containsKey('user')) {
      return User.fromJson(r.data['user'] as Map<String, dynamic>);
    }
    throw Exception('Not authenticated');
  }

  Future<void> login(String email, String password) async {
    final d = await DioClient.instance.dio;
    final r = await d.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    if (r.statusCode != 200) {
      throw Exception(r.data is Map && (r.data as Map).containsKey('message') ? r.data['message'] : 'Login failed');
    }
  }

  Future<void> register(String name, String email, String password) async {
    final d = await DioClient.instance.dio;
    final r = await d.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    if (r.statusCode != 200) {
      throw Exception(r.data is Map && (r.data as Map).containsKey('message') ? r.data['message'] : 'Register failed');
    }
  }

  Future<void> logout() async {
    final d = await DioClient.instance.dio;
    await d.post('/api/auth/logout');
  }
}
