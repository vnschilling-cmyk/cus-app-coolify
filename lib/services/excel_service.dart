import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/lead.dart';

class ExcelService {
  Future<void> exportLeads(List<Lead> leads) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Messeberichte'];

    // Headers
    sheetObject.appendRow([
      TextCellValue('Name'),
      TextCellValue('Firma'),
      TextCellValue('Land'),
      TextCellValue('Kundenart'),
      TextCellValue('Waterloop Vorteile'),
      TextCellValue('Waterloop Bedenken'),
      TextCellValue('Regelung Handling'),
      TextCellValue('Regelung Positiv'),
      TextCellValue('Regelung Kritik'),
      TextCellValue('Kältetechnik Feedback'),
      TextCellValue('Kältetechnik Vorteile'),
      TextCellValue('Kältetechnik Followup'),
      TextCellValue('Energieeffizienz Prio'),
      TextCellValue('Projektchance'),
      TextCellValue('Follow-up'),
    ]);

    // Data
    for (var lead in leads) {
      sheetObject.appendRow([
        TextCellValue(lead.name),
        TextCellValue(lead.company),
        TextCellValue(lead.country ?? ''),
        TextCellValue(lead.clientType),
        TextCellValue(lead.waterloopAdvantages ?? ''),
        TextCellValue(lead.waterloopConcerns ?? ''),
        TextCellValue(lead.regulationHandling ?? ''),
        TextCellValue(lead.regulationPositiveFeedback ?? ''),
        TextCellValue(lead.regulationCriticismWishes ?? ''),
        TextCellValue(lead.coolingTechFeedback ?? ''),
        TextCellValue(lead.coolingTechAdvantages ?? ''),
        TextCellValue(lead.coolingTechFollowup ?? ''),
        TextCellValue(lead.energyEfficiencyPriority ?? ''),
        TextCellValue(lead.projectChance ?? ''),
        TextCellValue(lead.followUp ?? ''),
      ]);
    }

    // Save
    if (kIsWeb) {
      excel.save(
        fileName: 'Messeberichte_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );
    } else {
      final fileBytes = excel.save();
      if (fileBytes != null) {
        var directory = await getApplicationDocumentsDirectory();
        File(
            "${directory.path}/Messeberichte_${DateTime.now().millisecondsSinceEpoch}.xlsx",
          )
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    }
  }
}
