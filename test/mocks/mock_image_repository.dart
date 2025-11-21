import 'package:geradordeimagem_back_dart/repositories/image_repository.dart';

class MockImageRepository extends ImageRepository {
  bool shouldThrowOnDeleteById = false;
  bool shouldThrowOnDeleteUserImages = false;
  String? lastDeletedImageId;
  Object? lastDeletedUserId;
  List<Map<String, dynamic>> mockImages = [];
  
  MockImageRepository() : super(apiKey: 'mock_api_key');

  @override
  Future<Map<String, dynamic>> deleteImageById(String imageId, Object? userId) async {
    lastDeletedImageId = imageId;
    lastDeletedUserId = userId;

    if (shouldThrowOnDeleteById) {
      throw Exception('Image not found or you do not have permission to delete it');
    }

    if (imageId.length != 24 || !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(imageId)) {
      throw Exception('Invalid image ID format. Expected 24 hexadecimal characters, got ${imageId.length} characters: $imageId');
    }

    mockImages.removeWhere((img) => img['id'] == imageId && img['userId'] == userId);

    return {
      'deletedCount': 1,
      'message': 'Image deleted successfully'
    };
  }

  @override
  Future<Map<String, dynamic>> deleteUserImages(Object? userId) async {
    lastDeletedUserId = userId;

    if (shouldThrowOnDeleteUserImages) {
      throw Exception('Error deleting user images');
    }

    final deletedCount = mockImages.where((img) => img['userId'] == userId).length;
    mockImages.removeWhere((img) => img['userId'] == userId);

    return {
      'deletedCount': deletedCount,
      'message': 'User images deleted successfully'
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getUserImages(Object? userId) async {
    return mockImages.where((img) => img['userId'] == userId).toList();
  }

  void addMockImage(String id, String imageData, String prompt, Object? userId) {
    mockImages.add({
      'id': id,
      'image_data': imageData,
      'prompt': prompt,
      'createdAt': DateTime.now().toIso8601String(),
      'userId': userId,
    });
  }

  void clearMockImages() {
    mockImages.clear();
  }
}
