import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/pages/public_profile_page.dart';
import 'chat_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _activeFilter = 'All Messages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Community',
        isMainScreen: true,
        location: 'Community',
        onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        onProfilePressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserProfilePage(
              name: 'Fatima Al-Sayed',
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y',
              bio: 'Seeking tranquility through reflection and prayer.',
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Above bottom nav
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0x00001156)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.edit_square, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _chatSearchBar(),

            const SizedBox(height: 16),

            // Category Filter Chips
            _buildFilterChips(),

            const SizedBox(height: 16),

            // Chat List Section
            _buildChatList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _chatSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Chat, Group',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.outline,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All Messages', 'Groups', 'Private', 'Pinned'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          bool isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                filter,
                style: AppTypography.label.copyWith(
                  color: isActive
                      ? AppColors.onPrimaryFixed
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isActive,
              onSelected: (val) => setState(() => _activeFilter = filter),
              selectedColor: AppColors.primaryFixed,
              backgroundColor: AppColors.surfaceContainerHigh,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _ChatItem(
            title: 'Amir Al-Hussein',
            subtitle:
                'As-salamu alaykum. I was reflecting on the beauty of patience...',
            time: '10:42 AM',
            unreadCount: 1,
            isPinned: true,
            leading: _buildImageAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBCJK2wMGg9gMZiUvgQIGnRElk5TNAbyKemys1O17W0kXuyhkl5XylevUyfHrTa9Hop7ubE0lFzqujFUp-j_ZYjFAON2i72aSzYlVsv6h3TvC0D2Ft7KsWAwB8zGVZkE5mWCPcNtirz2RUxCbbbSVxXqirYVkoLN3CIPW-sK6jShiDfrDvRVpFGp9Wjf3IZ_jfBIGsQQCqIGgP5M7JPxAoJ8fxmeiM7Do8heijs_p03yjZw2Vu9gEgK2PlhDPEi-khNkk6FpnaG9Kw'),
            statusColor: Colors.green,
          ),
          const Divider(height: 1, indent: 80, endIndent: 20),
          _ChatItem(
            title: 'Zaid Al-Farsi',
            subtitle:
                'Assalamu alaikum brothers, I have shared a new reflection on Niyyah.',
            time: 'Just now',
            unreadCount: 1,
            leading: _buildImageAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD5y5gtsOjbBE7LbpvBfmKo8fZbKpZceBr0xFGR0rtDEEJAApzvFsfTtlRsyDGWr1vejenevOOo5AwgE3rQMBgeMtixBRqZNDyBXgTcSFsSI-8zrCW6dlZOVLd_0IZlq0kPXX1Z1YFIek_74QK8Oc_mFSA_6SZyUD6lyZE2ozMCWdrunixdrW7uJrZVgPDkZjrsnegc30nHs5E9ZwRrql9KXHQaoNp-OaAAYCLzDIj-jdso_uFAHiuDODph3Mm0Jwiwwa_dTYSTtzE'),
            statusColor: Colors.green,
          ),
          const Divider(height: 1, indent: 80, endIndent: 20),
          _ChatItem(
            title: 'Quran Study Group',
            subtitle:
                'Zainab: Shall we meet at 7 PM tonight for the Juz 3 review?',
            time: '09:12 AM',
            unreadCount: 3,
            isPinned: true,
            leading: _buildInitialAvatar('QS', AppColors.secondaryFixedDim),
            statusColor: Colors.teal,
          ),
          const Divider(height: 1, indent: 80, endIndent: 20),
          _ChatItem(
            title: 'Sister Mariam',
            subtitle:
                'Wa alaikum assalam! I will bring the dates for iftar tomorrow.',
            time: 'Yesterday',
            leading: _buildImageAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBHXWnkXZZT3gdd5bW7wsGccUqDoIWY2okS_C5BWVYncX1Pia9nlZ3bNUgSVRAzxwUt7z6_tkauDcYZ5RKkoIHU4Hr50CIzGawrB3QSFxnlvkdCBX4Ye-lXA0bQ8Aig_cvWrF4iz-_06i74ipNdxQHYIR62txEAhmcNPpvDn2RD5Q5Kejg6Gcnym-VtVcdRZPErY65IW_ZUGih0fNrFJKt1jTT3Hv837t-YHtL43np5gSjOD3gWi0mMMlnWOttesa338u_heq5EmSU'),
          ),
          const Divider(height: 1, indent: 80, endIndent: 20),
          _ChatItem(
            title: 'Local Community',
            subtitle:
                'Omar: The mosque parking is currently full, please use the side street.',
            time: 'Yesterday',
            unreadCount: 12,
            leading:
                _buildIconAvatar(Icons.location_on, AppColors.primaryFixedDim),
          ),
          const Divider(height: 1, indent: 80, endIndent: 20),
          _ChatItem(
            title: 'Brother Yusuf',
            subtitle: 'JazakAllah Khair for the book recommendation, brother.',
            time: 'Mon',
            leading: _buildImageAvatar(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAnWaoO6PooHAHdfMpBORR3PqOU6B976ECu0B6uesYPLBDPQPrkqq8nA1rlrkAUlB9pw3brb6m7TtNNwNhgqDSbWnAGIT4PtQcG5VFqDzL5w-sjXMrXt4DZlhp_3rp3DfrUZAHvuxWrCFmSD-nme_wWTtfnSn28Jk7EQQcAaz0l2wvht7MAPHo_hGXOkzzvatUH-IeTCJ_oNgQ_xZ6xhFFxwNTxAad36_Fl8kff_oo8OxU_z0l196qss0GlnzYFMEAZEqIsSDBT3VE'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String text, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: AppColors.onSecondaryFixedVariant,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildImageAvatar(String url) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildIconAvatar(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.onPrimaryFixed, size: 28),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool isPinned;
  final Widget leading;
  final Color? statusColor;

  const _ChatItem({
    required this.title,
    required this.subtitle,
    required this.time,
    this.unreadCount = 0,
    this.isPinned = false,
    required this.leading,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (title == 'Amir Al-Hussein') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatPage(
                type: ChatType.private,
                title: 'Amir Al-Hussein',
                subtitle: 'ACTIVE NOW',
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBCJK2wMGg9gMZiUvgQIGnRElk5TNAbyKemys1O17W0kXuyhkl5XylevUyfHrTa9Hop7ubE0lFzqujFUp-j_ZYjFAON2i72aSzYlVsv6h3TvC0D2Ft7KsWAwB8zGVZkE5mWCPcNtirz2RUxCbbbSVxXqirYVkoLN3CIPW-sK6jShiDfrDvRVpFGp9Wjf3IZ_jfBIGsQQCqIGgP5M7JPxAoJ8fxmeiM7Do8heijs_p03yjZw2Vu9gEgK2PlhDPEi-khNkk6FpnaG9Kw',
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatPage(
                type: ChatType.community,
                title: 'Sacred Rhythm',
                subtitle: 'COMMUNITY CIRCLE',
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    final isZaid = title == 'Zaid Al-Farsi';
                    String avatar =
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAnWaoO6PooHAHdfMpBORR3PqOU6B976ECu0B6uesYPLBDPQPrkqq8nA1rlrkAUlB9pw3brb6m7TtNNwNhgqDSbWnAGIT4PtQcG5VFqDzL5w-sjXMrXt4DZlhp_3rp3DfrUZAHvuxWrCFmSD-nme_wWTtfnSn28Jk7EQQcAaz0l2wvht7MAPHo_hGXOkzzvatUH-IeTCJ_oNgQ_xZ6xhFFxwNTxAad36_Fl8kff_oo8OxU_z0l196qss0GlnzYFMEAZEqIsSDBT3VE';

                    final leadingWidget = leading;
                    if (leadingWidget is Container &&
                        leadingWidget.decoration is BoxDecoration) {
                      final decoration =
                          leadingWidget.decoration as BoxDecoration;
                      if (decoration.image != null &&
                          decoration.image!.image is NetworkImage) {
                        avatar = (decoration.image!.image as NetworkImage).url;
                      }
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicProfilePage(
                          name: title,
                          avatarUrl: avatar,
                          bio: isZaid
                              ? 'Seeking wisdom through the words of the Sahaba. Enthusiastic about Islamic history and community service.'
                              : '"Seeking tranquility in the rhythm of prayer and the wisdom of the word."',
                          reflectionsCount: isZaid ? 156 : 12,
                          followersCount: isZaid ? 89 : 45,
                          followingCount: isZaid ? 12 : 30,
                        ),
                      ),
                    );
                  },
                  child: leading,
                ),
                if (statusColor != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.headline.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        time,
                        style: AppTypography.label.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.body.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unreadCount > 0 || isPinned) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (isPinned) ...[
                    const SizedBox(height: 4),
                    const Icon(Icons.push_pin,
                        size: 14, color: AppColors.outline),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
