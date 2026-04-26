import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/password_service.dart';
import 'package:restock/features/profiles/presentation/blocs/change_password_event.dart';
import 'package:restock/features/profiles/presentation/blocs/change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final PasswordService service;
  final AuthStorage storage;

  ChangePasswordBloc({
    required this.service,
    required this.storage,
  }) : super(const ChangePasswordState()) {
    on<OnCurrentPasswordChanged>(_onCurrentPasswordChanged);
    on<OnNewPasswordChanged>(_onNewPasswordChanged);
    on<OnConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<ToggleCurrentPasswordVisibility>(_onToggleCurrentPasswordVisibility);
    on<ToggleNewPasswordVisibility>(_onToggleNewPasswordVisibility);
    on<ToggleConfirmPasswordVisibility>(_onToggleConfirmPasswordVisibility);
    on<ChangePassword>(_onChangePassword);
  }

  FutureOr<void> _onCurrentPasswordChanged(
    OnCurrentPasswordChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    final error = _validateCurrentPassword(event.currentPassword);
    emit(state.copyWith(
      currentPassword: event.currentPassword,
      currentPasswordError: error,
      clearCurrentPasswordError: error == null,
    ));
  }

  FutureOr<void> _onNewPasswordChanged(
    OnNewPasswordChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    final error = _validateNewPassword(event.newPassword, state.currentPassword);
    emit(state.copyWith(
      newPassword: event.newPassword,
      newPasswordError: error,
      clearNewPasswordError: error == null,
    ));

    // Re-validate confirm password if it's already filled
    if (state.confirmPassword.isNotEmpty) {
      final confirmError = _validateConfirmPassword(
        state.confirmPassword,
        event.newPassword,
      );
      emit(state.copyWith(
        confirmPasswordError: confirmError,
        clearConfirmPasswordError: confirmError == null,
      ));
    }
  }

  FutureOr<void> _onConfirmPasswordChanged(
    OnConfirmPasswordChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    final error = _validateConfirmPassword(event.confirmPassword, state.newPassword);
    emit(state.copyWith(
      confirmPassword: event.confirmPassword,
      confirmPasswordError: error,
      clearConfirmPasswordError: error == null,
    ));
  }

  FutureOr<void> _onToggleCurrentPasswordVisibility(
    ToggleCurrentPasswordVisibility event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(
      currentPasswordVisible: !state.currentPasswordVisible,
    ));
  }

  FutureOr<void> _onToggleNewPasswordVisibility(
    ToggleNewPasswordVisibility event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(
      newPasswordVisible: !state.newPasswordVisible,
    ));
  }

  FutureOr<void> _onToggleConfirmPasswordVisibility(
    ToggleConfirmPasswordVisibility event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(
      confirmPasswordVisible: !state.confirmPasswordVisible,
    ));
  }

  FutureOr<void> _onChangePassword(
    ChangePassword event,
    Emitter<ChangePasswordState> emit,
  ) async {
    // Prevent duplicate requests if already loading
    if (state.status == Status.loading) {
      return;
    }

    // Validate all fields
    final currentPasswordError = _validateCurrentPassword(state.currentPassword);
    final newPasswordError = _validateNewPassword(
      state.newPassword,
      state.currentPassword,
    );
    final confirmPasswordError = _validateConfirmPassword(
      state.confirmPassword,
      state.newPassword,
    );

    if (currentPasswordError != null ||
        newPasswordError != null ||
        confirmPasswordError != null) {
      emit(state.copyWith(
        currentPasswordError: currentPasswordError,
        newPasswordError: newPasswordError,
        confirmPasswordError: confirmPasswordError,
      ));
      return;
    }

    emit(state.copyWith(status: Status.loading));
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      await service.changePassword(
        token: token,
        userId: userId,
        currentPassword: state.currentPassword,
        newPassword: state.newPassword,
      );

      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  String? _validateCurrentPassword(String value) {
    if (value.trim().isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String value, String currentPassword) {
    if (value.trim().isEmpty) {
      return 'New password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value == currentPassword) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? _validateConfirmPassword(String value, String newPassword) {
    if (value.trim().isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
