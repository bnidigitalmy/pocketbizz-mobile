import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../env.dart';

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  Dio? _dio;

  Future<Dio> get dio async {
    if (_dio != null) return _dio!;

    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieDir = Directory('${appDocDir.path}/cookies');
    if (!await cookieDir.exists()) {
      await cookieDir.create(recursive: true);
    }
    final jar = PersistCookieJar(storage: FileStorage(cookieDir.path));

    final d = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: { 'Accept': 'application/json' },
      validateStatus: (c) => c != null && c >= 200 && c < 500,
    ));

    d.interceptors.add(CookieManager(jar));
    d.interceptors.add(
      InterceptorsWrapper(onResponse: (resp, handler) {
        if (resp.statusCode == 401) {
          // No-op: auth controller listens and can handle logout/redirect.
        }
        return handler.next(resp);
      }),
    );

    _dio = d;
    return _dio!;
  }
}
