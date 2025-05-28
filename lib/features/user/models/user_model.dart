class User {
  final String id;
  final String? googleId;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    this.googleId,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      googleId: json['google_id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : 
                 json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : 
                 json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_id': googleId,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}