import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../widgets/prayer_status_card.dart';
import '../widgets/milestone_grid.dart';
import '../widgets/real_time_prayer_clock.dart';
import '../widgets/current_prayer_header.dart';
import '../widgets/bento_timetable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/prayer_data_provider.dart';
import '../../../../core/providers/services_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../prayer_times/providers/active_window_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../features/settings/providers/location_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _getAmPm(DateTime time) {
    return DateFormat('a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final activeWindow = ref.watch(activePrayerWindowProvider);
    final currentUser = ref.watch(currentUserProvider);
    final prayerDataAsync = ref.watch(prayerDataProvider);
    final isConnected = ref.watch(connectivityProvider).value ?? true;
    final locationAsync = ref.watch(locationProvider);

    return prayerDataAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        final errorString = error.toString().toLowerCase();
        final isLocationError = errorString.contains('location') ||
            errorString.contains('permission');
        final isNetworkError =
            errorString.contains('socket') || errorString.contains('timeout');

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      isLocationError
                          ? Icons.location_off_rounded
                          : isNetworkError
                              ? Icons.wifi_off_rounded
                              : Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 56),
                  const SizedBox(height: 16),
                  Text(
                    isLocationError
                        ? 'Location Access Required'
                        : isNetworkError
                            ? 'Connection Issue'
                            : 'Unable to Load Prayer Times',
                    style: AppTypography.title
                        .copyWith(color: AppColors.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLocationError
                        ? 'Enable location services in Settings to get accurate prayer times.'
                        : isNetworkError
                            ? 'Check your internet connection and try again.'
                            : 'Please try again in a moment.',
                    style: AppTypography.body
                        .copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(prayerDataProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppShapes.fullRadius),
                    ),
                  ),
                  if (isLocationError) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => Geolocator.openLocationSettings(),
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text('Open Settings'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      data: (data) {
        final nextPrayer = data.prayerTimes.nextPrayer();
        final upcomingPrayerName = nextPrayer == Prayer.none
            ? 'Fajr'
            : _getPrayerDisplayName(nextPrayer);

        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.surface,
          appBar: AppTopBar(
            isMainScreen: true,
            location: locationAsync.maybeWhen(
              data: (loc) => loc?.displayAddress ?? 'Unknown',
              orElse: () => data.cityName,
            ),
            onProfilePressed: () => context.push(
              '/profile',
              extra: {
                'name': currentUser?.userMetadata?['full_name'] ?? 'Guest',
                'avatarUrl': currentUser?.userMetadata?['avatar_url'] ??
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
                'bio': 'Seeking tranquility through reflection and prayer.',
                'userId': currentUser?.id,
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(refreshLocationProvider)();
              ref.invalidate(prayerDataProvider);
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  if (!isConnected)
                    Container(
                      color: AppColors.tertiaryContainer,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.offline_bolt_rounded,
                              size: 16, color: AppColors.onTertiaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Offline mode - showing cached times',
                            style: AppTypography.label
                                .copyWith(color: AppColors.onTertiaryContainer),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Dynamic Header
                        CurrentPrayerHeader(
                          date:
                              DateFormat('EEEE, d MMM').format(DateTime.now()),
                          prayerName: activeWindow.displayName,
                          time: _formatTime(activeWindow.startTime),
                          amPm: _getAmPm(activeWindow.startTime),
                          windowType: activeWindow.windowType,
                        ),

                        const SizedBox(height: 16),

                        // Next Prayer Card
                        PrayerStatusCard(
                          nextPrayerName: upcomingPrayerName,
                          nextPrayer: nextPrayer,
                          prayerTime:
                              data.prayerTimes.timeForPrayer(nextPrayer) ??
                                  DateTime.now(),
                          showNotificationToggle: true,
                        ),

                        const SizedBox(height: 16),

                        RealTimePrayerClock(prayerTimes: data.prayerTimes),

                        const SizedBox(height: 16),

                        // Unified Data Grid
                        MilestoneGrid(prayerTimes: data.prayerTimes),

                        const SizedBox(height: 32),

                        // Bento Timetable with real data
                        BentoTimetable(
                          prayerTimes: data.prayerTimes,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // ✅ Riverpod auto-cancels subscriptions, but good practice to document
    // If you add controllers later (AnimationController, TextEditingController):
    // _myController.dispose();
    super.dispose();
  }

  String _getPrayerDisplayName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return 'Fajr Preparations';
    }
  }
}
