import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'env.dart';

Future<bool> enviarEmailComCodigo(String emailDestino, String codigo) async {
  try {
    final env = loadDotEnv();
    final username = env['EMAIL_USERNAME'];
    final password = env['EMAIL_PASSWORD'];

    if (username == null || password == null) {
      throw Exception('Credenciais de email não configuradas no .env');
    }

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Gerador de Imagem')
      ..recipients.add(emailDestino)
      ..subject = 'Seu código de verificação'
      ..html = '''
        <html>
          <body>
            <h2>Código de Verificação</h2>
            <p>Seu código de verificação é:</p>
            <h1 style="color: #4CAF50; letter-spacing: 5px;">${codigo}</h1>
            <p>Este código é válido por tempo limitado.</p>
            <br>
            <p style="color: #666;">Se você não solicitou este código, ignore este email.</p>
          </body>
        </html>
      ''';

    final sendReport = await send(message, smtpServer);
    print('Email enviado com sucesso: ${sendReport.toString()}');
    return true;
  } catch (e) {
    print('Erro ao enviar email: $e');
    return false;
  }
}