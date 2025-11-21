import 'package:geradordeimagem_back_dart/repositories/user_repository.dart';
import 'package:test/test.dart';

void main() {
  group('UserRepository', () {
    late UserRepository repository;

    setUp(() {
      repository = UserRepository();
    });

    test('hashPassword gera um hash válido', () {
      final password = 'senha123';
      final hashed = repository.hashPassword(password);
      expect(hashed, isNotNull);
      expect(hashed, isNot(equals(password)));
      expect(hashed.length, greaterThan(0));
    });

    test('hashPassword gera hashes diferentes para a mesma senha', () {
      final password = 'senha123';
      final hashed1 = repository.hashPassword(password);
      final hashed2 = repository.hashPassword(password);
      expect(hashed1, isNot(equals(hashed2)));
    });

    test('verifyPassword retorna true para senha correta', () {
      final password = 'senha123';
      final hashed = repository.hashPassword(password);
      final isValid = repository.verifyPassword(password, hashed);
      expect(isValid, isTrue);
    });

    test('verifyPassword retorna false para senha incorreta', () {
      final password = 'senha123';
      final wrongPassword = 'senhaErrada';
      final hashed = repository.hashPassword(password);
      final isValid = repository.verifyPassword(wrongPassword, hashed);
      expect(isValid, isFalse);
    });

    test('verifyPassword funciona com senhas vazias', () {
      final password = '';
      final hashed = repository.hashPassword(password);
      final isValid = repository.verifyPassword(password, hashed);
      expect(isValid, isTrue);
    });

    test('verifyPassword funciona com senhas especiais', () {
      final password = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
      final hashed = repository.hashPassword(password);
      final isValid = repository.verifyPassword(password, hashed);
      expect(isValid, isTrue);
    });
  });
}
