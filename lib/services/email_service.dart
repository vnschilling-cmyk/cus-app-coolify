import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guest.dart';

final emailServiceProvider = Provider((ref) => EmailService());

class EmailService {
  static const String _keyHost = 'smtp_host';
  static const String _keyPort = 'smtp_port';
  static const String _keyUser = 'smtp_user';
  static const String _keyPass = 'smtp_pass';
  static const String _keyFrom = 'smtp_from';

  Future<void> saveSettings({
    required String host,
    required int port,
    required String user,
    required String pass,
    required String from,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, host);
    await prefs.setInt(_keyPort, port);
    await prefs.setString(_keyUser, user);
    await prefs.setString(_keyPass, pass);
    await prefs.setString(_keyFrom, from);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'host': prefs.getString(_keyHost) ?? '',
      'port': prefs.getInt(_keyPort) ?? 587,
      'user': prefs.getString(_keyUser) ?? '',
      'pass': prefs.getString(_keyPass) ?? '',
      'from': prefs.getString(_keyFrom) ?? '',
    };
  }

  Future<void> sendGuestEmail(Guest guest) async {
    final settings = await getSettings();
    final String username = settings['user'];
    final String password = settings['pass'];
    final String host = settings['host'];
    final int port = settings['port'];
    final String fromEmail = settings['from'];

    if (username.isEmpty || password.isEmpty || host.isEmpty) {
      throw Exception('SMTP Einstellungen fehlen.');
    }

    final smtpServer = SmtpServer(host,
        port: port, username: username, password: password, ssl: port == 465);

    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${guest.qrCode}';

    final message = Message()
      ..from =
          Address(fromEmail.isNotEmpty ? fromEmail : username, 'TEKO Messe')
      ..recipients.add(guest.email)
      ..subject = 'Willkommen am TEKO Stand!'
      ..html = '''
        <div style="font-family: Arial, sans-serif; color: #333;">
          <h2 style="color: #00A9AC;">Hallo ${guest.firstName},</h2>
          <p>
            Vielen Dank für deine Registrierung an unserem Messestand!
          </p>
          <p>
            Hier ist dein persönlicher Zugangscode für weitere Stationen:
          </p>
          <div style="margin: 20px 0;">
            <img src="$qrUrl" alt="QR Code" style="border: 2px solid #ccc; padding: 10px; border-radius: 10px;" />
          </div>
          <p>Zeige diesen Code bei Bedarf einfach vor.</p>
          <br>
          <p>Viele Grüße,<br>Das TEKO Team</p>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent. \n' + e.toString());
      throw Exception('E-Mail konnte nicht gesendet werden: $e');
    }
  }
}
