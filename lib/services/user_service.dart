import 'package:geradordeimagem_back_dart/repositories/user_repository.dart';

class UserService {

  final repo = UserRepository();

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
    return await repo.removeUser(email);
  }

  getAllUsers() async {
    return await repo.getAllUsers();
  }

  getUserByEmail(email) async {
    return await repo.getUserByEmail(email);
  }
}