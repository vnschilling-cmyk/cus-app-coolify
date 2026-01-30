import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/lead_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/lead.dart';
import '../../models/event.dart';
import 'lead_form_page.dart';
import 'qr_scanner_page.dart';
import 'lead_list_page.dart';
import 'guest_list_page.dart';
import 'settings_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _selectedEventId;
  int? _selectedYear;
  bool _showAbsoluteNumbers = false;

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadListProvider);
    final events = ref.watch(eventProvider);

    // AnnotatedRegion removed, using AppBar systemOverlayStyle instead
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            SystemUiOverlayStyle.light, // White icons for dark theme
        backgroundColor:
            Colors.transparent, // Ensure it melts into the background
        elevation: 0,
        automaticallyImplyLeading:
            false, // Hide back button since it's now Home
        title: Text(
          'Messe Connect',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w100,
            fontSize: 32,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white24),
            onPressed: () => ref.read(authProvider.notifier).logout(),
            tooltip: 'Abmelden',
          ),
        ],
      ),
      body: leadsAsync.when(
        data: (leads) => Column(
          children: [
            Expanded(child: _buildContent(leads, events)),
            _buildBottomNavigation(context),
          ],
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, stack) => Center(child: Text('Fehler: $err')),
      ),
    );
  }

// ... content ...

  Widget _buildContent(List<Lead> leads, List<Event> events) {
    final filteredLeads = leads.where((l) {
      bool matchEvent =
          _selectedEventId == null || l.eventId == _selectedEventId;
      bool matchYear = _selectedYear == null || l.year == _selectedYear;
      return matchEvent && matchYear;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilters(events, leads),
              const SizedBox(height: 16),
              _buildSummaryCards(filteredLeads),
              const SizedBox(height: 16),
              _buildFacts(filteredLeads, events),
              const SizedBox(height: 20),
              Center(child: _buildSectionTitle('KUNDENSTRUKTUR')),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: _buildPieChart(filteredLeads),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(List<Lead> leads) {
    if (leads.isEmpty) {
      return const Center(
          child: Text('Keine Daten', style: TextStyle(color: Colors.white24)));
    }

    final Map<String, int> typeCounts = {};
    for (var l in leads) {
      typeCounts[l.clientType] = (typeCounts[l.clientType] ?? 0) + 1;
    }

    final colors = [
      Colors.indigoAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.cyanAccent,
      Colors.pinkAccent
    ];

    return SizedBox(
      height: 300,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // Catch all taps within the area
        onTap: () {
          print("Pie Chart Tapped"); // Debug print
          setState(() {
            _showAbsoluteNumbers = !_showAbsoluteNumbers;
          });
        },
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            pieTouchData:
                PieTouchData(enabled: false), // Disable internal handling
            sections: typeCounts.entries.toList().asMap().entries.map((entry) {
              final value = entry.value;
              final percentage =
                  (value.value / leads.length * 100).toStringAsFixed(0);

              final color = colors[entry.key % colors.length];
              String label = value.key;

              // Format label: split by / or specific handling for long names
              if (label.contains('/')) {
                label = label.replaceAll('/', '\n');
              } else if (label.startsWith('Selbständige') ||
                  label.startsWith('Selbstständige')) {
                label = label.replaceFirst(' ', '\n');
              }

              return PieChartSectionData(
                color: color,
                value: value.value.toDouble(),
                title: _showAbsoluteNumbers
                    ? value.value.toString()
                    : '$percentage%',
                radius: 65, // Slightly reduced
                titlePositionPercentageOffset: 0.55, // Inside
                titleStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: [
                    const Shadow(
                      color: Colors.black45,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                badgeWidget: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                    height: 1.1,
                  ),
                ),
                badgePositionPercentageOffset: 1.6, // Outside further
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: _buildNavigationButtons(context),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            context,
            icon: Icons.person_add_outlined,
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LeadFormPage()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            context,
            icon: Icons.qr_code_scanner_rounded,
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScannerPage()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            context,
            icon: Icons.layers_outlined,
            color: const Color(0xFFF59E0B),
            onTap: () => _showArchiveBottomSheet(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            context,
            icon: Icons.settings_outlined,
            color: Colors.grey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 64, // Reduced height as label is removed
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05)),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  void _showArchiveBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Colors.indigoAccent,
                ),
              ),
              title: Text(
                'Messeberichte (Leads)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeadListPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF10B981),
                ),
              ),
              title: Text(
                'Gästeliste (Check-in)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GuestListPage()),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<Event> events, List<Lead> leads) {
    // Determine available years based on leads and selected event
    final availableYears = leads
        .where((l) => _selectedEventId == null || l.eventId == _selectedEventId)
        .map((l) => l.year)
        .whereType<int>() // Filter out nulls
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    // If no years found (e.g. no data), fallback to last 10 years
    if (availableYears.isEmpty) {
      final currentYear = DateTime.now().year;
      for (int i = 0; i < 10; i++) {
        availableYears.add(currentYear - i);
      }
    }

    // Reset selected year if it's not in the available list for the new event
    if (_selectedYear != null && !availableYears.contains(_selectedYear)) {
      // Logic handled in build via effectiveSelectedYear
    }

    final effectiveSelectedYear =
        availableYears.contains(_selectedYear) ? _selectedYear : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 14,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'FILTER',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModernDropdown<String>(
                  context: context,
                  value: _selectedEventId,
                  hint: 'Alle Events',
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Alle Events')),
                    ...events.map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.name))),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedEventId = v;
                      _selectedYear = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernDropdown<int>(
                  context: context,
                  value: effectiveSelectedYear,
                  hint: 'Alle Jahre',
                  items: [
                    const DropdownMenuItem<int>(
                        value: null, child: Text('Alle Jahre')),
                    ...availableYears.map((y) =>
                        DropdownMenuItem(value: y, child: Text(y.toString()))),
                  ],
                  onChanged: (v) => setState(() => _selectedYear = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required BuildContext context,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                fontSize: 13,
              )),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
              size: 20),
          dropdownColor: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 16,
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Lead> leads) {
    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'TOTAL LEADS',
          value: leads.length.toString(),
          icon: Icons.people_outline,
          color: const Color(0xFF6366F1), // Indigo
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          title: 'HOT PROJECTS',
          value: leads
              .where((l) =>
                  l.projectChance?.contains(RegExp(r'[7-9][0-9]%')) ?? false)
              .length
              .toString(),
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFEC4899), // Pink/Red
        ),
      ],
    );
  }

  Widget _buildFacts(List<Lead> leads, List<Event> events) {
    if (leads.isEmpty) return const SizedBox.shrink();

    final hotLeads = leads
        .where(
            (l) => l.projectChance?.contains(RegExp(r'[7-9][0-9]%')) ?? false)
        .length;
    final conversionRate = ((hotLeads / leads.length) * 100).toStringAsFixed(1);

    final avgLeads = events.isNotEmpty
        ? (leads.length / events.length).toStringAsFixed(1)
        : '0';

    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'CONVERSION',
          value: '$conversionRate%',
          icon: Icons.trending_up_rounded,
          color: Colors.greenAccent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          title: 'Ø LEADS/EVENT',
          value: avgLeads,
          icon: Icons.analytics_outlined,
          color: Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Slightly larger padding
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22), // Slightly larger icon
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 20, // Slightly larger font
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
