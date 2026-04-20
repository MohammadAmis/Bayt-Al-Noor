import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../data/services/tasbih_service.dart';

class TasbihSettingsPage extends StatefulWidget {
  const TasbihSettingsPage({super.key});

  @override
  State<TasbihSettingsPage> createState() => _TasbihSettingsPageState();
}

class _TasbihSettingsPageState extends State<TasbihSettingsPage> {
  final _service = TasbihService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppTopBar(
        title: 'TASBIH SETTINGS',
        location: 'PREFERENCES',
        isMainScreen: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('VISUAL STYLE'),
            const SizedBox(height: 16),
            _buildThemeSelector(),
            const SizedBox(height: 32),

            _buildSectionHeader('LANGUAGE & DISPLAY'),
            const SizedBox(height: 16),
            _buildLanguageCard(),
            const SizedBox(height: 32),

            _buildSectionHeader('SENSORY & AUDIO'),
            const SizedBox(height: 16),
            _buildSensoryCard(),
            const SizedBox(height: 32),

            _buildSectionHeader('RITUAL ALERTS'),
            const SizedBox(height: 16),
            _buildRitualsCard(),
            
            const SizedBox(height: 48),
            
            // Footer Info
            Center(
              child: Text(
                'Personalize your spiritual focus.',
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.label.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        fontSize: 10,
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      children: [
        Expanded(
          child: _ThemePreviewCard(
            title: 'Modern Orb',
            subtitle: 'Celestial focus',
            isSelected: _service.counterStyle == CounterStyle.orb,
            onTap: () => _service.setCounterStyle(CounterStyle.orb),
            icon: Icons.auto_awesome,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ThemePreviewCard(
            title: 'Classic Beads',
            subtitle: 'Traditional feel',
            isSelected: _service.counterStyle == CounterStyle.beads,
            onTap: () => _service.setCounterStyle(CounterStyle.beads),
            icon: Icons.grain,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLangModeItem('Arabic', LanguageMode.arabic),
              const SizedBox(width: 8),
              _buildLangModeItem('English', LanguageMode.english),
            ],
          ),
          if (_service.languageMode == LanguageMode.english) ...[
            const Divider(height: 32, thickness: 0.5),
            _buildToggleRow(
              'Transliteration',
              'English phonetic reading',
              _service.isTransliterationVisible,
              (val) => _service.toggleTransliteration(val),
            ),
            const Divider(height: 32, thickness: 0.5),
            _buildToggleRow(
              'Translation',
              'English meaning',
              _service.isTranslationVisible,
              (val) => _service.toggleTranslation(val),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLangModeItem(String label, LanguageMode mode) {
    bool isSelected = _service.languageMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _service.setLanguageMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensoryCard() {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haptic Intensity',
                    style: AppTypography.title.copyWith(fontSize: 14),
                  ),
                  Text(
                    'Vibration strength on tap',
                    style: AppTypography.body.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                '${(_service.hapticIntensity * 100).toInt()}%',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _service.hapticIntensity,
            onChanged: (val) => _service.setHapticIntensity(val),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
          const Divider(height: 32, thickness: 0.5),
          _buildSoundSelector(),
        ],
      ),
    );
  }

  Widget _buildSoundSelector() {
    final profiles = ['None', 'Click', 'Water Drop', 'Celestial Pulse'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sound Profile',
          style: AppTypography.title.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: profiles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final isSelected = _service.selectedSoundProfile == profile;
              return GestureDetector(
                onTap: () => _service.setSoundProfile(profile),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      profile,
                      style: AppTypography.label.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
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

  Widget _buildRitualsCard() {
    return BentoCard(
      child: Column(
        children: [
           _buildToggleRow(
            'Landmark Vibrations',
            'Vibrate at 33, 66, and 99',
            true, // Simulated for now
            (val) {},
          ),
          const Divider(height: 32, thickness: 0.5),
          _buildToggleRow(
            'Auto-Series Switch',
            'Move to next Dhikr at goal',
            _service.isSeriesMode,
            (val) => _service.toggleSeriesMode(val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.title.copyWith(fontSize: 14),
              ),
              Text(
                subtitle,
                style: AppTypography.body.copyWith(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _ThemePreviewCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: AppShapes.lgRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.title.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
