import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassifierService {
  Interpreter? _interpreter;
  static const int inputSize = 128;
  static const List<String> classNames = ['blue', 'purple', 'yellow'];
  static const Map<String, String> beltMap = {
    'blue': 'Conveyor Belt A',
    'yellow': 'Conveyor Belt B',
    'purple': 'Conveyor Belt C',
  };

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/conveyor_model.tflite');
  }

  Map<String, dynamic>? predict(img.Image image) {
    if (_interpreter == null) return null;
    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    final input = List.generate(1, (_) =>
      List.generate(inputSize, (y) =>
        List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        })
      )
    );
    final output = [List<double>.filled(3, 0.0)];
    _interpreter!.run(input, output);
    final scores = output[0];
    final maxIdx = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
    return {
      'color': classNames[maxIdx],
      'belt': beltMap[classNames[maxIdx]]!,
      'confidence': scores[maxIdx] * 100,
      'scores': { for (int i = 0; i < classNames.length; i++) classNames[i]: scores[i] * 100 },
    };
  }

  void dispose() => _interpreter?.close();
}
