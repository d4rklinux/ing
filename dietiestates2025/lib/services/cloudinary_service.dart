import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ImageUploadService {
  static const String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dcatpnwiz/image/upload';
  static const String uploadPreset = 'dietiestates25';

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse(cloudinaryUrl);
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = json.decode(responseString);
      return jsonMap['secure_url'];
    }
    return throw Exception('Failed to upload image');
  }
}
