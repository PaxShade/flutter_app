class User {
  final String id;
  final String username;
  final String password;
  final String role;
  String avatarUrl;

  User({
    required this.id,
    required this.username,
    required this.password,
    this.role = 'Пользователь',
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
    'avatarUrl': avatarUrl,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    username: json['username'] ?? '',
    password: json['password'] ?? '',
    role: json['role'] ?? 'Пользователь',
    avatarUrl: json['avatarUrl'] ?? '',
  );
}
