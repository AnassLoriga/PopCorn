class Actor {
  final String name;
  final String profilePath;

  Actor({
    required this.name,
    required this.profilePath,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'] ?? 'Unknown',
      profilePath: json['profile_path'] ?? '',
    );
  }
}