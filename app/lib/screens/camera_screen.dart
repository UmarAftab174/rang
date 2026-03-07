import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../theme/app_theme.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _DetectedColor {
  const _DetectedColor({
    required this.color,
    required this.name,
    required this.percentage,
  });

  final Color color;
  final String name;
  final double percentage;

  String get hex =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _flashOn = false;
  bool _isLiveMode = true;
  bool _isAnalyzing = false;

  List<_DetectedColor> _detectedColors = const [];

  Timer? _scanTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _pulseController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  // ── Camera init ────────────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _redirectToPermissions();
        return;
      }
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      // Let the preview warm up
      await Future.delayed(const Duration(milliseconds: 400));
      _startScanning();
    } on CameraException catch (e) {
      const deniedCodes = {
        'CameraAccessDenied',
        'permissionDenied',
        'notAllowed',
        'NotAllowedError',
        'AudioAccessDenied',
      };
      if (deniedCodes.contains(e.code)) {
        _redirectToPermissions();
      }
    } catch (_) {
      _redirectToPermissions();
    }
  }

  void _redirectToPermissions() {
    if (mounted) Navigator.pushReplacementNamed(context, '/permissions');
  }

  // ── Scanning loop ─────────────────────────────────────────────────────────

  void _startScanning() {
    _captureAndAnalyze();
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_isLiveMode && mounted && _isInitialized) _captureAndAnalyze();
    });
  }

  Future<void> _captureAndAnalyze() async {
    final ctrl = _controller;
    if (ctrl == null ||
        !ctrl.value.isInitialized ||
        ctrl.value.isTakingPicture) return;
    try {
      if (mounted) setState(() => _isAnalyzing = true);
      final xFile = await ctrl.takePicture();
      final bytes = await xFile.readAsBytes();
      final colors = _analyzeImage(bytes);
      if (mounted) {
        setState(() {
          _detectedColors = colors;
          _isAnalyzing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  List<_DetectedColor> _analyzeImage(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return [];

    final cx = image.width ~/ 2;
    final cy = image.height ~/ 2;
    const half = 60;
    const step = 4;

    final Map<int, int> counts = {};
    for (int y = cy - half; y < cy + half; y += step) {
      for (int x = cx - half; x < cx + half; x += step) {
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
        final p = image.getPixel(x, y);
        // Quantize to 5-bit per channel
        final r = (p.r.toInt() >> 3) << 3;
        final g = (p.g.toInt() >> 3) << 3;
        final b = (p.b.toInt() >> 3) << 3;
        final key = (r << 16) | (g << 8) | b;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return [];
    final total = counts.values.fold(0, (a, b) => a + b);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(4).map((e) {
      final r = (e.key >> 16) & 0xFF;
      final g = (e.key >> 8) & 0xFF;
      final b = e.key & 0xFF;
      final color = Color.fromARGB(255, r, g, b);
      final pct = (e.value / total * 100).roundToDouble();
      return _DetectedColor(
        color: color,
        name: _colorName(color),
        percentage: pct,
      );
    }).toList();
  }

  String _colorName(Color c) {
    final hsl = HSLColor.fromColor(c);
    final h = hsl.hue;
    final s = hsl.saturation;
    final l = hsl.lightness;

    if (l > 0.92) return 'Soft White';
    if (l < 0.10) return 'Deep Black';
    if (s < 0.12) {
      if (l > 0.70) return 'Light Gray';
      if (l > 0.40) return 'Silver';
      return 'Charcoal';
    }

    String prefix = '';
    if (l < 0.28) {
      prefix = 'Deep ';
    } else if (l > 0.72) {
      prefix = 'Light ';
    } else if (s > 0.75) {
      prefix = 'Vivid ';
    }

    if (h < 15 || h >= 345) return '${prefix}Red';
    if (h < 40) return '${prefix}Orange';
    if (h < 70) return '${prefix}Yellow';
    if (h < 150) return '${prefix}Green';
    if (h < 195) return '${prefix}Cyan';
    if (h < 225) return '${prefix}Azure';
    if (h < 255) return '${prefix}Indigo';
    if (h < 285) return '${prefix}Purple';
    if (h < 325) return '${prefix}Magenta';
    return '${prefix}Rose';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview (or black bg while loading)
          if (_isInitialized)
            CameraPreview(_controller!)
          else
            const ColoredBox(color: Colors.black),

          // Top gradient scrim
          const Align(
            alignment: Alignment.topCenter,
            child: _TopScrim(),
          ),

          // Full UI overlay
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                _buildModeToggle(),
                Expanded(child: _buildViewfinder()),
                _buildBottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryPurple,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.9),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ChromaLens',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          _CircleButton(
            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
            onTap: _toggleFlash,
            active: _flashOn,
          ),
        ],
      ),
    );
  }

  void _toggleFlash() async {
    setState(() => _flashOn = !_flashOn);
    if (_isInitialized) {
      try {
        await _controller!
            .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      } catch (_) {}
    }
  }

  // ── Mode toggle ────────────────────────────────────────────────────────────

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.5),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(
            label: 'Live',
            active: _isLiveMode,
            onTap: () {
              if (!_isLiveMode) {
                setState(() => _isLiveMode = true);
                _startScanning();
              }
            },
          ),
          _ModeChip(
            label: 'Capture',
            active: !_isLiveMode,
            onTap: () {
              if (_isLiveMode) {
                setState(() => _isLiveMode = false);
                _scanTimer?.cancel();
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Viewfinder ─────────────────────────────────────────────────────────────

  Widget _buildViewfinder() {
    return Stack(
      children: [
        // Corner brackets
        Positioned.fill(
          child: CustomPaint(painter: const _CornerPainter()),
        ),

        // Scanning indicator
        Center(
          child: AnimatedOpacity(
            opacity: _isAnalyzing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: FadeTransition(
              opacity: _pulseAnim,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'SCANNING...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right-side buttons
        Positioned(
          right: 14,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleButton(icon: Icons.zoom_in_rounded, onTap: () {}),
              const SizedBox(height: 12),
              _CircleButton(icon: Icons.grid_view_rounded, onTap: () {}),
              const SizedBox(height: 12),
              _CircleButton(icon: Icons.history_rounded, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom panel ───────────────────────────────────────────────────────────

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF130D22).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'DETECTED COLORS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: AppTheme.accentGreen.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGreen.withOpacity(0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI ANALYSIS ACTIVE',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Color swatches
          SizedBox(
            height: 78,
            child: _detectedColors.isEmpty
                ? Center(
                    child: Text(
                      'Point camera at any surface to detect colors',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _detectedColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 22),
                    itemBuilder: (_, i) => _ColorSwatch(dc: _detectedColors[i]),
                  ),
          ),

          const SizedBox(height: 18),

          // Shutter button
          GestureDetector(
            onTap: _isLiveMode ? _savePalette : _captureAndAnalyze,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.6), width: 3),
              ),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePalette() {
    if (_detectedColors.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Palette saved! (${_detectedColors.length} colors captured)'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppTheme.primaryPurple.withOpacity(0.8)
              : Colors.black.withOpacity(0.5),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color:
              active ? AppTheme.primaryPurple : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.dc});
  final _DetectedColor dc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dc.color,
            border:
                Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: dc.color.withOpacity(0.45),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          dc.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${dc.hex} • ${dc.percentage.toInt()}%',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.65),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ── Corner bracket painter ────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7B61FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    final mx = size.width * 0.18;
    final my = size.height * 0.18;

    void bracket(double x, double y, double sx, double sy) {
      canvas.drawLine(Offset(x, y + sy * len), Offset(x, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x + sx * len, y), paint);
    }

    bracket(mx, my, 1, 1);
    bracket(size.width - mx, my, -1, 1);
    bracket(mx, size.height - my, 1, -1);
    bracket(size.width - mx, size.height - my, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
