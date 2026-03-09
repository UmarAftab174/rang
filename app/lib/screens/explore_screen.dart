import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

class _TrendingPalette {
  final String name;
  final List<Color> colors;
  final String source;
  final int likes;

  const _TrendingPalette({
    required this.name,
    required this.colors,
    required this.source,
    required this.likes,
  });
}

const _colorOfTheDay = (
  name: 'Mauvewood',
  hex: '#A4586E',
  color: Color(0xFFA4586E),
  desc: 'A muted rose-brown that evokes warmth and quiet sophistication.',
);

const List<_TrendingPalette> _trending = [
  _TrendingPalette(
    name: 'Neon Tokyo',
    colors: [Color(0xFFFF006E), Color(0xFF8338EC), Color(0xFF3A86FF), Color(0xFFFFBE0B), Color(0xFFFB5607)],
    source: 'Community',
    likes: 2341,
  ),
  _TrendingPalette(
    name: 'Soft Clay',
    colors: [Color(0xFFC9ADA7), Color(0xFF9A8C98), Color(0xFF4A4E69), Color(0xFF22223B), Color(0xFFF2E9E4)],
    source: 'AI Generated',
    likes: 1892,
  ),
  _TrendingPalette(
    name: 'Tropical Storm',
    colors: [Color(0xFF05668D), Color(0xFF028090), Color(0xFF00A896), Color(0xFF02C39A), Color(0xFFF0F3BD)],
    source: 'Community',
    likes: 1456,
  ),
  _TrendingPalette(
    name: 'Midnight Ember',
    colors: [Color(0xFF1A1423), Color(0xFF372549), Color(0xFF774C60), Color(0xFFB75D69), Color(0xFFEACDC2)],
    source: 'Curated',
    likes: 987,
  ),
];

const List<Map<String, dynamic>> _recentColors = [
  {'name': 'Coral', 'hex': '#FF7F50', 'color': Color(0xFFFF7F50)},
  {'name': 'Teal', 'hex': '#008080', 'color': Color(0xFF008080)},
  {'name': 'Amber', 'hex': '#FFBF00', 'color': Color(0xFFFFBF00)},
  {'name': 'Indigo', 'hex': '#4B0082', 'color': Color(0xFF4B0082)},
  {'name': 'Mint', 'hex': '#98FB98', 'color': Color(0xFF98FB98)},
  {'name': 'Slate', 'hex': '#708090', 'color': Color(0xFF708090)},
];

// ── Screen ────────────────────────────────────────────────────────────────────

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Color of the Day ───────────────────────────────────
            SliverToBoxAdapter(child: _buildColorOfTheDay()),

            // ── Quick Colors ───────────────────────────────────────
            SliverToBoxAdapter(child: _buildRecentColors()),

            // ── Trending Palettes title ────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: AppTheme.primaryPurpleLight, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Trending Palettes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Trending palette cards ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTrendingCard(_trending[index]),
                  ),
                  childCount: _trending.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E0E0)],
                  ).createShader(bounds),
                  child: const Icon(Icons.shutter_speed, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Color Segmentation',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryPurple.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: AppTheme.primaryPurpleLight,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
            ),
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search colors, palettes...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOfTheDay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _colorOfTheDay.color.withOpacity(0.25),
              AppTheme.backgroundCard,
            ],
          ),
          border: Border.all(
            color: _colorOfTheDay.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Color swatch
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _colorOfTheDay.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _colorOfTheDay.color.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.accentOrange, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'COLOR OF THE DAY',
                        style: TextStyle(
                          color: AppTheme.accentOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _colorOfTheDay.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _colorOfTheDay.hex,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Row(
            children: [
              Icon(Icons.color_lens_outlined, color: AppTheme.primaryPurpleLight, size: 18),
              SizedBox(width: 8),
              Text(
                'Quick Colors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recentColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final c = _recentColors[index];
              return Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: c['color'] as Color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (c['color'] as Color).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c['name'] as String,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(_TrendingPalette palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color strip
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 48,
              child: Row(
                children: palette.colors
                    .map((c) => Expanded(child: ColoredBox(color: c)))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Name + metadata
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palette.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            palette.source,
                            style: const TextStyle(
                              color: AppTheme.primaryPurpleLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${palette.colors.length} colors',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.favorite_border, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${palette.likes}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
