import 'package:restock/core/enums/status.dart';

class ChangePasswordState {
  final Status status;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool currentPasswordVisible;
  final bool newPasswordVisible;
  final bool confirmPasswordVisible;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? confirmPasswordError;
  final String? errorMessage;

  const ChangePasswordState({
    this.status = Status.initial,
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.currentPasswordVisible = false,
    this.newPasswordVisible = false,
    this.confirmPasswordVisible = false,
    this.currentPasswordError,
    this.newPasswordError,
    this.confirmPasswordError,
    this.errorMessage,
  });

  bool get isValid =>
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      currentPasswordError == null &&
      newPasswordError == null &&
      confirmPasswordError == null;

  ChangePasswordState copyWith({
    Status? status,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? currentPasswordVisible,
    bool? newPasswordVisible,
    bool? confirmPasswordVisible,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
    String? errorMessage,
    bool clearCurrentPasswordError = false,
    bool clearNewPasswordError = false,
    bool clearConfirmPasswordError = false,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      currentPasswordVisible: currentPasswordVisible ?? this.currentPasswordVisible,
      newPasswordVisible: newPasswordVisible ?? this.newPasswordVisible,
      confirmPasswordVisible: confirmPasswordVisible ?? this.confirmPasswordVisible,
      currentPasswordError: clearCurrentPasswordError ? null : (currentPasswordError ?? this.currentPasswordError),
      newPasswordError: clearNewPasswordError ? null : (newPasswordError ?? this.newPasswordError),
      confirmPasswordError: clearConfirmPasswordError ? null : (confirmPasswordError ?? this.confirmPasswordError),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
