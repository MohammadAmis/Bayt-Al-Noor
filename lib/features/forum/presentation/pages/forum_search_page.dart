import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_tokens.dart';

class ForumSearchPage extends ConsumerStatefulWidget {
  const ForumSearchPage({super.key});

  @override
  ConsumerState<ForumSearchPage> createState() => _ForumSearchPageState();
}

class _ForumSearchPageState extends ConsumerState<ForumSearchPage> {
  final _searchController = TextEditingController();
  int _activeTab = 0;
  final List<String> _tabs = ['Posts', 'Communities', 'Users', 'Tags'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildTabs(),
                  const SizedBox(height: 32),
                  _buildFilterChips(),
                  const SizedBox(height: 32),
                  _buildRecentSearches(),
                  const SizedBox(height: 32),
                  _buildTrendingSearches(),
                  const SizedBox(height: 32),
                  _buildTopResults(),
                  const SizedBox(height: 100), // Bottom nav padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                'Search',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCvfeJQEFaXb0NNPEfLczkPNAR-ZKqw-ZK2UmVUqFJ5g48o8gYDb3odykrhfz-d711lqPrwPz0HWmzbBvh8Y5YxgHqh0aKe-hFLSCnS9hDmU6JtD5d4JZP4SeB9n52se7C8BIQCKLTgrlWGJnnjYdrtxIu32GOA6AHnUBjtRIpgEeGbjGEFlBT5gh7ifXKB8iNooqCeMAe1RvJYCBJAx8PrtM79kqYtmzEmBdqjNn_WdA-hkYwq9zpjssBsBG0SXau-GUCWNvM6Tk0'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Search posts, communities, users...',
          hintStyle: TextStyle(color: const Color(0xFFBBCABF).withValues(alpha: 0.4)),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 20),
              ),
              Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.05)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded, color: AppColors.onSurfaceVariant, size: 20),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isActive = _activeTab == index;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = index),
            child: Container(
              padding: const EdgeInsets.only(bottom: 12, right: 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Post Type', 'icon': Icons.expand_more_rounded},
      {'label': 'Date', 'icon': Icons.expand_more_rounded},
      {'label': 'Community', 'icon': Icons.expand_more_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(f['label'] as String, style: const TextStyle(color: AppColors.onSurface, fontSize: 12)),
                const SizedBox(width: 4),
                Icon(f['icon'] as IconData, size: 16, color: AppColors.onSurface),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final recent = ['Quran interpretation', 'Halal travel tips'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Clear all', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recent.map((s) => Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 16),
                  Text(s, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                ],
              ),
              const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 18),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTrendingSearches() {
    final tags = ['#RamadanReady', '#FiqhQuestions', '#IslamicArt', '#CharityNetwork'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Searches',
          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              t,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTopResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Results',
          style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPostResult(
          'Spiritual Growth',
          '2h ago',
          'Finding peace through Quran interpretation and daily dhikr.',
          'Fatima Zahra',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCvyXKHF4vJ3T-vxfeB2JtnvexWe0oS176yO-sVXtou0ShBk2zzotI4v1SXw1LmZEPNccT2bgfx7Ki5A2D8_cq-G6JZERIgFB9DizMASPiC-dffmnExl03KCaDo5LlWKNpVEquHOtkerU2XrxPCzR7kJ6Rk6XKoNrCPs8gfEc0s0XPl0j8yT91XfVtyiUW78N7aoy2Chz3-3l-lvW188u3J1Sn-kl3nERxSifZ_MYndZX0SBBAzU88sbbSsO5GQTl2fIv8tnckl13U',
        ),
        const SizedBox(height: 16),
        _buildPostResult(
          'Lifestyle',
          '5h ago',
          'Essential Halal travel tips for navigating Europe this summer.',
          'Ibrahim K.',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDtHMtrW_ZtdTnZh4P17_XkpgFqlDEeBlJt_yJlZrESkcW6YL5bXgbY1h-WJvitnkrosFrMWHoi_04F2LW4ynhsmGiF6GS_3KZj_-q0r4Ad5Q19K4DRHyvjrChb8eslOReiw7Ur5knhUISqx8k4b86VMbMD1kKe4uPgf9OYVGWicBhGAY1x7aWz8W27nZioBN98nRo0d-Cv0K8oa8LpjGt17PVBe66g9XfyeKpp7IW2tZrxKAQv5Q9YP3GJsZJQ15-ahSdA4afh0cA',
        ),
      ],
    );
  }

  Widget _buildPostResult(String category, String time, String title, String author, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
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
                          category.toUpperCase(),
                          style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        Text(time, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, size: 12, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(author, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.favorite_outline_rounded, size: 18, color: AppColors.onSurfaceVariant),
                  SizedBox(width: 16),
                  Icon(Icons.bookmark_outline_rounded, size: 18, color: AppColors.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
