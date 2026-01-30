import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';
import '../../services/import_service.dart';
import '../../services/email_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EINSTELLUNGEN',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'DESIGN',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  title: 'System',
                  mode: AppThemeMode.system,
                  currentMode: themeMode,
                ),
                Divider(
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05)),
                _buildThemeOption(
                  context,
                  ref,
                  title: 'Hell',
                  mode: AppThemeMode.light,
                  currentMode: themeMode,
                ),
                Divider(
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05)),
                _buildThemeOption(
                  context,
                  ref,
                  title: 'Dunkel',
                  mode: AppThemeMode.dark,
                  currentMode: themeMode,
                ),
                Divider(
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.05)),
                _buildThemeOption(
                  context,
                  ref,
                  title: 'TEKO Stil',
                  mode: AppThemeMode.teko,
                  currentMode: themeMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05)),
            ),
            child: ListTile(
              onTap: () async {
                final emailService = ref.read(emailServiceProvider);
                final settings = await emailService.getSettings();

                if (context.mounted) {
                  _showSmtpDialog(context, ref, settings);
                }
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_outline_rounded,
                    color: Colors.blueAccent),
              ),
              title: Text(
                'E-Mail Konfiguration',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              subtitle: Text(
                'SMTP Einstellungen für den Mailversand',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'DATENVERWALTUNG',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05)),
            ),
            child: ListTile(
              onTap: () async {
                // Import logic here
                final importService = ref.read(importServiceProvider);
                await importService.importExcel(context);
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.table_view_rounded,
                    color: Colors.greenAccent),
              ),
              title: Text(
                'Excel Import (Alte Messen)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              subtitle: Text(
                'Importieren Sie Leads aus früheren Veranstaltungen',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required AppThemeMode mode,
    required AppThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded,
              color: Theme.of(context).primaryColor)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  void _showSmtpDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> settings) {
    final hostController = TextEditingController(text: settings['host']);
    final portController =
        TextEditingController(text: settings['port'].toString());
    final userController = TextEditingController(text: settings['user']);
    final passController = TextEditingController(text: settings['pass']);
    final fromController = TextEditingController(text: settings['from']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('SMTP Konfiguration',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                    labelText: 'SMTP Server (z.B. smtp.gmail.com)'),
              ),
              TextField(
                controller: portController,
                decoration: const InputDecoration(labelText: 'Port (z.B. 587)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: userController,
                decoration:
                    const InputDecoration(labelText: 'Benutzername/E-Mail'),
              ),
              TextField(
                controller: fromController,
                decoration:
                    const InputDecoration(labelText: 'Absender (Optional)'),
              ),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Passwort'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABBRECHEN'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(emailServiceProvider).saveSettings(
                    host: hostController.text,
                    port: int.tryParse(portController.text) ?? 587,
                    user: userController.text,
                    pass: passController.text,
                    from: fromController.text,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Einstellungen gespeichert')),
                );
              }
            },
            child: const Text('SPEICHERN'),
          ),
        ],
      ),
    );
  }
}
