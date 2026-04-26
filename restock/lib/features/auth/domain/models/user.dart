/* class User {
  final String firstName;
  final String lastName;
  final String email;
  final String token;

  const User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      token: json['token'],
    );
  }
} */


import 'package:restock/features/profiles/domain/models/profile.dart';

class User {
  final int id;
  final String username;
  final int roleId;
  final String token;
  final Profile? profile;
  final int subscription;

  const User({
    required this.id,
    required this.username,
    required this.roleId,
    required this.token,
    this.profile,
    required this.subscription,
  });

  User copyWith({
    int? id,
    String? username,
    int? roleId,
    String? token,
    Profile? profile,
    int? subscription,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      roleId: roleId ?? this.roleId,
      token: token ?? this.token,
      profile: profile ?? this.profile,
      subscription: subscription ?? this.subscription,
    );
  }
}
