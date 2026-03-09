import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const SettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _hapticFeedback = true;
  double _segmentationSensitivity = 1.0;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        automaticallyImplyLeading: !widget.isEmbedded,
        leading: widget.isEmbedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: widget.isEmbedded ? 16 : 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: widget.isEmbedded ? 100 : 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionTitle('GENERAL'),
              const SizedBox(height: 8),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.vibration,
                  title: 'Haptic Feedback',
                  value: _hapticFeedback,
                  onChanged: (val) => setState(() => _hapticFeedback = val),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('CAMERA'),
              const SizedBox(height: 8),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildIconContainer(Icons.layers),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Segmentation Sensitivity',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Adjust edge detection accuracy',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.primaryPurpleLight,
                          inactiveTrackColor:
                              AppTheme.primaryPurple.withOpacity(0.2),
                          thumbColor: AppTheme.primaryPurpleLight,
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16.0),
                        ),
                        child: Slider(
                          value: _segmentationSensitivity,
                          min: 0,
                          max: 2,
                          divisions: 2,
                          onChanged: (val) =>
                              setState(() => _segmentationSensitivity = val),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PRECISE',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            Text('STANDARD',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            Text('BROAD',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('EXPORT'),
              const SizedBox(height: 8),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.save,
                  title: 'Auto-Save to Gallery',
                  value: _autoSave,
                  onChanged: (val) => setState(() => _autoSave = val),
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.image,
                  title: 'Default Export Format',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('PNG',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 14)),
                          Text('(Lossless)',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          size: 20),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('ABOUT'),
              const SizedBox(height: 8),
              _buildCard([
                _buildTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  trailing: const Text('2.4.0 (Pro)',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.delete_outline,
                  title: 'Clear Cache',
                  titleColor: AppTheme.accentRed,
                  iconColor: AppTheme.accentRed,
                  iconBgColor: AppTheme.accentRed.withOpacity(0.1),
                  trailing: const Text('124 MB',
                      style:
                          TextStyle(color: AppTheme.accentRed, fontSize: 13)),
                ),
              ]),

              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'Rang • AI Color Segmentation Engine',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.primaryPurpleLight,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.08),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.primaryPurple.withOpacity(0.08),
      indent: 64,
      endIndent: 16,
    );
  }

  Widget _buildIconContainer(IconData icon,
      {Color? iconColor, Color? bgColor}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor ?? AppTheme.primaryPurple.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor ?? AppTheme.primaryPurpleLight,
        size: 20,
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    Color? titleColor,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildIconContainer(icon, iconColor: iconColor, bgColor: iconBgColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: titleColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildTile(
      icon: icon,
      title: title,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppTheme.primaryPurple,
        inactiveThumbColor: AppTheme.textSecondary,
        inactiveTrackColor: AppTheme.primaryPurple.withOpacity(0.2),
      ),
    );
  }
}
