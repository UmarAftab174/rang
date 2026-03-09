import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Auto-dismissing splash screen inspired by Instagram/Spotify.
/// Shows for ~3 seconds with staggered animations, then navigates to /home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _brand = AppTheme.primary;
  static const Color _cyan = AppTheme.accent;
  static const Color _bg = AppTheme.backgroundDark;

  late AnimationController _entryController;
  late AnimationController _exitController;

  // Entry animations (staggered)
  late Animation<double> _bgFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _ringRotate;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _footerFade;

  // Exit animation
  late Animation<double> _exitFade;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // ── Entry: 2s staggered reveal ──
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bgFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _logoScale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.1, 0.45, curve: Curves.elasticOut)),
    );
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.1, 0.4, curve: Curves.easeOut)),
    );
    _ringRotate = Tween(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
    );
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.35, 0.6, curve: Curves.easeOut)),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.35, 0.6, curve: Curves.easeOut)),
    );
    _subtitleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.5, 0.75, curve: Curves.easeOut)),
    );
    _footerFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.65, 0.9, curve: Curves.easeOut)),
    );

    // ── Exit: 400ms fade out ──
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _exitFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    // Start the show
    _entryController.forward();

    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), _startExit);
  }

  void _startExit() {
    if (!mounted || _navigated) return;
    _exitController.forward().then((_) {
      if (!mounted || _navigated) return;
      _navigated = true;
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryController, _exitController]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFade,
            child: Stack(
              children: [
                // ── Background ──────────────────────────────────────
                Opacity(opacity: _bgFade.value, child: _buildBackground()),

                // ── Content ─────────────────────────────────────────
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Logo
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _buildLogo(),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        SlideTransition(
                          position: _titleSlide,
                          child: FadeTransition(
                            opacity: _titleFade,
                          child: _buildTitle(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: const Text(
                          'AI-Powered Color Segmentation',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // Footer
                      FadeTransition(
                        opacity: _footerFade,
                        child: Column(
                          children: [
                            // Loading indicator
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  _brand.withOpacity(0.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'RANG • COLOR SEGMENTATION',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Gradient mesh background ──────────────────────────────────────────────

  Widget _buildBackground() {
    return Stack(
      children: [
        // Full screen dark base
        Positioned.fill(child: Container(color: _bg)),
        // Top-left purple glow
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_brand.withOpacity(0.12), Colors.transparent],
              ),
            ),
          ),
        ),
        // Bottom-right cyan glow
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_cyan.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        // Top-right subtle cyan
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_cyan.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
        ),
        // Bottom-left subtle purple
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_brand.withOpacity(0.06), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Logo: conic gradient iris ring + shutter icon ─────────────────────────

  Widget _buildLogo() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Purple glow behind
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _brand.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          // Outer frosted circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F172A).withOpacity(0.50),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // Conic gradient ring
          Transform.rotate(
            angle: _ringRotate.value * 2 * math.pi,
            child: SizedBox(
              width: 128,
              height: 128,
              child: CustomPaint(
                painter: _ConicGradientRingPainter(
                  colors: const [_brand, _cyan, _brand, _cyan],
                  strokeWidth: 3.5,
                ),
              ),
            ),
          ),
          // Inner dark circle + icon
          Container(
            width: 118,
            height: 118,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _bg,
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_brand, _cyan],
                ).createShader(bounds),
                child: const Icon(
                  Icons.shutter_speed,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFE2E8F0)], // subtle gradient
      ).createShader(bounds),
      child: Text(
        'Rang',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 52,
          fontWeight: FontWeight.w800, // Extra bold for the smooth look
          letterSpacing: -1.5,
          height: 1.1,
        ),
      ),
    );
  }
}

// ── Conic gradient ring painter ─────────────────────────────────────────────

class _ConicGradientRingPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;

  const _ConicGradientRingPainter({
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: math.pi * 3,
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_ConicGradientRingPainter old) =>
      old.strokeWidth != strokeWidth;
}
