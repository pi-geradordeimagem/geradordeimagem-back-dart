import 'dart:convert';

import 'package:geradordeimagem_back_dart/services/image_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ImageController {
  final service = ImageService();

  Router get router {
    final r = Router();

    r.post('/', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      try {
        final msg = await service.generateImage(body['prompt']);

        return Response.ok(msg, headers: {'content-type': 'image/png'});
      } catch (e) {
        return Response(500, body: jsonEncode({'error': e.toString()}));
      }
    });

    return r;
  }
}
