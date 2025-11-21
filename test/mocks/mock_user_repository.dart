import 'package:geradordeimagem_back_dart/repositories/user_repository.dart';

class MockUserRepository extends UserRepository {
  String? lastHashedPassword;
  Map<String, dynamic>? lastUserData;
  bool shouldThrowOnSignUp = false;
  bool shouldThrowOnLogin = false;
  
  @override
  String hashPassword(String password) {
    lastHashedPassword = 'mocked_hash_$password';
    return lastHashedPassword!;
  }
  
  @override
  bool verifyPassword(String password, String hashedPassword) {
    return hashedPassword == 'mocked_hash_$password';
  }
  
  @override
  Future<Map<String, dynamic>> signUp(userData) async {
    if (shouldThrowOnSignUp) {
      throw Exception('User already exists');
    }
    lastUserData = userData;
    return {
      'email': userData['email'],
      'password_hash': userData['password_hash'],
      'admin': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
  
  @override
  Future<String> login(loginData) async {
    if (shouldThrowOnLogin) {
      throw Exception('Invalid credentials');
    }
    return 'mocked_jwt_token';
  }
  
  @override
  Future<Map<String, dynamic>> removeUser(email) async {
    return {'message': 'User removed successfully'};
  }
  
  @override
  Future<Map<String, dynamic>> getAllUsers() async {
    return {
      "users": [
        {'email': 'user1@test.com', 'admin': false},
        {'email': 'user2@test.com', 'admin': true},
      ]
    };
  }
  
  @override
  Future<Map<String, dynamic>> getUserByEmail(email) async {
    if (email == 'notfound@test.com') {
      throw Exception('User not found');
    }
    return {
      'email': email,
      'admin': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
