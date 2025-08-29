import 'package:geradordeimagem_back_dart/services/hello_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class HelloController {
  final service = HelloService();

  Router get router {
    final r = Router();

    r.get('/', (Request req) {
      final msg = service.sayHello();
      return Response.ok(msg);
    });

    r.get('/hello/<name>', (Request req, String name) {
      final msg = service.sayHelloToName(name);
      return Response.ok(msg);
    });

    return r;
  }
}
