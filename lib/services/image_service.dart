import 'package:geradordeimagem_back_dart/repositories/image_repository.dart';
import 'package:geradordeimagem_back_dart/utils/env.dart';

class ImageService {

  final repo = ImageRepository(apiKey: loadDotEnv()['API_KEY'] ?? '');

  generateImage(prompt, userId) async {
    final base64Img = await repo.generateImageFromText(prompt, userId);
    final img = repo.base64ToImage(base64Img);
    return img;
  }

  getUserImages(userId) async {
    return await repo.getUserImages(userId);
  }

  deleteUserImages(userId) async {
    return await repo.deleteUserImages(userId);
  }
}
