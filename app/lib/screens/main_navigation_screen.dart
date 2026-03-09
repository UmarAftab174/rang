import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _activeNav = 0; // Explore active by default

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      ExploreScreen(),
      HomeScreen(isEmbedded: true),
      SizedBox.shrink(), // Scan placeholder (index 2 always pushes camera)
      HistoryScreen(),
      SettingsScreen(isEmbedded: true),
    ];
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Center scan button: show camera permission prompt first
      Navigator.pushNamed(context, '/permissions');
      return;
    }
    setState(() => _activeNav = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true,
      body: IndexedStack(
        index: _activeNav,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNavBar(
        activeIndex: _activeNav,
        onTap: _onNavTap,
      ),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.activeIndex, required this.onTap});

  static const _items = [
    _NavItem(label: 'Explore', icon: Icons.explore_outlined, activeIcon: Icons.explore),
    _NavItem(label: 'Palettes', icon: Icons.palette_outlined, activeIcon: Icons.palette),
    _NavItem(label: 'Scan', icon: Icons.camera_alt_rounded, activeIcon: Icons.camera_alt_rounded),
    _NavItem(label: 'History', icon: Icons.history_outlined, activeIcon: Icons.history),
    _NavItem(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF14142B).withOpacity(0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.06),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (i) {
                  if (i == 2) {
                    // ── Center scan button ──
                    return Expanded(
                      child: _CenterScanButton(onTap: () => onTap(2)),
                    );
                  }
                  return Expanded(
                    child: _NavTabButton(
                      item: _items[i],
                      isActive: i == activeIndex,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav data ──────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
}

// ── Regular tab button ────────────────────────────────────────────────────────

class _NavTabButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTabButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Active top line indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: isActive ? 18 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          Icon(
            isActive ? item.activeIcon : item.icon,
            color: isActive ? AppTheme.primaryPurpleLight : AppTheme.textMuted,
            size: 21,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryPurpleLight : AppTheme.textMuted,
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Center "Scan" button ──────────────────────────────────────────────────────

class _CenterScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF9F7AEA), // Lighter purple
                  AppTheme.primaryPurpleDark,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
