import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.orangeAccent.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          size: 48,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'SICHERHEIT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w100,
                        letterSpacing: 4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BITTE PASSWORT ÄNDERN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sie melden sich zum ersten Mal an. Bitte bestätigen Sie Ihr aktuelles Passwort und vergeben Sie ein neues.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 64),
                    _buildPasswordField(
                      controller: _oldPasswordController,
                      label: 'AKTUELLES PASSWORT (INITIALPASSWORT)',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Erforderlich' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'NEUES PASSWORT',
                      validator: (v) => v == null || v.length < 8
                          ? 'Mindestens 8 Zeichen erforderlich'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'NEUES PASSWORT BESTÄTIGEN',
                      validator: (v) => v != _passwordController.text
                          ? 'Passwörter stimmen nicht überein'
                          : null,
                    ),
                    const SizedBox(height: 48),
                    authState.when(
                      data: (_) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: _handleSubmit,
                        child: const Text('PASSWORT SPEICHERN'),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.orangeAccent),
                      ),
                      error: (err, _) => Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                            ),
                            onPressed: _handleSubmit,
                            child: const Text('PASSWORT SPEICHERN'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            err.toString().contains('oldPassword')
                                ? 'Aktuelles Passwort ist nicht korrekt.'
                                : err.toString().replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      child: Text(
                        'Abbrechen & Abmelden',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w200,
              letterSpacing: 2.0,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(fontWeight: FontWeight.w200),
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              onPressed: () => setState(
                () => _isPasswordVisible = !_isPasswordVisible,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).updatePassword(
            _oldPasswordController.text, _passwordController.text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().contains('oldPassword')
                  ? 'Aktuelles Passwort ist nicht korrekt (Initialpasswort prüfen).'
                  : 'Fehler: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }
}
