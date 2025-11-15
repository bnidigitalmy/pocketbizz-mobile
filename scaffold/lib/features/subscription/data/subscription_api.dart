import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/subscription.dart';

class SubscriptionApi {
  Future<List<Subscription>> getSubscriptions() async {
    final Dio d = await DioClient.instance.dio;
    final r = await d.get('/api/user/subscriptions');
    if (r.statusCode == 200 && r.data is List) {
      return (r.data as List).map((e) => Subscription.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('Failed to load subscriptions');
  }

  Future<PlanLimits> getPlanLimits() async {
    final Dio d = await DioClient.instance.dio;
    final r = await d.get('/api/user/plan-limits');
    if (r.statusCode == 200 && r.data is Map) {
      return PlanLimits.fromJson(Map<String, dynamic>.from(r.data));
    }
    throw Exception('Failed to load plan limits');
  }
}
