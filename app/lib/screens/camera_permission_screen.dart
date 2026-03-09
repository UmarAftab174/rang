import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Permissions',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.27,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildCameraIcon(),
                      const SizedBox(height: 48),

                      // Title
                      const Text(
                        'Camera Access Required',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Rang needs camera access to analyze and segment colors in real time.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Feature cards
                      _buildFeatureItem(
                        icon: Icons.visibility_outlined,
                        title: 'Live Viewfinder',
                        description: 'See colors as you move your device',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: Icons.palette_outlined,
                        title: 'Color Sampling',
                        description: 'Extract hex codes instantly',
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    // Allow Camera Access
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _requestCameraPermission(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppTheme.primaryPurple.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Allow Camera Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Maybe Later
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.primaryPurple.withOpacity(0.1),
                          foregroundColor: AppTheme.primaryPurple,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Privacy note
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'You can change your permissions at any time in the system settings. Your privacy is our priority.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildCameraIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow + bordered container
        Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: const Color(0xFF9333EA).withOpacity(0.15),
                blurRadius: 48,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Card background
                Container(color: AppTheme.backgroundCard),
                // Centre circle + icon
                Center(
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.photo_camera_outlined,
                        color: AppTheme.primaryPurple,
                        size: 64,
                      ),
                    ),
                  ),
                ),
                // Bottom gradient overlay
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 64,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0x1A8B5CF6), // primaryPurple ~10%
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Check badge
        Positioned(
          bottom: -16,
          right: -16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryPurple,
              border: Border.all(
                color: AppTheme.backgroundDark,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.primaryPurple.withOpacity(0.05),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _requestCameraPermission(BuildContext context) {
    // Pop the permission screen and then push camera
    Navigator.pop(context);
    Navigator.pushNamed(context, '/camera');
  }
}
