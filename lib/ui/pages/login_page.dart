import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/test_data_service.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4), // Container for logo
                        child: Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'assets/login_logo_dark.png',
                            height: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.business_rounded,
                                    size: 140, color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'MESSE CONNECT',
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
                      'BITTE ANMELDEN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: Colors.indigoAccent,
                      ),
                    ),
                    const SizedBox(height: 64),
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-Mail',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Ungültige E-Mail'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'PASSWORT',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 2.0,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          style: const TextStyle(fontWeight: FontWeight.w200),
                          validator: (v) => v == null || v.length < 5
                              ? 'Mind. 5 Zeichen'
                              : null,
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
                    ),
                    const SizedBox(height: 48),
                    authState.when(
                      data: (_) => ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('ANMELDEN'),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (err, _) => Column(
                        children: [
                          ElevatedButton(
                            onPressed: _handleLogin,
                            child: const Text('ANMELDEN'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            err.toString().replaceAll('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        await ref
                            .read(testDataServiceProvider)
                            .seedInitialUsers();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Initialsetup abgeschlossen. Loggen Sie sich jetzt ein.'),
                            ),
                          );
                        }
                      },
                      icon:
                          const Icon(Icons.settings_suggest_outlined, size: 16),
                      label: const Text('INITIAL-SETUP (EINMALIG)'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white10,
                        textStyle: GoogleFonts.inter(
                          fontSize: 9,
                          letterSpacing: 1,
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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }
}
