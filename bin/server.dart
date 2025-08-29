import 'dart:io';

import 'package:geradordeimagem_back_dart/controllers/hello_controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final _router = Router()
  ..mount('/', HelloController().router.call);

void main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
