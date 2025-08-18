class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompromised;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url = '',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.isCompromised = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isCompromised': isCompromised ? 1 : 0,
    };
  }

  static PasswordEntry fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'],
      title: json['title'],
      username: json['username'],
      password: json['password'],
      url: json['url'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isCompromised: json['isCompromised'] == 1,
    );
  }

  PasswordEntry copyWith({
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    bool? isCompromised,
  }) {
    return PasswordEntry(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isCompromised: isCompromised ?? this.isCompromised,
    );
  }
}

