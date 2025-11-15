class User {
  final String id;
  final String email;
  final String? name;
  final bool isOnTrial;
  final DateTime? trialEndsAt;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.isOnTrial,
    this.trialEndsAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      isOnTrial: (json['isOnTrial'] == 1) || (json['isOnTrial'] == true),
      trialEndsAt: json['trialEndsAt'] != null ? DateTime.tryParse(json['trialEndsAt']) : null,
    );
  }
}
