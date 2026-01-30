import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/guest.dart';
import '../../services/pocketbase_service.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isSubmitting = false;
  String? _registeredQrCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF334155), // TEKO Grey Bg
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF334155), Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black45,
                color: const Color(0xFF475569)
                    .withValues(alpha: 0.9), // TEKO Grey Surface
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: BorderSide(
                    color: const Color(0xFF3BC0C3)
                        .withValues(alpha: 0.1), // TEKO Cyan tint
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: _registeredQrCode == null
                      ? _buildForm(context)
                      : _buildSuccess(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/login_logo_dark.png',
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.business_rounded,
                  size: 140,
                  color: Colors.white24),
            ),
          ),
          const SizedBox(height: 32),
          _buildHeader('REGISTRIERUNG', 'BITTE DATEN EINGEBEN'),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 400) {
              return Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      label: 'Vorname',
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Pflichtfeld' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Nachname',
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Pflichtfeld' : null,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'Vorname',
                    textInputAction: TextInputAction.next,
                    validator: (v) => v?.isEmpty == true ? 'Pflichtfeld' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Nachname',
                    textInputAction: TextInputAction.next,
                    validator: (v) => v?.isEmpty == true ? 'Pflichtfeld' : null,
                  ),
                ],
              );
            }
          }),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            label: 'E-Mail',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || !v.contains('@') ? 'Ungültige E-Mail' : null,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _companyController,
            label: 'Unternehmen',
            prefixIcon: Icons.business_outlined,
            textInputAction: TextInputAction.done,
            validator: (v) => v?.isEmpty == true ? 'Pflichtfeld' : null,
          ),
          const SizedBox(height: 48),
          _isSubmitting
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3BC0C3)))
              : ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3BC0C3), // TEKO Cyan
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'KOSTENFREI REGISTRIEREN',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
          const SizedBox(height: 24),
          Text(
            'Mit der Registrierung bestätigen Sie Ihre Teilnahme an der Messe.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline,
            color: Colors.greenAccent, size: 80),
        const SizedBox(height: 24),
        Text(
          'REGISTRIERUNG ERFOLGREICH!',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Vielen Dank, ${_firstNameController.text}.\nDein persönlicher QR-Code wurde erstellt.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: QrImageView(
            data: _registeredQrCode!,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Bitte zeige diesen Code am Messeeingang vor.',
          style: GoogleFonts.inter(
            color: const Color(0xFF3BC0C3), // TEKO Cyan
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 64),
        TextButton(
          onPressed: () => setState(() {
            _registeredQrCode = null;
            _firstNameController.clear();
            _lastNameController.clear();
            _emailController.clear();
            _companyController.clear();
          }),
          child: const Text('WEITERE PERSON ANMELDEN'),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 3,
            color: const Color(0xFF3BC0C3), // TEKO Cyan
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final email = _emailController.text.trim().toLowerCase();
        final qrCode =
            'GUEST_${email.hashCode}_${DateTime.now().millisecondsSinceEpoch % 10000}';

        final guest = Guest(
          id: '',
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          company: _companyController.text.trim(),
          attended: false,
          qrCode: qrCode,
        );

        await PocketBaseService().registerGuest(guest);

        setState(() {
          _registeredQrCode = qrCode;
          _isSubmitting = false;
        });
      } catch (e) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          final isDuplicate = errorMessage.contains('bereits registriert');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: isDuplicate ? Colors.orange : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
