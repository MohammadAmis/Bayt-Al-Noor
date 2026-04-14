import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedMethod = 'MWL (Muslim World League)';
  bool _isHanafi = true;
  bool _is12h = true;
  bool _sacredAlerts = true;
  final String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Bayt Al-Noor',
        subtitle: 'بَيْتُ النُّورِ',
        location: 'London, UK',
        leadingIcon: Icons.arrow_back,
        onMenuPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sanctuary Settings',
                  style: AppTypography.display.copyWith(
                    fontSize: 36,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Configure your personal spiritual hub and prayer preferences.',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Location Section
            _buildSectionHeader('YOUR LOCATION'),
            const SizedBox(height: 16),
            _buildLocationCard(),

            const SizedBox(height: 40),

            // Spiritual Path Section
            _buildSectionHeader('SPIRITUAL PATH'),
            const SizedBox(height: 16),
            _buildModernSettingsCard([
              _buildSettingRow(
                icon: Icons.auto_awesome,
                title: 'Calculation Method',
                subtitle: _selectedMethod,
                trailing: const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.outline),
                onTap: () => _showMethodPicker(),
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.menu_book,
                title: 'Madhhab (School of Thought)',
                subtitle: _isHanafi ? 'Hanafi' : 'Shafi / Others',
                trailing: const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.outline),
                onTap: () {
                  setState(() => _isHanafi = !_isHanafi);
                },
              ),
            ]),

            const SizedBox(height: 40),

            // App Experience Section
            _buildSectionHeader('SACRED EXPERIENCE'),
            const SizedBox(height: 16),
            _buildModernSettingsCard([
              _buildSettingRow(
                icon: Icons.brightness_medium,
                title: 'Theme preference',
                subtitle: 'Sacred Light',
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: AppShapes.fullRadius,
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTypography.label.copyWith(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onPrimaryFixedVariant,
                    ),
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.schedule,
                title: '24-Hour Time Format',
                trailing: Switch.adaptive(
                  value: !_is12h,
                  onChanged: (val) => setState(() => _is12h = !val),
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.notifications_active,
                title: 'Sacred Alerts',
                subtitle: 'Prayer and reflection reminders',
                trailing: Switch.adaptive(
                  value: _sacredAlerts,
                  onChanged: (val) => setState(() => _sacredAlerts = val),
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.language,
                title: 'App Language',
                subtitle: _selectedLanguage,
                trailing: const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.outline),
                onTap: () {
                  // Language logic
                },
              ),
            ]),

            const SizedBox(height: 48),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showSignOutDialog(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppColors.error.withValues(alpha: 0.05),
                  shape:
                      RoundedRectangleBorder(borderRadius: AppShapes.lgRadius),
                ),
                child: Text(
                  'SIGN OUT FROM Bayt-Al-Noor',
                  style: AppTypography.label.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
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
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.secondary.withValues(alpha: 0.8),
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppShapes.xlRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Mock Map Preview
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB5G4rxSNb2ORAuBFu4CYE--nNEpN9AUjYf-sCFLtIk020rnpgOtV9n9XzCMWG0YRwgohc30xHogyiUVBJcYD0aJFjtexxLHtoEOd1GxUideoGdpUJ_6qznFrTj5Xi1t9OTFTmJmMBRCT6iECf9RiNa9xFv07vj5ALMsh5tve9FE7mTZyKfvBzx968eyML-mFzGnUoW7X63iBinGu5OgcZzSIJGKm1vL3MYiGZo6kOmjVUnDWQMqu6gf-56hL2SqbKH3lAfzBThD4w'),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'London, United Kingdom',
                        style: AppTypography.title.copyWith(fontSize: 18),
                      ),
                      Text(
                        '51.5074° N, 0.1278° W',
                        style: AppTypography.body.copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppShapes.xlRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.xlRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppShapes.lgRadius,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null)
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
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 20,
      color: AppColors.surfaceContainerLow,
    );
  }

  void _showMethodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: AppShapes.fullRadius,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Calculation Methods',
                style: AppTypography.headline.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 24),
              ...[
                'MWL (Muslim World League)',
                'ISNA',
                'Egypt',
                'Umm Al-Qura',
                'Karachi'
              ].map((method) {
                bool isSelected = _selectedMethod == method;
                return ListTile(
                  title: Text(method, style: AppTypography.body),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedMethod = method);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out',
          style: AppTypography.headline
              .copyWith(fontSize: 24, color: AppColors.primary),
        ),
        content: Text(
          'Are you sure you want to leave your sanctuary? You will need to sign in again to access your preferences.',
          style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'STAY',
              style: AppTypography.label.copyWith(
                  color: AppColors.outline, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'SIGN OUT',
              style: AppTypography.label
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
