import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';

class UserProfilePage extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final String bio;

  const UserProfilePage({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.bio,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _dmEnabled = true;
  bool _mentorsEnabled = true;
  bool _readReceipts = false;
  bool get _isMobile => MediaQuery.of(context).size.width <= 768;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppTopBar(
          title: 'Profile',
          isMainScreen: false,
          location: '',
          onMenuPressed: () => Navigator.pop(context),
          onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _buildProfileIdentity(),
              ),
              SliverToBoxAdapter(
                child: _buildStatsRow(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: AppColors.surface.withValues(alpha:0.8),
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Reflections'),
                        Tab(text: 'Saved Verses'),
                        Tab(text: 'Chat Settings'),
                      ],
                      labelStyle: AppTypography.label.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle: AppTypography.label.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.onSurfaceVariant,
                      indicatorColor: AppColors.primary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: AppColors.outlineVariant.withValues(alpha:0.1),
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _buildReflectionsTab(),
                _buildSavedVersesTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabIndex = DefaultTabController.of(context).index;
            return tabIndex == 0 ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.note_add, color: Colors.white),
            ) : const SizedBox.shrink();
          }
        ),
      ),
    );
  }


  Widget _buildProfileIdentity() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerLowest, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  image: DecorationImage(
                    image: NetworkImage(widget.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            widget.name,
            style: AppTypography.headline.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.bio,
            style: AppTypography.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'MEMBER SINCE RAMADAN 2023',
              style: AppTypography.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          _buildStatCard('42', 'Reflections'),
          const SizedBox(width: 16),
          _buildStatCard('128', 'Saved Verses'),
          const SizedBox(width: 16),
          _buildStatCard('12', 'Day Streak', isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  value,
                  style: AppTypography.headline.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                if (isHighlight) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildReflectionCard(
          surahRef: 'SURAH AL-BAQARAH 2:153',
          timestamp: 'Yesterday at 6:42 PM',
          verse: '“O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.”',
          note: 'This verse reminds me to slow down when things get overwhelming. Patience isn\'t just waiting; it\'s active trust.',
        ),
        const SizedBox(height: 24),
        _buildReflectionCard(
          surahRef: 'SURAH AR-RA\'D 13:28',
          timestamp: 'Oct 12, 2023',
          verse: '“Unquestionably, by the remembrance of Allah hearts are assured.”',
          note: 'Finding peace in dhikr during the morning commute today. The commute felt shorter and more purposeful.',
        ),
        const SizedBox(height: 120), // Bottom padding for FAB
      ],
    );
  }

  Widget _buildReflectionCard({
    required String surahRef,
    required String timestamp,
    required String verse,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
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
                    surahRef,
                    style: AppTypography.label.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.more_horiz, color: AppColors.outlineVariant, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            verse,
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              note,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: AppColors.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedVersesTab() {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: _isMobile ? 1 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildVerseGridCard(
          quote: '“Verily, with every hardship comes ease.”',
          ref: 'SURAH ASH-SHARH 94:6',
        ),
        _buildVerseGridCard(
          quote: '“And He is with you wherever you are.”',
          ref: 'SURAH AL-HADID 57:4',
        ),
        _buildVerseGridCard(
          quote: '“My Lord, increase me in knowledge.”',
          ref: 'SURAH TAHA 20:114',
        ),
        _buildVerseGridCard(
          quote: '“He found you lost and guided you.”',
          ref: 'SURAH AD-DUHA 93:7',
        ),
      ],
    );
  }

  Widget _buildVerseGridCard({required String quote, required String ref}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_quote, color: AppColors.primary.withValues(alpha:0.1), size: 32),
          const SizedBox(height: 12),
          Text(
            quote,
            style: AppTypography.headline.copyWith(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Text(
            ref,
            style: AppTypography.label.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Privacy & Preferences',
          style: AppTypography.headline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        _buildSettingToggle('Community DMs', _dmEnabled, (v) => setState(() => _dmEnabled = v)),
        const SizedBox(height: 16),
        _buildSettingToggle('Spiritual Mentors', _mentorsEnabled, (v) => setState(() => _mentorsEnabled = v)),
        const SizedBox(height: 16),
        _buildSettingToggle('Read Receipts', _readReceipts, (v) => setState(() => _readReceipts = v)),
        const SizedBox(height: 48),
        _buildSettingButton(Icons.notifications, 'Prayer Reminders'),
        const SizedBox(height: 12),
        _buildSettingButton(Icons.security, 'Security Settings'),
        const SizedBox(height: 12),
        _buildSettingButton(Icons.logout, 'Sign Out', color: AppColors.error),
      ],
    );
  }

  Widget _buildSettingToggle(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryFixed,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha:0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.onSurface),
          const SizedBox(width: 16),
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.onSurface,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48.0;
  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
