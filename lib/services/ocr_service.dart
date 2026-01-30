import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<Map<String, String>> scanBusinessCard(XFile image) async {
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    String name = "";
    String company = "";
    String country = "";

    // Basic heuristic-based extraction
    // In a production app, use a more robust entity extraction (e.g. LLM or specialized regex)
    List<String> lines = recognizedText.text.split('\n');
    if (lines.isNotEmpty) {
      name = lines[0]; // Usually the name is at the top
    }
    if (lines.length > 1) {
      company = lines[1]; // Often the company follows
    }

    // Look for keywords like "GmbH", "Inc", etc. for company
    for (var line in lines) {
      if (line.contains('GmbH') ||
          line.contains('AG') ||
          line.contains('Inc.')) {
        company = line;
      }
    }

    return {'name': name, 'company': company, 'country': country};
  }

  void dispose() {
    _textRecognizer.close();
  }
}
