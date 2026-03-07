import 'dart:math' as math;
import 'package:flutter/material.dart';

// Per-page theme data
class _PageTheme {
  final Color accent;
  final IconData icon;
  final String title;
  final String description;
  const _PageTheme({
    required this.accent,
    required this.icon,
    required this.title,
    required this.description,
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFF7B61FF);
  static const Color _bg = Color(0xFF120F23);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _pulseController;
  late AnimationController _rotateController;

  static const List<_PageTheme> _pages = [
    _PageTheme(
      accent: _primary,
      icon: Icons.blur_on,
      title: 'ChromaLens',
      description: 'See the world in color',
    ),
    _PageTheme(
      accent: Color(0xFF06B6D4),
      icon: Icons.colorize,
      title: 'Color Detection',
      description: 'Identify colors instantly with AI',
    ),
    _PageTheme(
      accent: Color(0xFF10B981),
      icon: Icons.camera_alt_rounded,
      title: 'Camera Access',
      description: 'Enable camera to analyze colors in real time',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _onGetStarted() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onSignIn() {
    Navigator.pushNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background gradient blobs
          _buildBackground(),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Skip button row
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: _primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, i) => _buildPage(_pages[i], i),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => _buildDot(i),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shadowColor: _primary.withOpacity(0.4),
                        elevation: 12,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Allow Camera Access' : 'Get Started',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign in row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _onSignIn,
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Diagonal gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0x26_7B61FF), // primary 15%
                  Colors.transparent,
                  Color(0x14_7B61FF), // primary 8%
                ],
              ),
            ),
          ),
        ),
        // Top-left blob
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x33_7B61FF), Colors.transparent],
              ),
            ),
          ),
        ),
        // Bottom-right blob
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x3D_7B61FF), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(_PageTheme theme, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hero visual — aspect square
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: AspectRatio(
            aspectRatio: 1,
            child: _buildHeroVisual(theme),
          ),
        ),
        const SizedBox(height: 40),
        // Title
        Text(
          theme.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Description
        Text(
          theme.description,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 17,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        // Page 3 extra: feature cards
        if (index == 2) ...[
          const SizedBox(height: 28),
          _buildFeatureRow(
            icon: Icons.visibility_outlined,
            label: 'Live Viewfinder',
            accent: theme.accent,
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            icon: Icons.colorize_outlined,
            label: 'Instant Hex Codes',
            accent: theme.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'You can change permissions anytime in Settings.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildHeroVisual(_PageTheme theme) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, _) {
        final pulse = _pulseController.value;
        final rotate = _rotateController.value * 2 * math.pi;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.accent.withOpacity(0.12),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: theme.accent.withOpacity(0.20),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accent.withOpacity(0.06),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Backdrop tint
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  color: _bg.withOpacity(0.45),
                ),
              ),
              // Rotating dashed outer circle
              SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Transform.rotate(
                    angle: rotate,
                    child: CustomPaint(
                      painter: _DashedCirclePainter(
                        color: theme.accent.withOpacity(0.35),
                        strokeWidth: 3,
                        dashCount: 20,
                      ),
                    ),
                  ),
                ),
              ),
              // Inner static circle
              SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.all(52),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.accent.withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Glow + icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.withOpacity(0.45 + pulse * 0.25),
                      blurRadius: 20 + pulse * 16,
                      spreadRadius: 2 + pulse * 3,
                    ),
                  ],
                ),
                child: Icon(
                  theme.icon,
                  size: 110,
                  color: theme.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withOpacity(0.08),
        border: Border.all(color: accent.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accent.withOpacity(0.15),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? _primary : _primary.withOpacity(0.25),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _primary.withOpacity(0.5),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
    );
  }
}

// Dashed circle painter
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final angleStep = 2 * math.pi / dashCount;
    // Each dash covers half a step, gap covers other half
    final dashAngle = angleStep * 0.5;

    for (int i = 0; i < dashCount; i++) {
      final start = angleStep * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.dashCount != dashCount;
}

class OnboardingItem {
  final String title;
  final String description;
  OnboardingItem({required this.title, required this.description});
}

