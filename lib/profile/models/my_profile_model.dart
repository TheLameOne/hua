class MyProfile {
  final String username;
  final String? profilePic;
  final String? bio;

  MyProfile({
    required this.username,
    this.profilePic,
    this.bio,
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) {
    return MyProfile(
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

  MyProfile copyWith({
    String? username,
    String? profilePic,
    String? bio,
  }) {
    return MyProfile(
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
    );
  }
}
