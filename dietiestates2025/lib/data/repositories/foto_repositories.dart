import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/cloudinary_service.dart';
import '../../services/http_service.dart';

class FotoRepositories {
  final HttpService httpService;
  final ImageUploadService imageService;

  FotoRepositories(this.httpService, this.imageService);

  Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      return await imageService.uploadImage(imageFile);
    } catch (e){
      rethrow;
    }
  }
}
