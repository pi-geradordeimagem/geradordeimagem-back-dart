import 'package:test/test.dart';
import 'mocks/mock_user_repository.dart';

void main() {
  group('UserRepository com Mock', () {
    late MockUserRepository repository;

    setUp(() {
      repository = MockUserRepository();
    });

    test('hashPassword retorna hash mockado', () {
      final result = repository.hashPassword('senha123');
      expect(result, equals('mocked_hash_senha123'));
      expect(repository.lastHashedPassword, equals('mocked_hash_senha123'));
    });

    test('verifyPassword valida senha corretamente', () {
      final hashed = repository.hashPassword('senha123');
      expect(repository.verifyPassword('senha123', hashed), isTrue);
      expect(repository.verifyPassword('senhaErrada', hashed), isFalse);
    });

    test('signUp salva dados do usuário', () async {
      final userData = {
        'email': 'test@test.com',
        'password_hash': 'hashed_password',
      };
      
      final result = await repository.signUp(userData);
      
      expect(result['email'], equals('test@test.com'));
      expect(result['password_hash'], equals('hashed_password'));
      expect(result['admin'], isFalse);
      expect(repository.lastUserData, equals(userData));
    });

    test('signUp lança exceção quando usuário já existe', () async {
      repository.shouldThrowOnSignUp = true;
      
      expect(
        () => repository.signUp({'email': 'test@test.com'}),
        throwsA(isA<Exception>()),
      );
    });

    test('login retorna token JWT mockado', () async {
      final result = await repository.login({
        'email': 'test@test.com',
        'password': 'senha123',
      });
      
      expect(result, equals('mocked_jwt_token'));
    });

    test('login lança exceção com credenciais inválidas', () async {
      repository.shouldThrowOnLogin = true;
      
      expect(
        () => repository.login({'email': 'test@test.com', 'password': 'wrong'}),
        throwsA(isA<Exception>()),
      );
    });

    test('removeUser retorna mensagem de sucesso', () async {
      final result = await repository.removeUser('test@test.com');
      expect(result['message'], equals('User removed successfully'));
    });

    test('getAllUsers retorna lista de usuários', () async {
      final result = await repository.getAllUsers();
      expect(result['users'], isA<List>());
      expect(result['users'].length, equals(2));
    });

    test('getUserByEmail retorna usuário encontrado', () async {
      final result = await repository.getUserByEmail('test@test.com');
      expect(result['email'], equals('test@test.com'));
      expect(result['admin'], isFalse);
    });

    test('getUserByEmail lança exceção quando usuário não existe', () async {
      expect(
        () => repository.getUserByEmail('notfound@test.com'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
