import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/core/services/cloudinary_service.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/profile_service.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_event.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService service;
  final AuthStorage storage;
  final CloudinaryService cloudinaryService;

  ProfileBloc({
    required this.service,
    required this.storage,
    required this.cloudinaryService,
  }) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateAvatar>(_onUpdateAvatar);
    on<DeleteAccount>(_onDeleteAccount);
    on<Logout>(_onLogout);
  }

  FutureOr<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();
      final username = await storage.getUsername();

      if (token == null || userId == null) {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      final profile = await service.getProfile(token, userId);
      emit(state.copyWith(
        status: Status.success,
        profile: profile,
        username: username,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

FutureOr<void> _onUpdateAvatar(
  UpdateAvatar event,
  Emitter<ProfileState> emit,
) async {
  print('DEBUG ProfileBloc: Starting avatar update');
  emit(state.copyWith(isUploadingAvatar: true));
  try {
    final token = await storage.getToken();
    final userId = await storage.getUserId();

    print('DEBUG ProfileBloc: Token: ${token?.substring(0, 20)}..., UserId: $userId');

    if (token == null || userId == null) {
      print('DEBUG ProfileBloc: User not authenticated');
      emit(state.copyWith(
        isUploadingAvatar: false,
        errorMessage: 'User not authenticated',
      ));
      return;
    }

    if (state.profile == null) {
      print('DEBUG ProfileBloc: Profile not loaded');
      emit(state.copyWith(
        isUploadingAvatar: false,
        errorMessage: 'Profile not loaded',
      ));
      return;
    }

    // Upload a Cloudinary
    print('DEBUG ProfileBloc: Uploading to Cloudinary...');
    print('DEBUG ProfileBloc: Reading image bytes...');
    final imageBytes = await event.imageFile.readAsBytes();
    final filename = event.imageFile.name;
    print('DEBUG ProfileBloc: Image bytes length: ${imageBytes.length}, filename: $filename');

    final rawCloudinaryUrl = await cloudinaryService.uploadImageBytes(
      imageBytes,
      filename,
    );
    print('DEBUG ProfileBloc: Cloudinary raw URL received: $rawCloudinaryUrl');

    // Aplicar transformación vía URL (recorte circular, etc.)
    final optimizedUrl = cloudinaryService.getOptimizedUrl(rawCloudinaryUrl);
    print('DEBUG ProfileBloc: Optimized Cloudinary URL: $optimizedUrl');

    // Update backend con la URL optimizada
    final currentProfile = state.profile!;
    print('DEBUG ProfileBloc: Updating backend with URL...');
    await service.updateAvatarUrl(
      token,
      userId,
      currentProfile,
      optimizedUrl,
    );
    print('DEBUG ProfileBloc: Backend updated successfully');

    // Actualizar estado local
    final updatedProfile = currentProfile.copyWith(avatar: optimizedUrl);
    print('DEBUG ProfileBloc: Updating local state with new avatar');
    emit(state.copyWith(
      isUploadingAvatar: false,
      profile: updatedProfile,
    ));
    print('DEBUG ProfileBloc: Avatar update complete!');
  } catch (e) {
    print('DEBUG ProfileBloc: Error during avatar update: $e');
    emit(state.copyWith(
      isUploadingAvatar: false,
      errorMessage: e.toString(),
    ));
  }
}

Future<void> _onDeleteAccount(
  DeleteAccount event,
  Emitter<ProfileState> emit,
) async {
  try {
    emit(state.copyWith(status: Status.loading));

    final token = await storage.getToken();
    final userId = await storage.getUserId();

    if (token == null || userId == null) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: 'User not authenticated',
      ));
      return;
    }

    await service.deleteAccount(token, userId);

    await storage.clear();

    emit(state.copyWith(status: Status.success, profile: null));
  } catch (e) {
    emit(state.copyWith(
      status: Status.failure,
      errorMessage: e.toString(),
    ));
  }
}


  FutureOr<void> _onLogout(
    Logout event,
    Emitter<ProfileState> emit,
  ) async {
    await storage.clear();
    emit(const ProfileState());
  }
}
