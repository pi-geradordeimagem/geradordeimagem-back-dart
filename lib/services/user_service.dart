import 'package:geradordeimagem_back_dart/repositories/user_repository.dart';
import 'package:geradordeimagem_back_dart/services/image_service.dart';

class UserService {

  final repo = UserRepository();
  final imageService = ImageService();

  signUp(userData) async {
    final hashedPassword = repo.hashPassword(userData['password']);

    userData['password_hash'] = hashedPassword;
    userData.remove('password');

    return await repo.signUp(userData);
  }

  login(loginData) async {
    return await repo.login(loginData);
  }

  removeUser(email) async {
    final user = await repo.getUserByEmail(email);
    
    if (user == null) {
      throw Exception('User not found');
    }

    final userId = user['_id'];
    
    final imagesDeletion = await imageService.deleteUserImages(userId);
    print('Deleted ${imagesDeletion['deletedCount']} images for user $email');

    return await repo.removeUser(email);
  }

  getAllUsers() async {
    return await repo.getAllUsers();
  }

  getUserByEmail(email) async {
    return await repo.getUserByEmail(email);
  }

  updateUser(String email, Map<String, dynamic> updateData, {bool isAdmin = false}) async {
    if (!isAdmin && updateData.containsKey('admin')) {
      updateData.remove('admin');
    }

    return await repo.updateUser(email, updateData);
  }

  sendVerificationCode(email, code) async {
    return await repo.sendVerificationCode(email, code);
  }

  Future<bool> requestPasswordReset(String email) async {
    return await repo.requestPasswordReset(email);
  }

  Future<bool> verifyResetCode(String email, String code) async {
    return await repo.verifyResetCode(email, code);
  }

  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    return await repo.resetPassword(email, code, newPassword);
  }
}