import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static Future<void> downloadModel() async {
    final modelUrl = 'https://storage.googleapis.com/plant_disease_models/plant_disease_model.tflite';
    final response = await http.get(Uri.parse(modelUrl));
    
    if (response.statusCode == 200) {
      final documentsDir = await getApplicationDocumentsDirectory();
      final modelPath = '${documentsDir.path}/assets/plant_disease_model.tflite';
      
      // Create directory if it doesn't exist
      final modelDir = Directory('${documentsDir.path}/assets');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      
      // Write model file
      await File(modelPath).writeAsBytes(response.bodyBytes);
      print('Model downloaded successfully to: $modelPath');
    } else {
      throw Exception('Failed to download model');
    }
  }
}
