import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dvspiemtu';
  static const String uploadPreset = 'uitopic';

  // No necesitas apiKey aquí para uploads unsigned desde Flutter
  // static const String apiKey = '795856672881861';

  Future<String> uploadImageBytes(Uint8List imageBytes, String filename) async {
    try {
      print('DEBUG Cloudinary: Starting upload for bytes, filename: $filename');

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      print('DEBUG Cloudinary: Upload URI: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Upload preset (UNSIGNED)
      request.fields['upload_preset'] = uploadPreset;

      // Folder opcional
      request.fields['folder'] = 'restock/avatars';

      print('DEBUG Cloudinary: Upload preset: $uploadPreset');
      print('DEBUG Cloudinary: Adding file to request...');

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
        ),
      );

      print('DEBUG Cloudinary: Sending request to Cloudinary...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('DEBUG Cloudinary: Response status: ${response.statusCode}');
      print('DEBUG Cloudinary: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final secureUrl = data['secure_url'] as String;
        print('DEBUG Cloudinary: Upload successful! URL: $secureUrl');
        return secureUrl;
      }

      throw Exception(
        'Failed to upload image: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('DEBUG Cloudinary: Error: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  String getOptimizedUrl(String? url, {int width = 400, int height = 400}) {
    if (url == null || url.isEmpty) return '';

    // Si es URL de Cloudinary, le metemos la transformación en la URL
    if (url.contains('cloudinary.com')) {
      final parts = url.split('/upload/');
      if (parts.length == 2) {
        return '${parts[0]}/upload/c_fill,g_face,h_$height,w_$width,r_max/${parts[1]}';
      }
    }

    return url;
  }
}
