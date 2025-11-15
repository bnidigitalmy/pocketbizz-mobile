class Subscription {
  final String id;
  final String planName;
  final String status; // active / expired / cancelled
  final int durationMonths;
  final DateTime subscriptionStartsAt;
  final DateTime subscriptionEndsAt;
  final String totalPaid;

  Subscription({
    required this.id,
    required this.planName,
    required this.status,
    required this.durationMonths,
    required this.subscriptionStartsAt,
    required this.subscriptionEndsAt,
    required this.totalPaid,
  });

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        id: j['id'] as String,
        planName: j['planName'] as String,
        status: j['status'] as String,
        durationMonths: j['durationMonths'] as int,
        subscriptionStartsAt: DateTime.parse(j['subscriptionStartsAt']),
        subscriptionEndsAt: DateTime.parse(j['subscriptionEndsAt']),
        totalPaid: j['totalPaid'].toString(),
      );
}

class PlanLimits {
  final int productsCurrent;
  final int productsMax;
  final int stockItemsCurrent;
  final int stockItemsMax;
  final int transactionsCurrent;
  final int transactionsMax;

  PlanLimits({
    required this.productsCurrent,
    required this.productsMax,
    required this.stockItemsCurrent,
    required this.stockItemsMax,
    required this.transactionsCurrent,
    required this.transactionsMax,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> j) => PlanLimits(
        productsCurrent: (j['products']?['current'] ?? 0) as int,
        productsMax: (j['products']?['max'] ?? 0) as int,
        stockItemsCurrent: (j['stockItems']?['current'] ?? 0) as int,
        stockItemsMax: (j['stockItems']?['max'] ?? 0) as int,
        transactionsCurrent: (j['transactions']?['current'] ?? 0) as int,
        transactionsMax: (j['transactions']?['max'] ?? 0) as int,
      );
}
