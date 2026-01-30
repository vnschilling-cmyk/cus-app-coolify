import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/lead_provider.dart';
import '../../services/excel_service.dart';
import 'lead_form_page.dart';
import 'qr_scanner_page.dart';
import 'guest_list_page.dart';
import 'lead_list_page.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messe Connect',
                          style: GoogleFonts.outfit(
                            fontSize: 42,
                            fontWeight: FontWeight.w100,
                            letterSpacing: -1,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Lead & Event Management',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 4,
                            color: Colors.indigoAccent,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white24,
                      ),
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      tooltip: 'Abmelden',
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 24, bottom: 48),
                    children: [
                      _buildActionCard(
                        context,
                        title: 'NEUER BERICHT',
                        subtitle:
                            'Erfassen Sie neue Kontakte manuell oder via OCR Scan.',
                        icon: Icons.person_add_outlined,
                        color: const Color(0xFF6366F1),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeadFormPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildActionCard(
                        context,
                        title: 'GÄSTE CHECK-IN',
                        subtitle: 'Scannen Sie QR-Codes für den Party-Zutritt.',
                        icon: Icons.qr_code_scanner_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildActionCard(
                        context,
                        title: 'ARCHIV & LISTEN',
                        subtitle:
                            'Übersicht aller Kontakte und Status-Abfrage.',
                        icon: Icons.layers_outlined,
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFF1E293B),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ARCHIV & LISTEN',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 3,
                                      color: Colors.white38,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.people_outline,
                                      color: Colors.indigoAccent,
                                    ),
                                    title: const Text('Messeberichte (Leads)'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LeadListPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.qr_code_2_rounded,
                                      color: Color(0xFF10B981),
                                    ),
                                    title: const Text('Gästeliste (Check-in)'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GuestListPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildActionCard(
                        context,
                        title: 'STATISTIK & ANALYSE',
                        subtitle:
                            'Statistische Auswertungen der Messe-Erfolge.',
                        icon: Icons.bar_chart_rounded,
                        color: Colors.cyanAccent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () async {
                          ref.read(leadListProvider).whenData((list) async {
                            await ExcelService().exportLeads(list);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Excel Export erfolgreich erstellt',
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.download_outlined, size: 20),
                        label: const Text('DATEN EXPORTIEREN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color.withValues(alpha: 0.8), size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w200,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
