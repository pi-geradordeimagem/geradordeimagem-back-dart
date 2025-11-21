import 'package:geradordeimagem_back_dart/middlewares/auth_middleware.dart';
import 'package:shelf/shelf.dart';

/// Helper para aplicar authGuard de forma mais limpa
/// 
/// Uso:
/// ```dart
/// r.get('/profile', withAuth((req) async {
///   final email = req.context['userEmail'];
///   // sua lógica
/// }));
/// ```
Future<Response> Function(Request) withAuth(Future<Response> Function(Request) handler) {
  return (Request req) async {
    return await authGuard()(handler)(req);
  };
}

/// Helper para aplicar adminGuard de forma mais limpa
/// 
/// Uso:
/// ```dart
/// r.get('/users', withAdmin((req) async {
///   // sua lógica
/// }));
/// ```
Future<Response> Function(Request) withAdmin(Future<Response> Function(Request) handler) {
  return (Request req) async {
    return await adminGuard()(handler)(req);
  };
}
