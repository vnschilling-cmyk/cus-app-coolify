import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/guest_provider.dart';
import '../../models/guest.dart';

class GuestListPage extends ConsumerWidget {
  const GuestListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestListAsync = ref.watch(guestListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GÄSTELISTE',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Colors.white38,
            ),
            onPressed: () =>
                ref.read(guestListProvider.notifier).refreshGuests(),
          ),
        ],
      ),
      body: guestListAsync.when(
        data: (guests) => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: guests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final guest = guests[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: guest.attended
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: guest.attended
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.03),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      guest.attended
                          ? Icons.check_rounded
                          : Icons.person_outline_rounded,
                      color: guest.attended ? Colors.green : Colors.white24,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${guest.company ?? "Keine Firma"} • ${guest.email ?? ""}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (guest.attended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CHECK-IN',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.green,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      useMaterial3: false, // Force popup menu style
                      popupMenuTheme: PopupMenuThemeData(
                        color: Theme.of(context).cardTheme.color,
                        textStyle: GoogleFonts.inter(color: Colors.white),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.white24),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, ref, guest);
                        } else if (value == 'delete') {
                          _confirmDelete(context, ref, guest);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Bearbeiten'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Löschen',
                                  style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, stack) => Center(
          child: Text(
            'Fehler beim Laden: $err',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w200,
              color: Colors.white38,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Guest guest) {
    final firstNameController = TextEditingController(text: guest.firstName);
    final lastNameController = TextEditingController(text: guest.lastName);
    final companyController = TextEditingController(text: guest.company);
    final emailController = TextEditingController(text: guest.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B), // Match dark theme
        title: Text('Gast bearbeiten',
            style: GoogleFonts.inter(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Vorname',
                      labelStyle: TextStyle(color: Colors.white60),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nachname',
                      labelStyle: TextStyle(color: Colors.white60),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: companyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Firma',
                labelStyle: TextStyle(color: Colors.white60),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'E-Mail',
                labelStyle: TextStyle(color: Colors.white60),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedGuest = guest.copyWith(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                company: companyController.text,
                email: emailController.text,
              );
              ref.read(guestListProvider.notifier).updateGuest(updatedGuest);
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Guest guest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Gast löschen?',
            style: GoogleFonts.inter(color: Colors.white)),
        content: Text(
            'Möchtest du "${guest.name}" wirklich von der Liste entfernen?',
            style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(guestListProvider.notifier).deleteGuest(guest.id);
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
