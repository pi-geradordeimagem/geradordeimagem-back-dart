import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageRepository {
  final String apiKey;

  ImageRepository({
    required this.apiKey,
  });

  generateImageFromText(String prompt) async {
    final Uri url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final body = {
      "model": "google/gemini-2.5-flash-image-preview",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "Gera uma imagem utilizando o contexto a seguir. Retorne SEMPRE uma imagem. Mesmo que não saiba o que é, ou não entende, tente compreender e SEMPRE envie uma imagem: $prompt",
            }
          ],
        }
      ],
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://openrouter.ai/api/v1/chat/completions",
      },
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      print('Erro na API: ${response.body}');
      throw Exception('Erro ao gerar imagem');
    }

    if (responseData['choices'] == null ||
        responseData['choices'].isEmpty ||
        responseData['choices'][0]['message'] == null ||
        responseData['choices'][0]['message']['images'] == null ||
        responseData['choices'][0]['message']['images'].isEmpty ||
        responseData['choices'][0]['message']['images'][0]['image_url'] == null ||
        responseData['choices'][0]['message']['images'][0]['image_url']['url'] == null) {
      print('Resposta inesperada da API: ${response.body}');
      throw Exception('Resposta inesperada da API');
    }

    return responseData['choices'][0]['message']['images'][0]['image_url']['url'];
  }

  base64ToImage(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    base64String = base64String.replaceFirst(regex, '');
    return base64Decode(base64String);
  }
}