import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaletteData {
  final String id;
  final String name;
  final List<Color> colors;
  final bool isFavorite;
  final DateTime createdAt;

  PaletteData({
    required this.id,
    required this.name,
    required this.colors,
    this.isFavorite = false,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}

class ScanResultData {
  final String id;
  final String title;
  final DateTime timestamp;
  final int colorCount;
  final List<Color> dominantColors;
  final String status; // 'completed', 'processing', 'failed'
  final double confidence;

  ScanResultData({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.colorCount,
    required this.dominantColors,
    required this.status,
    required this.confidence,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

class MockDataService {
  static final MockDataService instance = MockDataService._internal();

  MockDataService._internal() {
    _initMockData();
  }

  final ValueNotifier<List<PaletteData>> palettes = ValueNotifier([]);
  final ValueNotifier<List<ScanResultData>> history = ValueNotifier([]);

  void addPalette(PaletteData p) {
    palettes.value = [p, ...palettes.value];
  }

  void addScan(ScanResultData s) {
    history.value = [s, ...history.value];
  }

  void updateScanStatus(String id, String status) {
    final list = List<ScanResultData>.from(history.value);
    final i = list.indexWhere((element) => element.id == id);
    if (i != -1) {
      final old = list[i];
      list[i] = ScanResultData(
        id: old.id,
        title: old.title,
        timestamp: old.timestamp,
        colorCount: old.colorCount,
        dominantColors: old.dominantColors,
        status: status,
        confidence: status == 'completed' ? 0.95 + math.Random().nextDouble() * 0.04 : old.confidence,
      );
      history.value = list;
    }
  }

  void _initMockData() {
    final now = DateTime.now();
    palettes.value = [
      PaletteData(
        id: '1',
        name: 'Ocean Sunset',
        colors: const [Color(0xFFFF9E7D), Color(0xFFFFCCBB), Color(0xFF4A90E2), Color(0xFF1A4B8E), Color(0xFF0D2547)],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PaletteData(
        id: '2',
        name: 'Deep Forest',
        colors: const [Color(0xFF2D4F1E), Color(0xFF4B6F44), Color(0xFF8FB339), Color(0xFFD9E5D6), Color(0xFF1B2615)],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      PaletteData(
        id: '3',
        name: 'Cyber Night',
        colors: const [Color(0xFF00F5FF), Color(0xFF7B61FF), Color(0xFFFF00E5), Color(0xFF120F23), Color(0xFF1D1D42)],
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      PaletteData(
        id: '4',
        name: 'Sahara Sands',
        colors: const [Color(0xFFE8C07D), Color(0xFFD4A373), Color(0xFFFAEDCD), Color(0xFFCCD5AE), Color(0xFFFEFAE0)],
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];

    history.value = [
      ScanResultData(
        id: 'h1',
        title: 'Living Room Wall',
        timestamp: now.subtract(const Duration(hours: 2)),
        colorCount: 7,
        dominantColors: const [Color(0xFFE8C07D), Color(0xFFD4A373), Color(0xFFFAEDCD), Color(0xFF8B7355)],
        status: 'completed',
        confidence: 0.94,
      ),
      ScanResultData(
        id: 'h2',
        title: 'Garden Flowers',
        timestamp: now.subtract(const Duration(hours: 5)),
        colorCount: 12,
        dominantColors: const [Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF2D4F1E), Color(0xFFFFD700)],
        status: 'completed',
        confidence: 0.91,
      ),
      ScanResultData(
        id: 'h3',
        title: 'Sunset Photo',
        timestamp: now.subtract(const Duration(days: 1)),
        colorCount: 9,
        dominantColors: const [Color(0xFFFF9E7D), Color(0xFF4A90E2), Color(0xFF1A4B8E), Color(0xFFFFCCBB)],
        status: 'completed',
        confidence: 0.97,
      ),
      ScanResultData(
        id: 'h4',
        title: 'Fabric Sample',
        timestamp: now.subtract(const Duration(days: 3)),
        colorCount: 4,
        dominantColors: const [Color(0xFF774C60), Color(0xFFB75D69), Color(0xFFEACDC2), Color(0xFF372549)],
        status: 'processing',
        confidence: 0.0,
      ),
    ];
  }
}
