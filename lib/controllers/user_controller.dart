import 'dart:convert';
import 'package:geradordeimagem_back_dart/services/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserController {
  final service = UserService();

  Router get router {
    final r = Router();

    r.post('/signup', (Request req) async {
      final userDataString = await req.readAsString();
      final Map<String, dynamic> userData = jsonDecode(userDataString);

      try {
        final msg = await service.signUp(userData);
      
        msg.remove('_id');

        return Response.ok(jsonEncode(msg));
      } catch (e) {
        return Response(500, body: jsonEncode({'error': e.toString()}));
      }

    });

    r.post('/login', (Request req) async {
      final loginDataString = await req.readAsString();
      final Map<String, dynamic> loginData = jsonDecode(loginDataString);

      try {
        final token = await service.login(loginData);
        return Response.ok(jsonEncode({'token': token}));
      } catch (e) {
        return Response(401, body: jsonEncode({'error': e.toString()}));
      }
    });

    r.delete('/remove/<email>', (Request req, String email) async {
      try {
        final msg = await service.removeUser(email);
        return Response.ok(jsonEncode(msg));
      } catch (e) {
        return Response(500, body: jsonEncode({'error': e.toString()}));
      }
    });

    r.get('/', (Request req) async {
      try {
        final users = await service.getAllUsers();
        return Response.ok(jsonEncode(users));
      } catch (e) {
        return Response(500, body: jsonEncode({'error': e.toString()}));
      }
    });

    r.get('/<email>', (Request req, String email) async {
      try {
        final user = await service.getUserByEmail(email);
        if (user == null) {
          return Response(404, body: jsonEncode({'error': 'User not found'}));
        }
        return Response.ok(jsonEncode(user));
      } catch (e) {
        return Response(500, body: jsonEncode({'error': e.toString()}));
      }
    });

    return r;
  }
}
