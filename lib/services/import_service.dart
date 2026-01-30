import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';

class ImportService {
  final Ref ref;

  ImportService(this.ref);

  Future<void> importExcel(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        List<Lead> newLeads = [];

        // Assume the first sheet is the one we want
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet == null) continue;

          // Skip header row (assuming row 0 is header)
          for (int i = 1; i < sheet.maxRows; i++) {
            var row = sheet.rows[i];
            if (row.isEmpty) continue;

            // Simple mapping - adjust indices based on actual Excel structure
            // Assuming: Name (0), Company (1), Email (2), Phone (3), Event (4), Year (5)
            // This is a placeholder structure.

            try {
              String name = row[0]?.value?.toString() ?? 'Unbekannt';
              if (name == 'Unbekannt' || name.isEmpty)
                continue; // Skip empty rows

              String company = row[1]?.value?.toString() ?? '';
              String email = row[2]?.value?.toString() ?? '';
              String phone = row[3]?.value?.toString() ?? '';
              String eventId =
                  row[4]?.value?.toString().toLowerCase() ?? 'old_import';
              int year = int.tryParse(row[5]?.value?.toString() ?? '') ??
                  DateTime.now().year;

              // Generate ID
              String id =
                  '${eventId}_${year}_${DateTime.now().millisecondsSinceEpoch}_$i';

              newLeads.add(Lead(
                id: id,
                name: name,
                company: company,
                eventId: eventId,
                year: year,
                responsible: 'import',
                clientType: 'Sonstige',
                energyEfficiencyPriority: 'Keine Priorität',
                projectChance: '0%',
              ));
            } catch (e) {
              debugPrint('Error parsing row $i: $e');
            }
          }
        }

        if (newLeads.isNotEmpty) {
          final notifier = ref.read(leadListProvider.notifier);
          for (var lead in newLeads) {
            await notifier.addLead(lead);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '${newLeads.length} Datensätze erfolgreich importiert.')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Keine gültigen Daten gefunden.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Import Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Importieren: $e')),
        );
      }
    }
  }
}

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(ref);
});
