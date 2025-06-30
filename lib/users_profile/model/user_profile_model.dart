class UserProfile {
  final String id;
  final String username;
  final String? profilePic;
  final String? bio;

  UserProfile({
    required this.id,
    required this.username,
    this.profilePic,
    this.bio,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      profilePic: json['profilePic'],
      bio: json['bio'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profilePic': profilePic,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? profilePic,
    String? bio,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, username: $username, profilePic: $profilePic, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ profilePic.hashCode ^ bio.hashCode;
  }
}
