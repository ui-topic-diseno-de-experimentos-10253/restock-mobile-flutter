abstract class ChangePasswordEvent {
  const ChangePasswordEvent();
}

class OnCurrentPasswordChanged extends ChangePasswordEvent {
  final String currentPassword;
  const OnCurrentPasswordChanged({required this.currentPassword});
}

class OnNewPasswordChanged extends ChangePasswordEvent {
  final String newPassword;
  const OnNewPasswordChanged({required this.newPassword});
}

class OnConfirmPasswordChanged extends ChangePasswordEvent {
  final String confirmPassword;
  const OnConfirmPasswordChanged({required this.confirmPassword});
}

class ToggleCurrentPasswordVisibility extends ChangePasswordEvent {
  const ToggleCurrentPasswordVisibility();
}

class ToggleNewPasswordVisibility extends ChangePasswordEvent {
  const ToggleNewPasswordVisibility();
}

class ToggleConfirmPasswordVisibility extends ChangePasswordEvent {
  const ToggleConfirmPasswordVisibility();
}

class ChangePassword extends ChangePasswordEvent {
  const ChangePassword();
}
