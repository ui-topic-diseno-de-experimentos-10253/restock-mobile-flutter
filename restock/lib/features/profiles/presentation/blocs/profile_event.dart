import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateAvatar extends ProfileEvent {
  final XFile imageFile;
  const UpdateAvatar({required this.imageFile});
}

class DeleteAccount extends ProfileEvent {
  const DeleteAccount();
}

class Logout extends ProfileEvent {
  const Logout();
}
