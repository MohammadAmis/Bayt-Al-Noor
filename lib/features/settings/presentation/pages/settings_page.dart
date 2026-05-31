import 'package:bayt_al_noor/core/providers/services_provider.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/common_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/design_tokens.dart';
import '../../../../../core/providers/connectivity_provider.dart';
import '../../providers/settings_providers.dart';
import '../widgets/location_setting_tile.dart';
import '../dialogs/calculation_method_dialog.dart';
import '../dialogs/location_input_dialog.dart';
import '../../providers/location_providers.dart';
import '../../../../../core/providers/app_preferences_provider.dart';
import '../../../circle/data/providers/chat_providers.dart';
import '../widgets/rescheduling_status_banner.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectivityProvider).value ?? true;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final notificationOffset = ref.watch(notificationOffsetProvider);
    final notificationSound = ref.watch(notificationSoundProvider);
    final calculationMethod = ref.watch(calculationMethodProvider);
    final useAutoLocation = ref.watch(useAutoLocationProvider);
    final manualLocationName = ref.watch(manualLocationNameProvider);
    final isHanafi = ref.watch(isHanafiProvider);
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Settings',
        isMainScreen: false,
        location: '', // Not used for SubScreen
        onSettingsPressed: () {}, // Already on settings
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isConnected) _OfflineBanner(),
            const SizedBox(height: 4),
            const ReschedulingStatusBanner(),

            // ── Notifications ──
            const _SectionHeader(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              color: Color(0xFF1565C0),
            ),
            _SettingsCard(
              children: [
                _PremiumToggleTile(
                  title: 'Prayer Alerts',
                  subtitle: 'Get notified before each prayer',
                  value: notificationsEnabled,
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFF1565C0),
                  onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).toggle(v),
                ),
                if (notificationsEnabled) ...[
                  _Divider(),
                  _PremiumSliderTile(
                    title: 'Alert Timing',
                    subtitle: '$notificationOffset minutes before prayer',
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xFF1565C0),
                    value: notificationOffset.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 12,
                    label: '$notificationOffset min',
                    onChanged: (v) => ref.read(notificationOffsetProvider.notifier).update(v.round()),
                  ),
                  _Divider(),
                  _PremiumToggleTile(
                    title: 'Notification Sound',
                    subtitle: 'Play sound with alerts',
                    value: notificationSound,
                    icon: Icons.volume_up_rounded,
                    iconColor: const Color(0xFF1565C0),
                    onChanged: (v) => ref.read(notificationSoundProvider.notifier).toggle(v),
                  ),
                ],
              ],
            ),

            // ── Prayer Times ──
            const _SectionHeader(
              icon: Icons.mosque_rounded,
              title: 'Prayer Times',
              color: AppColors.primary,
            ),
            _SettingsCard(
              footer: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  'Different regions use different calculation methods. Choose the one recommended for your location.',
                  style: AppTypography.label.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ),
              children: [
                _PremiumNavTile(
                  title: 'Calculation Method',
                  subtitle: calculationMethod.displayName,
                  icon: Icons.calculate_rounded,
                  iconColor: AppColors.primary,
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const CalculationMethodDialog(),
                  ),
                ),
                _Divider(),
                _PremiumToggleTile(
                  title: 'Hanafi Madhab',
                  subtitle: 'Alternate Asr calculation',
                  value: isHanafi,
                  icon: Icons.history_edu_rounded,
                  iconColor: AppColors.primary,
                  onChanged: (v) => ref.read(isHanafiProvider.notifier).toggle(v),
                ),
              ],
            ),

            // ── Location ──
            const _SectionHeader(
              icon: Icons.location_on_rounded,
              title: 'Location',
              color: Color(0xFF2E7D32),
            ),
            _SettingsCard(
              children: [
                _PremiumToggleTile(
                  title: 'Auto-Detect Location',
                  subtitle: useAutoLocation ? 'Using GPS for accurate times' : 'Manual location active',
                  value: useAutoLocation,
                  icon: useAutoLocation ? Icons.my_location_rounded : Icons.pin_drop_rounded,
                  iconColor: const Color(0xFF2E7D32),
                  onChanged: (useAuto) async {
                    try {
                      ref.read(useAutoLocationProvider.notifier).toggle(useAuto);
                      if (useAuto) {
                        final permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          await Geolocator.requestPermission();
                        }
                        ref.read(locationManagerProvider.notifier).refresh();
                      }
                    } catch (error) {
                      debugPrint('Error toggling location: $error');
                    }
                  },
                ),
                _Divider(),
                locationAsync.maybeWhen(
                  data: (location) => LocationSettingTile(
                    locationName: useAutoLocation
                        ? (location?.address ?? 'Detecting...')
                        : manualLocationName,
                    coordinates: useAutoLocation
                        ? (location != null
                            ? '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'
                            : null)
                        : null,
                    isAuto: useAutoLocation,
                    isLoading: locationAsync.isLoading,
                    onRefresh: useAutoLocation
                        ? () => ref.read(locationManagerProvider.notifier).refresh()
                        : null,
                    onEdit: !useAutoLocation
                        ? () => showDialog(
                              context: context,
                              builder: (_) => LocationInputDialog(
                                initialLocation: manualLocationName,
                                onSave: (val) {
                                  ref.read(manualLocationNameProvider.notifier).update(val);
                                },
                              ),
                            )
                        : null,
                  ),
                  orElse: () => LocationSettingTile(
                    locationName: useAutoLocation ? 'Fetching location...' : manualLocationName,
                    isAuto: useAutoLocation,
                    isLoading: locationAsync.isLoading,
                    onRefresh: useAutoLocation
                        ? () => ref.read(locationManagerProvider.notifier).refresh()
                        : null,
                  ),
                ),
              ],
            ),

            // ── App Preferences ──
            const _SectionHeader(
              icon: Icons.palette_rounded,
              title: 'App Preferences',
              color: Color(0xFF6A1B9A),
            ),
            _SettingsCard(
              children: [
                _PremiumDropdownTile<ThemeMode>(
                  title: 'Theme',
                  subtitle: 'Light, dark, or system default',
                  icon: Icons.brightness_6_rounded,
                  iconColor: const Color(0xFF6A1B9A),
                  value: ref.watch(themeModeProvider),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeModeProvider.notifier).update(mode);
                  },
                ),
                _Divider(),
                _PremiumToggleTile(
                  title: 'Arabic Names',
                  subtitle: 'Display prayer names in Arabic script',
                  value: ref.watch(showArabicNamesProvider),
                  icon: Icons.translate_rounded,
                  iconColor: const Color(0xFF6A1B9A),
                  onChanged: (v) => ref.read(showArabicNamesProvider.notifier).toggle(v),
                ),
                _Divider(),
                _PremiumToggleTile(
                  title: 'Hijri Date',
                  subtitle: 'Show Islamic calendar dates',
                  value: ref.watch(showHijriDateProvider),
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF6A1B9A),
                  onChanged: (v) => ref.read(showHijriDateProvider.notifier).toggle(v),
                ),
              ],
            ),

            // ── Data & Privacy ──
            const _SectionHeader(
              icon: Icons.shield_rounded,
              title: 'Data & Privacy',
              color: Color(0xFFC62828),
            ),
            _SettingsCard(
              children: [
                _PremiumNavTile(
                  title: 'Clear Cached Data',
                  subtitle: 'Remove stored prayer times and location cache',
                  icon: Icons.delete_sweep_rounded,
                  iconColor: const Color(0xFFC62828),
                  trailingIcon: Icons.chevron_right_rounded,
                  onTap: () => _showClearDataDialog(context, ref),
                ),
                _Divider(),
                _PremiumNavTile(
                  title: 'Privacy Policy',
                  subtitle: 'View our data practices',
                  icon: Icons.privacy_tip_rounded,
                  iconColor: AppColors.primary,
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () => _openPrivacyPolicy(context),
                ),
                _Divider(),
                _PremiumNavTile(
                  title: 'Sign Out',
                  subtitle: 'Log out of your account',
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  trailingIcon: Icons.chevron_right_rounded,
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),

            // ── Footer ──
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppShapes.fullRadius,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mosque_rounded, size: 14, color: AppColors.primary.withValues(alpha: 0.6)),
                        const SizedBox(width: 8),
                        Text(
                          'Bayt Al-Noor  ·  v1.0.0',
                          style: AppTypography.label.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Built with ❤️ for the Ummah',
                    style: AppTypography.label.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: AppShapes.xlRadius),
        title: Text('Clear Cached Data?', style: AppTypography.title.copyWith(color: AppColors.onSurface)),
        content: Text(
          'This will remove stored prayer times and reset location cache. Your account and settings will remain.',
          style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.label.copyWith(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              shape: RoundedRectangleBorder(borderRadius: AppShapes.fullRadius),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/MohammadAmis/Bayt-Al-Noor/blob/main/PRIVACY.md');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy policy')),
        );
      }
    }
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      await ref.read(supabaseServiceProvider).signOut(repo);
      if (context.mounted) {
        // Clear navigation stack and go to login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
// Private layout helpers (visual only)
// ─────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: AppShapes.lgRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_rounded, size: 16, color: AppColors.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline — some settings may not sync',
              style: AppTypography.label.copyWith(color: AppColors.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Widget? footer;

  const _SettingsCard({required this.children, this.footer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppShapes.lgRadius,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.outlineVariant.withValues(alpha: 0.6),
      indent: 56,
      endIndent: 16,
    );
  }
}

class _PremiumToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<bool> onChanged;

  const _PremiumToggleTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppShapes.lgRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.title.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14,
                      )),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTypography.label.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        )),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: iconColor,
              inactiveThumbColor: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumNavTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _PremiumNavTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailingIcon = Icons.chevron_right_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.lgRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.title.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14,
                      )),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTypography.label.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        )),
                ],
              ),
            ),
            Icon(trailingIcon, size: 18, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _PremiumSliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const _PremiumSliderTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: AppTypography.title.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 14,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: AppShapes.fullRadius,
                      ),
                      child: Text(label,
                          style: AppTypography.label.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          )),
                    ),
                  ],
                ),
                Text(subtitle,
                    style: AppTypography.label.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    )),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: iconColor,
                    thumbColor: iconColor,
                    inactiveTrackColor: iconColor.withValues(alpha: 0.2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: label,
                    onChanged: onChanged,
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

class _PremiumDropdownTile<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PremiumDropdownTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.title.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 14,
                    )),
                Text(subtitle,
                    style: AppTypography.label.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppShapes.lgRadius,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                items: items,
                onChanged: onChanged,
                isDense: true,
                style: AppTypography.label.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                icon: const Icon(Icons.unfold_more_rounded, size: 14, color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}