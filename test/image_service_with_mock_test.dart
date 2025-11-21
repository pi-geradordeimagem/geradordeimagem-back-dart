import 'package:test/test.dart';
import 'mocks/mock_image_repository.dart';

void main() {
  group('ImageRepository com Mock - Delete Operations', () {
    late MockImageRepository repository;

    setUp(() {
      repository = MockImageRepository();
      repository.clearMockImages();
    });

    group('deleteImageById', () {
      test('deleta imagem com sucesso quando ID e userId são válidos', () async {
    
        final imageId = '507f1f77bcf86cd799439011';
        final userId = 'user123';
        repository.addMockImage(imageId, 'base64_image_data', 'test prompt', userId);
        
        final result = await repository.deleteImageById(imageId, userId);
        
        expect(result['deletedCount'], equals(1));
        expect(result['message'], equals('Image deleted successfully'));
        expect(repository.lastDeletedImageId, equals(imageId));
        expect(repository.lastDeletedUserId, equals(userId));
      });

      test('lança exceção quando ID tem formato inválido - tamanho incorreto', () async {
        final invalidId = '123';
        final userId = 'user123';
        
        expect(
          () => repository.deleteImageById(invalidId, userId),
          throwsA(predicate((e) => 
            e is Exception && 
            e.toString().contains('Invalid image ID format')
          )),
        );
      });

      test('lança exceção quando ID contém caracteres não hexadecimais', () async {
        final invalidId = 'ZZZZZZZZZZZZZZZZZZZZZZZ1';
        final userId = 'user123';
        
        expect(
          () => repository.deleteImageById(invalidId, userId),
          throwsA(predicate((e) => 
            e is Exception && 
            e.toString().contains('Invalid image ID format')
          )),
        );
      });

      test('lança exceção quando imagem não é encontrada', () async {
        repository.shouldThrowOnDeleteById = true;
        final imageId = '507f1f77bcf86cd799439011';
        final userId = 'user123';
        
        expect(
          () => repository.deleteImageById(imageId, userId),
          throwsA(predicate((e) => 
            e is Exception && 
            e.toString().contains('not found')
          )),
        );
      });

      test('lança exceção quando ID é vazio', () async {
        final emptyId = '';
        final userId = 'user123';
        
        expect(
          () => repository.deleteImageById(emptyId, userId),
          throwsA(predicate((e) => 
            e is Exception && 
            e.toString().contains('Invalid image ID format')
          )),
        );
      });

      test('remove imagem da lista mockada após deletar', () async {
        final imageId = '507f1f77bcf86cd799439011';
        final userId = 'user123';
        repository.addMockImage(imageId, 'base64_image_data', 'test prompt', userId);
        
        expect(repository.mockImages.length, equals(1));
        
        await repository.deleteImageById(imageId, userId);
        
        expect(repository.mockImages.length, equals(0));
      });

      test('não remove imagens de outros usuários', () async {
        final imageId1 = '507f1f77bcf86cd799439011';
        final imageId2 = '507f1f77bcf86cd799439012';
        final userId1 = 'user123';
        final userId2 = 'user456';
        
        repository.addMockImage(imageId1, 'base64_image_data', 'test prompt', userId1);
        repository.addMockImage(imageId2, 'base64_image_data', 'test prompt', userId2);
        
        expect(repository.mockImages.length, equals(2));
        
        await repository.deleteImageById(imageId1, userId1);
        
        expect(repository.mockImages.length, equals(1));
        expect(repository.mockImages[0]['id'], equals(imageId2));
        expect(repository.mockImages[0]['userId'], equals(userId2));
      });

      test('armazena último imageId e userId deletados', () async {
        final imageId = '507f1f77bcf86cd799439011';
        final userId = 'user123';
        repository.addMockImage(imageId, 'base64_image_data', 'test prompt', userId);
        
        await repository.deleteImageById(imageId, userId);
        
        expect(repository.lastDeletedImageId, equals(imageId));
        expect(repository.lastDeletedUserId, equals(userId));
      });
    });

    group('deleteUserImages', () {
      test('deleta todas as imagens do usuário com sucesso', () async {
        final userId = 'user123';
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', userId);
        repository.addMockImage('507f1f77bcf86cd799439012', 'image2', 'prompt2', userId);
        repository.addMockImage('507f1f77bcf86cd799439013', 'image3', 'prompt3', userId);
        
        final result = await repository.deleteUserImages(userId);
        
        expect(result['deletedCount'], equals(3));
        expect(result['message'], equals('User images deleted successfully'));
        expect(repository.lastDeletedUserId, equals(userId));
      });

      test('retorna deletedCount 0 quando usuário não tem imagens', () async {
        final userId = 'user123';
        
        final result = await repository.deleteUserImages(userId);
        
        expect(result['deletedCount'], equals(0));
        expect(result['message'], equals('User images deleted successfully'));
      });

      test('não deleta imagens de outros usuários', () async {
        final userId1 = 'user123';
        final userId2 = 'user456';
        
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', userId1);
        repository.addMockImage('507f1f77bcf86cd799439012', 'image2', 'prompt2', userId1);
        repository.addMockImage('507f1f77bcf86cd799439013', 'image3', 'prompt3', userId2);
        
        expect(repository.mockImages.length, equals(3));
        
        await repository.deleteUserImages(userId1);
        
        expect(repository.mockImages.length, equals(1));
        expect(repository.mockImages[0]['userId'], equals(userId2));
      });

      test('lança exceção quando ocorre erro ao deletar', () async {
        repository.shouldThrowOnDeleteUserImages = true;
        final userId = 'user123';
        
        expect(
          () => repository.deleteUserImages(userId),
          throwsA(predicate((e) => 
            e is Exception && 
            e.toString().contains('Error deleting user images')
          )),
        );
      });

      test('limpa todas as imagens do usuário da lista mockada', () async {
        final userId = 'user123';
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', userId);
        repository.addMockImage('507f1f77bcf86cd799439012', 'image2', 'prompt2', userId);
        
        expect(repository.mockImages.length, equals(2));
        
        await repository.deleteUserImages(userId);
        
        expect(repository.mockImages.length, equals(0));
      });

      test('armazena último userId deletado', () async {
        final userId = 'user123';
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', userId);
        
        await repository.deleteUserImages(userId);
        
        expect(repository.lastDeletedUserId, equals(userId));
      });

      test('deleta apenas imagens do userId especificado em cenário misto', () async {
        final userId1 = 'user123';
        final userId2 = 'user456';
        final userId3 = 'user789';
        
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', userId1);
        repository.addMockImage('507f1f77bcf86cd799439012', 'image2', 'prompt2', userId2);
        repository.addMockImage('507f1f77bcf86cd799439013', 'image3', 'prompt3', userId1);
        repository.addMockImage('507f1f77bcf86cd799439014', 'image4', 'prompt4', userId3);
        repository.addMockImage('507f1f77bcf86cd799439015', 'image5', 'prompt5', userId1);
        
        expect(repository.mockImages.length, equals(5));
        
        final result = await repository.deleteUserImages(userId1);
        
        expect(result['deletedCount'], equals(3));
        expect(repository.mockImages.length, equals(2));
        
        final remainingUserIds = repository.mockImages.map((img) => img['userId']).toList();
        expect(remainingUserIds, isNot(contains(userId1)));
        expect(remainingUserIds, contains(userId2));
        expect(remainingUserIds, contains(userId3));
      });
    });

    group('getUserImages após delete', () {
      test('retorna lista vazia após deletar todas as imagens do usuário', () async {
        final userId = 'user123';
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', userId);
        repository.addMockImage('507f1f77bcf86cd799439012', 'image2', 'prompt2', userId);
        
        await repository.deleteUserImages(userId);
        
        final images = await repository.getUserImages(userId);
        expect(images, isEmpty);
      });

      test('retorna apenas imagens restantes após deletar uma imagem específica', () async {
        final userId = 'user123';
        final imageId1 = '507f1f77bcf86cd799439011';
        final imageId2 = '507f1f77bcf86cd799439012';
        
        repository.addMockImage(imageId1, 'image1', 'prompt1', userId);
        repository.addMockImage(imageId2, 'image2', 'prompt2', userId);
        
        await repository.deleteImageById(imageId1, userId);
        
        final images = await repository.getUserImages(userId);
        expect(images.length, equals(1));
        expect(images[0]['id'], equals(imageId2));
      });
    });

    group('Métodos auxiliares do mock', () {
      test('addMockImage adiciona imagem corretamente', () {
        final imageId = '507f1f77bcf86cd799439011';
        final userId = 'user123';
        
        repository.addMockImage(imageId, 'base64_data', 'test prompt', userId);
        
        expect(repository.mockImages.length, equals(1));
        expect(repository.mockImages[0]['id'], equals(imageId));
        expect(repository.mockImages[0]['userId'], equals(userId));
        expect(repository.mockImages[0]['image_data'], equals('base64_data'));
        expect(repository.mockImages[0]['prompt'], equals('test prompt'));
      });

      test('clearMockImages limpa todas as imagens', () {
        repository.addMockImage('507f1f77bcf86cd799439011', 'image1', 'prompt1', 'user123');
        repository.addMockImage('507f1f77bcf86cd799439012', 'image2', 'prompt2', 'user456');
        
        expect(repository.mockImages.length, equals(2));
        
        repository.clearMockImages();
        
        expect(repository.mockImages.length, equals(0));
      });

      test('shouldThrowOnDeleteById controla exceções em deleteImageById', () {
        repository.shouldThrowOnDeleteById = false;
        expect(repository.shouldThrowOnDeleteById, isFalse);
        
        repository.shouldThrowOnDeleteById = true;
        expect(repository.shouldThrowOnDeleteById, isTrue);
      });

      test('shouldThrowOnDeleteUserImages controla exceções em deleteUserImages', () {
        repository.shouldThrowOnDeleteUserImages = false;
        expect(repository.shouldThrowOnDeleteUserImages, isFalse);
        
        repository.shouldThrowOnDeleteUserImages = true;
        expect(repository.shouldThrowOnDeleteUserImages, isTrue);
      });
    });
  });
}
