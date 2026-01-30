import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/lead.dart';
import '../../providers/lead_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../services/ocr_service.dart';
import '../widgets/custom_text_field.dart';

class LeadFormPage extends ConsumerStatefulWidget {
  final Lead? lead;

  const LeadFormPage({super.key, this.lead});

  @override
  ConsumerState<LeadFormPage> createState() => _LeadFormPageState();
}

class _LeadFormPageState extends ConsumerState<LeadFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _countryController = TextEditingController();

  String _clientType = 'Betreiber/Endkunde';
  String? _selectedEventId;
  int _selectedYear = DateTime.now().year;

  final _waterloopAdvantagesController = TextEditingController();
  final _waterloopConcernsController = TextEditingController();

  final _regulationHandlingController = TextEditingController();
  final _regulationPositiveController = TextEditingController();
  final _regulationWishesController = TextEditingController();

  final _coolingFeedbackController = TextEditingController();
  final _coolingAdvantagesController = TextEditingController();
  final _coolingFollowupController = TextEditingController();

  String _energyPriority = 'Wichtig';
  final _energyCommentController = TextEditingController();

  final _projectChanceController = TextEditingController();
  final _followUpController = TextEditingController();

  final List<String> _clientTypes = [
    'Betreiber/Endkunde',
    'Selbständige Kaufleute',
    'KAB',
    'Planer/Berater',
    'Hersteller/OEM',
    'Lieferant',
    'Wettbewerber',
    'Sonstige',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.lead != null) {
      final l = widget.lead!;
      _nameController.text = l.name;
      _companyController.text = l.company;
      _countryController.text = l.country ?? '';
      _clientType = l.clientType;
      _selectedEventId = l.eventId;
      _selectedYear = l.year ?? DateTime.now().year;
      _waterloopAdvantagesController.text = l.waterloopAdvantages ?? '';
      _waterloopConcernsController.text = l.waterloopConcerns ?? '';
      _regulationHandlingController.text = l.regulationHandling ?? '';
      _regulationPositiveController.text = l.regulationPositiveFeedback ?? '';
      _regulationWishesController.text = l.regulationCriticismWishes ?? '';
      _coolingFeedbackController.text = l.coolingTechFeedback ?? '';
      _coolingAdvantagesController.text = l.coolingTechAdvantages ?? '';
      _coolingFollowupController.text = l.coolingTechFollowup ?? '';
      _energyPriority = l.energyEfficiencyPriority ?? 'Wichtig';
      _energyCommentController.text = l.energyEfficiencyComment ?? '';
      _projectChanceController.text = l.projectChance ?? '';
      _followUpController.text = l.followUp ?? '';
    } else {
      // Default to first event if available for new lead
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final events = ref.read(eventProvider);
        if (events.isNotEmpty) {
          setState(() => _selectedEventId = events.first.id);
        }
      });
    }
  }

  final List<String> _energyPriorities = [
    'Sehr wichtig',
    'Wichtig',
    'Weniger wichtig',
    'Keine Priorität',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MESSEBERICHT',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, size: 20),
            onPressed: _scanBusinessCard,
            tooltip: 'Visitenkarte scannen',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            _buildSection(
              title: 'BASISDATEN',
              icon: Icons.badge_outlined,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _companyController,
                  label: 'Firma',
                  prefixIcon: Icons.business_outlined,
                  validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _countryController,
                  label: 'Land',
                  prefixIcon: Icons.public_outlined,
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'KUNDENART',
                  initialValue: _clientType,
                  items: _clientTypes,
                  onChanged: (v) => setState(() => _clientType = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final events = ref.watch(eventProvider);
                          return _buildGenericDropdown<String>(
                            label: 'VERANSTALTUNG',
                            value: _selectedEventId,
                            items: events
                                .map((e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w200)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedEventId = v),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildGenericDropdown<int>(
                        label: 'JAHR',
                        value: _selectedYear,
                        items: List.generate(
                                11, (index) => DateTime.now().year - 5 + index)
                            .map((y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w200)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedYear = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              title: 'WATERLOOP',
              icon: Icons.water_drop_outlined,
              color: Colors.blueAccent,
              children: [
                CustomTextField(
                  controller: _waterloopAdvantagesController,
                  label: 'Vorteile',
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _waterloopConcernsController,
                  label: 'Bedenken',
                  maxLines: 2,
                ),
              ],
            ),
            _buildSection(
              title: 'REGELUNG',
              icon: Icons.settings_outlined,
              color: Colors.orangeAccent,
              children: [
                CustomTextField(
                  controller: _regulationHandlingController,
                  label: 'Handling / Parametrierung',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _regulationPositiveController,
                  label: 'Positive Rückmeldung',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _regulationWishesController,
                  label: 'Kritik / Wünsche',
                ),
              ],
            ),
            _buildSection(
              title: 'KÄLTETECHNIK',
              icon: Icons.ac_unit_outlined,
              color: Colors.cyanAccent,
              children: [
                CustomTextField(
                  controller: _coolingFeedbackController,
                  label: 'Allg. Feedback',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _coolingAdvantagesController,
                  label: 'Vorteile',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _coolingFollowupController,
                  label: 'Follow-up Punkte',
                ),
              ],
            ),
            _buildSection(
              title: 'ENERGIEEFFIZIENZ',
              icon: Icons.bolt_outlined,
              color: Colors.greenAccent,
              children: [
                _buildRadioGroup(
                  label: 'Priorität',
                  value: _energyPriority,
                  items: _energyPriorities,
                  onChanged: (v) => setState(() => _energyPriority = v!),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _energyCommentController,
                  label: 'Kommentar',
                  maxLines: 2,
                ),
              ],
            ),
            _buildSection(
              title: 'MAßNAHMEN',
              icon: Icons.assignment_outlined,
              color: Colors.purpleAccent,
              children: [
                CustomTextField(
                  controller: _projectChanceController,
                  label: 'Projektchance',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _followUpController,
                  label: 'Follow-up (Was/Wann)',
                ),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _saveLead,
              child: const Text('BERICHT SPEICHERN'),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color color = Colors.indigoAccent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20), // Full color
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14, // Larger
                  fontWeight: FontWeight.w700, // Boldest
                  letterSpacing: 2,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16), // Reduced padding
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.03), // Subtle tint
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12, // Larger
              fontWeight: FontWeight.w600, // Bolder
              letterSpacing: 1.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7), // Visible in light mode
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String initialValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildGenericDropdown<String>(
      label: label,
      value: initialValue.isEmpty ? null : initialValue, // Handle empty init
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: TextStyle(
                      fontWeight: FontWeight.w500, // Bolder
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12, // Larger
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            final isSelected = item == value;
            return InkWell(
              onTap: () => onChanged(item),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _scanBusinessCard() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    if (!mounted) return;
    final image = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerPage(camera: cameras.first),
      ),
    );

    if (image != null) {
      final data = await OCRService().scanBusinessCard(image);
      setState(() {
        _nameController.text = data['name'] ?? '';
        _companyController.text = data['company'] ?? '';
        _countryController.text = data['country'] ?? '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitenkarte erfolgreich gescannt')),
        );
      }
    }
  }

  void _saveLead() async {
    if (_formKey.currentState!.validate()) {
      final lead = Lead(
        id: widget.lead?.id ?? '', // Keep ID if editing
        name: _nameController.text,
        company: _companyController.text,
        country: _countryController.text,
        clientType: _clientType,
        waterloopAdvantages: _waterloopAdvantagesController.text,
        waterloopConcerns: _waterloopConcernsController.text,
        regulationHandling: _regulationHandlingController.text,
        regulationPositiveFeedback: _regulationPositiveController.text,
        regulationCriticismWishes: _regulationWishesController.text,
        coolingTechFeedback: _coolingFeedbackController.text,
        coolingTechAdvantages: _coolingAdvantagesController.text,
        coolingTechFollowup: _coolingFollowupController.text,
        energyEfficiencyPriority: _energyPriority,
        energyEfficiencyComment: _energyCommentController.text,
        projectChance: _projectChanceController.text,
        followUp: _followUpController.text,
        eventId: _selectedEventId,
        year: _selectedYear,
        responsible: ref.read(authProvider.notifier).currentUserId,
      );

      try {
        if (widget.lead != null) {
          await ref.read(leadListProvider.notifier).updateLead(lead);
        } else {
          await ref.read(leadListProvider.notifier).addLead(lead);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Messebericht erfolgreich gespeichert'),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
        }
      }
    }
  }
}

class CameraScannerPage extends StatefulWidget {
  final CameraDescription camera;
  const CameraScannerPage({super.key, required this.camera});

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CAMERA SCANNER',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            fontSize: 14,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (context.mounted) Navigator.pop(context, image);
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
        child: const Icon(Icons.camera_outlined, color: Colors.indigoAccent),
      ),
    );
  }
}
