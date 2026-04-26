import 'package:restock/features/auth/domain/models/user.dart';
import 'package:restock/features/profiles/data/models/profile_dto.dart';

class UserDto {
  final int id;
  final String username;
  final int roleId;
  final int subscription;
  final String? token;
  final ProfileDto? profile;

  const UserDto({
    required this.id,
    required this.username,
    required this.roleId,
    required this.subscription,
    this.token,
    this.profile,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      roleId: json['roleId'] ?? 0,
      subscription: json['subscription'] ?? 0,
      token: json['token'],
      profile: json['profile'] != null
          ? ProfileDto.fromJson(json['profile'])
          : null,
    );
  }

  User toDomain() {
    return User(
      id: id,
      username: username,
      roleId: roleId,
      token: token ?? '',
      subscription: subscription,
      profile: profile?.toDomain(),
    );
  }

  toJson() {}
}
