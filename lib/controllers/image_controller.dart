import 'dart:convert';

import 'package:geradordeimagem_back_dart/middlewares/guard_helpers.dart';
import 'package:geradordeimagem_back_dart/services/image_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ImageController {
  final service = ImageService();

  Router get router {
    final r = Router();

    r.post('/', (Request req) async {
      return await withAuth((Request req) async {
        try {
          final userEmail = req.context['userEmail'];
          print('Usuário $userEmail is requesting image generation');
          
          final body = jsonDecode(await req.readAsString());
          final userId = req.context['userId'];

          final msg = await service.generateImage(body['prompt'], userId);

          return Response.ok(msg, headers: {'content-type': 'image/png'});
        } catch (e) {
          return Response(
            500, 
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      })(req);
    });

    r.get('/user', (Request req) async {
      return await withAuth((Request req) async {
        try {
          final userId = req.context['userId'];
          final userEmail = req.context['userEmail'];
          print('Usuário $userEmail is requesting their images');

          final images = await service.getUserImages(userId);

          return Response.ok(
            jsonEncode({'images': images}),
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

    r.delete('/<imageId>', (Request req, String imageId) async {
      return await withAuth((Request req) async {
        try {
          final userId = req.context['userId'];
          final userEmail = req.context['userEmail'];
          print('Usuário $userEmail is deleting image $imageId');

          final result = await service.deleteImageById(imageId, userId);

          return Response.ok(
            jsonEncode(result),
            headers: {'content-type': 'application/json'},
          );
        } catch (e) {
          return Response(
            404,
            body: jsonEncode({'error': e.toString()}),
            headers: {'content-type': 'application/json'},
          );
        }
      })(req);
    });

    return r;
  }
}
