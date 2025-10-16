import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:geradordeimagem_back_dart/utils/env.dart';
import 'package:geradordeimagem_back_dart/utils/mongo_connect.dart';

class UserRepository {
  // ignore: prefer_typing_uninitialized_variables
  late final db;
  final jwtSecret = loadDotEnv()['JWT_SECRET'];

  UserRepository() {
    db = mongoConnect();
  }

  String hashPassword(String password) {
    final String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    return hashed;
  }

  bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }

  signUp(userData) async {
    final mongoDb = await db;

    Map<String, dynamic> userToInsert = {
      'email': userData['email'],
      'password_hash': userData['password_hash'],
      'admin': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final usersCollection = mongoDb.collection('users');

    final userExists = await usersCollection.findOne({'email': userData['email']});

    if (userExists != null) {
      print('User with email ${userData['email']} already exists.');
      throw Exception('User already exists');
    }

    await usersCollection.insertOne(userToInsert);
    return userToInsert;
  }

  login(loginData) async {
    final mongoDb = await db;

    final usersCollection = mongoDb.collection('users');

    final user = await usersCollection.findOne({'email': loginData['email']});

    if (user == null) {
      throw Exception('User not found');
    }

    final isValid = verifyPassword(loginData['password'], user['password_hash']);

    if (!isValid) {
      throw Exception('Invalid password');
    }

    final jwt = JWT(
      {"id": user['_id'],"email": user['email'], "admin": user['admin']},
    );

    final token = jwt.sign(SecretKey(jwtSecret), expiresIn: Duration(hours: 1));

    return token;
  }
  
  removeUser(email) async {
    final mongoDb = await db;

    final usersCollection = mongoDb.collection('users');

    final userExists = await usersCollection.findOne({'email': email});

    if (userExists == null) {
      throw Exception('User not found');
    }

    await usersCollection.deleteOne({'email': email});

    return {'message': 'User removed successfully'};
  }

  getAllUsers() async {
    final mongoDb = await db;

    final usersCollection = mongoDb.collection('users');

    final users = await usersCollection.find().toList();

    return {
      "users": users
    };
  }

  getUserByEmail(email) async {
    final mongoDb = await db;

    final usersCollection = mongoDb.collection('users');

    final userExists = await usersCollection.findOne({'email': email});

    if (userExists == null) {
      throw Exception('User not found');
    }

    return userExists;
  }
}