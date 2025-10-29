import 'dart:convert';
import 'package:geradordeimagem_back_dart/middlewares/guard_helpers.dart';
import 'package:geradordeimagem_back_dart/services/user_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserController {
  final service = UserService();

  Router get router {
    final r = Router();

    // Rotas públicas (sem autenticação)
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

    // Rotas protegidas - apenas admins
    r.delete('/remove/<email>', (Request req, String email) async {
      return await withAdmin((Request req) async {
        try {
          final adminEmail = req.context['userEmail'];
          print('Admin $adminEmail is removing user $email');

          final msg = await service.removeUser(email);
          return Response.ok(
            jsonEncode(msg),
            headers: {'content-type': 'application/json'},
          );
        } catch (e) {
          return Response(
            500, 
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      })(req);
    });

    r.get('/', (Request req) async {
      return await withAdmin((Request req) async {
        try {
          final adminEmail = req.context['userEmail'];
          print('Admin $adminEmail is requesting all users');
          
          final users = await service.getAllUsers();
          return Response.ok(
            jsonEncode(users),
            headers: {'content-type': 'application/json'},
          );
        } catch (e) {
          return Response(
            500, 
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      })(req);
    });

    r.get('/<email>', (Request req, String email) async {
      return await withAuth((Request req) async {
        try {
          final requestUserEmail = req.context['userEmail'] as String;
          final isAdmin = req.context['isAdmin'] as bool;
          
          if (!isAdmin && requestUserEmail != email) {
            return Response(
              403,
              body: jsonEncode({'error': 'You can only access your own user data'}),
              headers: {'content-type': 'application/json'},
            );
          }
          
          final user = await service.getUserByEmail(email);
          if (user == null) {
            return Response(
              404, 
              body: jsonEncode({'error': 'User not found'}),
              headers: {'content-type': 'application/json'},
            );
          }
          return Response.ok(
            jsonEncode(user),
            headers: {'content-type': 'application/json'},
          );
        } catch (e) {
          return Response(
            500, 
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      })(req);
    });

    return r;
  }
}
