import 'package:restock/features/auth/data/models/user_dto.dart';
import 'package:restock/features/auth/domain/models/user.dart';

class AuthResponseDto {
  final UserDto user;

  AuthResponseDto({required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      user: UserDto.fromJson(json),
    );
  }

  User toDomain() => user.toDomain();
}
