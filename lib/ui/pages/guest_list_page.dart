import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/guest_provider.dart';

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
                ],
              ),
            );
          },
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, stack) => Center(
          child: Text(
            'Fehler beim Laden',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w200,
              color: Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}
