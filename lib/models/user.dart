class User {
  final int id;
  final String name;
  final String username;
  final String avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        username: json['username'],
        avatarUrl: 'https://i.pravatar.cc/150?img=${json['id']}',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'avatarUrl': avatarUrl,
      };
}
