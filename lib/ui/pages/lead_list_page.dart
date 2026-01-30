import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/lead_provider.dart';
import '../../models/lead.dart';

class LeadListPage extends ConsumerStatefulWidget {
  const LeadListPage({super.key});

  @override
  ConsumerState<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends ConsumerState<LeadListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final leadListAsync = ref.watch(leadListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MESSEBERICHTE',
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
            onPressed: () => ref.read(leadListProvider.notifier).refreshLeads(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: TextFormField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: TextStyle(
                fontWeight: FontWeight.w400, // Slightly bolder
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Nach Firma oder Name suchen...',
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Expanded(
            child: leadListAsync.when(
              data: (leads) {
                final filteredLeads = leads.where((l) {
                  return l.company.toLowerCase().contains(_searchQuery) ||
                      l.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredLeads.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Berichte gefunden',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w200,
                        color: Colors.white38,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 0,
                  ),
                  itemCount: filteredLeads.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lead = filteredLeads[index];
                    return _buildLeadCard(lead);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
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
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: theme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.company.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600, // Increased weight
                        letterSpacing: 1,
                        color: theme.colorScheme.onSurface, // Theme aware
                      ),
                    ),
                    Text(
                      lead.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400, // Increased weight
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7), // Theme aware
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lead.clientType,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          if (lead.projectChance != null && lead.projectChance!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: Colors.amber, // Darker amber for better visibility
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lead.projectChance!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
