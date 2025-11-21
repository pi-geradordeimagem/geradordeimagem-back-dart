import 'dart:io';
import 'package:geradordeimagem_back_dart/controllers/hello_controller.dart';
import 'package:geradordeimagem_back_dart/controllers/image_controller.dart';
import 'package:geradordeimagem_back_dart/controllers/user_controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Middleware corsHeaders() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
          'Access-Control-Max-Age': '86400',
        });
      }
      
      final response = await innerHandler(request);
      
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
        ...response.headers,
      });
    };
  };
}

final _router = Router()
  ..mount('/', HelloController().router.call)
  ..mount('/image', ImageController().router.call)
  ..mount('/users', UserController().router.call);

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
