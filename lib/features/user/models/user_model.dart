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
      id: json['id'] ?? '',
      googleId: json['googleId'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'googleId': googleId,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}