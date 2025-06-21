class UserProfile {
  final String username;
  final String? profilePic;
  final String? bio;

  UserProfile({
    required this.username,
    this.profilePic,
    this.bio,
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      profilePic: json['profilePic'],
      bio: json['bio'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profilePic': profilePic,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? username,
    String? profilePic,
    String? bio,
  }) {
    return UserProfile(
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() {
    return 'UserProfile(username: $username, profilePic: $profilePic, bio: $bio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return username.hashCode ^ profilePic.hashCode ^ bio.hashCode;
  }
}
