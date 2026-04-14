import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../../../../core/design_tokens.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../widgets/prayer_status_card.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/milestone_grid.dart';
import '../widgets/real_time_prayer_clock.dart';
import '../widgets/current_prayer_header.dart';
import '../widgets/bento_timetable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _prayerService = PrayerService.instance;
  final _supabaseService = SupabaseService.instance;

  PrayerTimes? _prayerTimes;
  String _cityName = 'Loading...';
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initPrayerData();
    // Start a timer to refresh the UI every minute for the countdown
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initPrayerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No user found');

      // 1. Fetch Profile Preferences
      final profile = await _supabaseService.getUserProfile(user.id);
      final methodStr = profile?['calculation_method'] as String?;
      final madhhabStr = profile?['madhhab'] as String?;
      
      final calculationMethod = _prayerService.parseCalculationMethod(methodStr);
      final madhab = _prayerService.parseMadhab(madhhabStr);

      // 2. Get Location
      final position = await _prayerService.getCurrentPosition();
      final lat = position?.latitude ?? profile?['latitude'] ?? 51.5074;
      final lon = position?.longitude ?? profile?['longitude'] ?? -0.1278;

      // 3. Calculate Times
      final times = await _prayerService.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: calculationMethod,
        madhab: madhab,
      );

      // 4. Get City Name
      final city = await _prayerService.getCityName(lat, lon);

      // 5. Update Profile with fresh location if improved
      if (position != null) {
        await _supabaseService.updateUserProfile(
          userId: user.id,
          latitude: lat,
          longitude: lon,
        );
      }

      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _cityName = city;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _getAmPm(DateTime time) {
    return DateFormat('a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              const Text('Peace be upon you.\nWe encountered an error loading your timings.', textAlign: TextAlign.center),
              TextButton(onPressed: _initPrayerData, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final currentPrayer = _prayerTimes!.currentPrayer();
    final nextPrayer = _prayerTimes!.nextPrayer();
    
    // SPIRITUAL WINDOW LOGIC
    String activePrayerName = _getPrayerDisplayName(currentPrayer);
    DateTime activeTime = currentPrayer == Prayer.none 
        ? _prayerTimes!.isha 
        : _prayerTimes!.timeForPrayer(currentPrayer)!;

    // Detection for Ishraq and Zawal windows
    final ishraqTime = _prayerService.getIshraqTime(_prayerTimes!.sunrise);
    final zawalStart = _prayerService.getZawalTime(_prayerTimes!.dhuhr);

    if (currentPrayer == Prayer.sunrise) {
      if (now.isAfter(ishraqTime)) {
        activePrayerName = 'Ishraq';
        activeTime = ishraqTime;
      }
      if (now.isAfter(zawalStart)) {
        activePrayerName = 'Zawal';
        activeTime = zawalStart;
      }
    }

    if (currentPrayer == Prayer.none) {
      activePrayerName = 'Isha (Past)';
    }

    final upcomingPrayerName = nextPrayer == Prayer.none ? 'Fajr' : _getPrayerDisplayName(nextPrayer);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Bayt Al-Noor',
        subtitle: 'بَيْتُ النُّورِ',
        location: _cityName.toUpperCase(),
        onSearchPressed: () {},
        onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        onProfilePressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(
              name: _supabaseService.currentUser?.userMetadata?['full_name'] ?? 'Guest',
              avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
              bio: 'Seeking tranquility through reflection and prayer.',
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _initPrayerData,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Dynamic Header
                    CurrentPrayerHeader(
                      date: DateFormat('EEEE, d MMM').format(DateTime.now()),
                      prayerName: activePrayerName,
                      time: _formatTime(activeTime),
                      amPm: _getAmPm(activeTime),
                    ),

                    const SizedBox(height: 16),

                    // Next Prayer Card
                    PrayerStatusCard(
                      nextPrayer: upcomingPrayerName,
                      countdown: _calculateCountdown(nextPrayer),
                    ),

                    const SizedBox(height: 16),

                    RealTimePrayerClock(prayerTimes: _prayerTimes!),

                    const SizedBox(height: 16),

                    // Unified Data Grid
                    MilestoneGrid(prayerTimes: _prayerTimes!),

                    const SizedBox(height: 32),

                    // Bento Timetable with real data
                    BentoTimetable(
                      prayerTimes: _prayerTimes!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPrayerDisplayName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'Fajr';
      case Prayer.sunrise: return 'Sunrise';
      case Prayer.dhuhr: return 'Dhuhr';
      case Prayer.asr: return 'Asr';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha: return 'Isha';
      default: return 'Fajr Preparations';
    }
  }

  String _calculateCountdown(Prayer next) {
    if (next == Prayer.none) return 'Wait for Fajr';
    final nextTime = _prayerTimes!.timeForPrayer(next)!;
    final diff = nextTime.difference(DateTime.now());
    
    if (diff.isNegative) return '0h 0m';
    
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
