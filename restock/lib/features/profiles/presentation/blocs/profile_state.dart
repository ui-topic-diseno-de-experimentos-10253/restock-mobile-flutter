import 'package:restock/core/enums/status.dart';
import 'package:restock/features/profiles/domain/models/profile.dart';

class ProfileState {
  final Status status;
  final Profile? profile;
  final String? errorMessage;
  final bool isUploadingAvatar;
  final String? username;

  const ProfileState({
    this.status = Status.initial,
    this.profile,
    this.errorMessage,
    this.isUploadingAvatar = false,
    this.username,
  });

  ProfileState copyWith({
    Status? status,
    Profile? profile,
    String? errorMessage,
    bool? isUploadingAvatar,
    String? username,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      username: username ?? this.username,
    );
  }
}
