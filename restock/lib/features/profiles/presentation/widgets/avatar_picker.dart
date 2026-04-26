import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final String firstName;
  final String lastName;
  final bool isLoading;
  final Function(XFile) onImageSelected;

  const AvatarPicker({
    super.key,
    this.avatarUrl,
    this.firstName = '',
    this.lastName = '',
    this.isLoading = false,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      onImageSelected(pickedFile);
    }
  }

  String _getInitials() {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  Color _getAvatarColor(BuildContext context) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final hash = firstName.hashCode + lastName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return GestureDetector(
      onTap: isLoading ? null : () => _pickImage(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base layer - Avatar or Initials
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasAvatar
                  ? Color.fromRGBO(92, 164, 104, 1)
                  : _getAvatarColor(context),
            ),
            child: hasAvatar
                ? ClipOval(
                    child: Image.network(
                      avatarUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to initials on error
                        return _buildInitialsWidget(context);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  )
                : _buildInitialsWidget(context),
          ),

          // Overlay layer
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(
                alpha: isLoading ? 0.6 : 0.3,
              ),
            ),
          ),

          // Icon or Loading indicator
          if (isLoading)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          else
            const Icon(
              Icons.add_a_photo,
              color: Colors.white,
              size: 32,
            ),
        ],
      ),
    );
  }

  Widget _buildInitialsWidget(BuildContext context) {
    return Center(
      child: Text(
        _getInitials(),
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
