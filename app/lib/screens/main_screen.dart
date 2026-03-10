import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../services/classifier_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  CameraController? _cameraController;
  final ClassifierService _classifier = ClassifierService();

  bool _isModelLoaded = false;
  bool _isCameraReady = false;
  bool _isScanning    = false;
  bool _isProcessing  = false;
  Map<String, dynamic>? _result;

  static const Map<String, Color> colorMap = {
    'blue':   Color(0xFF2196F3),
    'yellow': Color(0xFFFFC107),
    'purple': Color(0xFF9C27B0),
  };

  static const Map<String, String> colorEmoji = {
    'blue':   '🔵',
    'yellow': '🟡',
    'purple': '🟣',
  };

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _classifier.loadModel();
    setState(() => _isModelLoaded = true);
    await _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      camera, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    setState(() => _isCameraReady = true);
  }

  void _toggleScanning() {
    if (!_isCameraReady || !_isModelLoaded) return;
    setState(() {
      _isScanning = !_isScanning;
      if (!_isScanning) _result = null;
    });
    if (_isScanning) _startLiveInference();
  }

  Future<void> _startLiveInference() async {
    while (_isScanning && mounted) {
      if (!_isProcessing && _isCameraReady) {
        _isProcessing = true;
        try {
          final xFile = await _cameraController!.takePicture();
          final bytes = await File(xFile.path).readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null && mounted) {
            final result = _classifier.predict(image);
            if (mounted) setState(() => _result = result);
          }
        } catch (_) {}
        _isProcessing = false;
      }
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  @override
  void dispose() {
    _isScanning = false;
    _cameraController?.dispose();
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0533),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Full screen camera ──────────────────────────────
            if (_isCameraReady)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),

            if (!_isCameraReady)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                ),
              ),

            // ── Top bar with app name ───────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // App name
                    const Text(
                      'RANG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),

                    // ── COLOR RESULT BOX (top right) ────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _result != null
                          ? _buildColorBox()
                          : Container(
                              key: const ValueKey('empty'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white24, width: 1),
                              ),
                              child: const Text(
                                'COLOR',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    letterSpacing: 2),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scanning indicator ring ─────────────────────────
            if (_isScanning)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF7C4DFF).withOpacity(0.6),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Bottom controls ────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.only(bottom: 36, top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Belt assignment label
                    if (_result != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '→ ${_result!['belt']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Scan button
                    GestureDetector(
                      onTap: _toggleScanning,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isScanning
                              ? const Color(0xFFFF80AB)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: (_isScanning
                                      ? const Color(0xFFFF80AB)
                                      : const Color(0xFF7C4DFF))
                                  .withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isScanning ? Icons.stop : Icons.camera_alt,
                          color: const Color(0xFF1A0533),
                          size: 32,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      _isScanning ? 'Tap to stop' : 'Tap to scan',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBox() {
    final color      = _result!['color'] as String;
    final confidence = _result!['confidence'] as double;
    final boxColor   = colorMap[color] ?? Colors.white;
    final emoji      = colorEmoji[color] ?? '';

    return AnimatedContainer(
      key: ValueKey(color),
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: boxColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: boxColor.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                color.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${confidence.toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
