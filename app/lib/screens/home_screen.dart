import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _Palette {
  final String name;
  final List<Color> colors;
  final bool isFavorite;
  final String timeAgo;

  const _Palette({
    required this.name,
    required this.colors,
    required this.timeAgo,
    this.isFavorite = false,
  });
}

const List<_Palette> _palettes = [
  _Palette(
    name: 'Ocean Sunset',
    colors: [
      Color(0xFFFF9E7D),
      Color(0xFFFFCCBB),
      Color(0xFF4A90E2),
      Color(0xFF1A4B8E),
      Color(0xFF0D2547),
    ],
    isFavorite: true,
    timeAgo: '2d ago',
  ),
  _Palette(
    name: 'Deep Forest',
    colors: [
      Color(0xFF2D4F1E),
      Color(0xFF4B6F44),
      Color(0xFF8FB339),
      Color(0xFFD9E5D6),
      Color(0xFF1B2615),
    ],
    timeAgo: '5d ago',
  ),
  _Palette(
    name: 'Cyber Night',
    colors: [
      Color(0xFF00F5FF),
      Color(0xFF7B61FF),
      Color(0xFFFF00E5),
      Color(0xFF120F23),
      Color(0xFF1D1D42),
    ],
    timeAgo: '1w ago',
  ),
  _Palette(
    name: 'Sahara Sands',
    colors: [
      Color(0xFFE8C07D),
      Color(0xFFD4A373),
      Color(0xFFFAEDCD),
      Color(0xFFCCD5AE),
      Color(0xFFFEFAE0),
    ],
    isFavorite: true,
    timeAgo: '2w ago',
  ),
  _Palette(
    name: 'Alps Winter',
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFC0CFD1),
      Color(0xFF6F8A91),
      Color(0xFF2C3E50),
      Color(0xFFBDC3C7),
    ],
    timeAgo: '3w ago',
  ),
  _Palette(
    name: 'Floral Meadow',
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFFFF8C42),
      Color(0xFF7B61FF),
    ],
    timeAgo: '1m ago',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeFilter = 0;
  int _activeNav = 1; // Library active
  final _filters = const ['Recent', 'Most Colors', 'Favorites', 'Collections'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.photo_camera, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: _palettes.length,
                itemBuilder: (context, index) =>
                    _PaletteCard(palette: _palettes[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App bar row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryPurple,
                ),
                child: const Icon(Icons.palette, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'ChromaLens',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              style:
                  const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search your palettes...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),

        // Filter chips
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final active = index == _activeFilter;
              return GestureDetector(
                onTap: () => setState(() => _activeFilter = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.primaryPurple
                        : AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color:
                          active ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (label: 'Explore', icon: Icons.explore_outlined, activeIcon: Icons.explore),
      (label: 'Library', icon: Icons.folder_special_outlined, activeIcon: Icons.folder_special),
      (label: 'Generate', icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome),
      (label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          top: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == _activeNav;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _activeNav = i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        color: active
                            ? AppTheme.primaryPurple
                            : AppTheme.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label.toUpperCase(),
                        style: TextStyle(
                          color: active
                              ? AppTheme.primaryPurple
                              : AppTheme.textSecondary,
                          fontSize: 9,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Palette card ──────────────────────────────────────────────────────────────

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({required this.palette});
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / gradient preview area
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient built from palette colors
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: palette.colors,
                        stops: List.generate(
                          palette.colors.length,
                          (i) => i / (palette.colors.length - 1),
                        ),
                      ),
                    ),
                  ),
                  // Subtle dark overlay at bottom for readability
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x66000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Favorite icon
                  if (palette.isFavorite)
                    const Positioned(
                      bottom: 8,
                      right: 8,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              palette.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6),

          // Color swatch strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: palette.colors
                      .map((c) => Expanded(child: ColoredBox(color: c)))
                      .toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // 5 Colors + time ago
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${palette.colors.length} COLORS',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  palette.timeAgo,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
