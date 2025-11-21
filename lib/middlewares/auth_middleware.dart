import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:geradordeimagem_back_dart/utils/env.dart';
import 'package:shelf/shelf.dart';

/// Middleware para autenticação de usuários (admin ou normal)
Middleware authGuard() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          jsonEncode({'error': 'Token not provided'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final jwtSecret = loadDotEnv()['JWT_SECRET'];

      try {
        final jwt = JWT.verify(token, SecretKey(jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;
        
        final requestWithUser = request.change(context: {
          'user': payload,
          'userId': payload['id'],
          'userEmail': payload['email'],
          'isAdmin': payload['admin'] ?? false,
        });

        return await innerHandler(requestWithUser);
      } on JWTExpiredException {
        return Response.forbidden(
          jsonEncode({'error': 'Token expired'}),
          headers: {'content-type': 'application/json'},
        );
      } on JWTException catch (e) {
        return Response.forbidden(
          jsonEncode({'error': 'Invalid token: ${e.message}'}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Error verifying token'}),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}

/// Middleware para autenticação de apenas administradores
Middleware adminGuard() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          jsonEncode({'error': 'Token not provided'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final jwtSecret = loadDotEnv()['JWT_SECRET'];

      try {
        final jwt = JWT.verify(token, SecretKey(jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;
        final isAdmin = payload['admin'] ?? false;

        if (!isAdmin) {
          return Response.forbidden(
            jsonEncode({'error': 'Access denied. Only administrators can access this resource'}),
            headers: {'content-type': 'application/json'},
          );
        }

        final requestWithUser = request.change(context: {
          'user': payload,
          'userId': payload['id'],
          'userEmail': payload['email'],
          'isAdmin': true,
        });

        return await innerHandler(requestWithUser);
      } on JWTExpiredException {
        return Response.forbidden(
          jsonEncode({'error': 'Token expired'}),
          headers: {'content-type': 'application/json'},
        );
      } on JWTException catch (e) {
        return Response.forbidden(
          jsonEncode({'error': 'Invalid token: ${e.message}'}),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Error verifying token'}),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
