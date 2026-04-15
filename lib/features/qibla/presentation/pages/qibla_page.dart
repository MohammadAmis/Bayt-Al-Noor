import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ✅ Core
import '../../../../../core/design_tokens.dart';
import '../../../../../core/widgets/common_widgets.dart';

// ✅ Local widgets
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/qibla_provider.dart';
import '../widgets/compass_dial.dart';
import '../widgets/qibla_display_card.dart';
import '../widgets/location_card.dart';
import '../widgets/recalibrate_button.dart';

// ✅ Your EXISTING location provider (AppLocation)
import '../../../settings/providers/location_providers.dart';

class QiblaPage extends ConsumerStatefulWidget {
  const QiblaPage({super.key});

  @override
  ConsumerState<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends ConsumerState<QiblaPage> {
  @override
  void initState() {
    super.initState();

    // Initialize Qibla after first frame (ensures providers are ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQibla();
    });
  }

  /// Initialize Qibla: wait for location if needed, then calculate
  void _initializeQibla() {
    // ✅ Read your existing provider: Provider<AsyncValue<AppLocation?>>
    final locationAsync = ref.read(locationProvider);

    if (locationAsync.value != null) {
      // ✅ Location already loaded: calculate immediately
      ref.read(qiblaProvider.notifier).initialize();
    } else {
      // ⏳ Location still loading: listen for changes, then calculate
      ref.listen<AsyncValue<AppLocation?>>(locationProvider, (previous, next) {
        if (next.value != null) {
          ref.read(qiblaProvider.notifier).initialize();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch Qibla state
    final qiblaState = ref.watch(qiblaProvider);

    // ✅ Watch your existing location provider
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: 'Bayt Al-Noor',
        subtitle: 'بَيْتُ النُّورِ',
        // ✅ Use AppLocation.displayAddress (from your extension)
        location: locationAsync.maybeWhen(
          data: (appLoc) => appLoc?.displayAddress ?? 'Loading...',
          orElse: () => 'Unknown',
        ),
        onSettingsPressed: () => Navigator.pushNamed(context, '/settings'),
        onProfilePressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(
              name: 'Fatima Al-Sayed',
              avatarUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y',
              bio: 'Seeking tranquility through reflection and prayer.',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                children: [
                  // Section Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // State handling: Loading / Error / Success
                  if (qiblaState.isLoading && qiblaState.direction == null)
                    const _LoadingState()
                  else if (qiblaState.error != null)
                    _ErrorState(
                      message: qiblaState.error!,
                      onRetry: () =>
                          ref.read(qiblaProvider.notifier).recalibrate(),
                    )
                  else if (qiblaState.direction != null) ...[
                    // ✅ Success: Show compass with real-time heading
                    // In your build() method, the CompassDial usage stays the same:
                    CompassDial(
                      qiblaDirection: qiblaState.direction!,
                      deviceHeading: qiblaState.deviceHeading,
                      size: 300,
                      onAligned: () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('✓ You are facing the Qibla'),
                              backgroundColor: AppColors.celestialGold,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // User Location Card (using your AppLocation)
                    LocationCard(
                      location: qiblaState.direction!.userLocation,
                      locationName: locationAsync.value?.displayAddress,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Recalibrate Button
                  RecalibrateButton(
                    isLoading: qiblaState.isCalibrating,
                    onPressed: () =>
                        ref.read(qiblaProvider.notifier).recalibrate(),
                  ),

                  // Manual location input (web fallback)
                  if (kIsWeb) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        final coords = await _showLocationInputDialog();
                        if (coords != null && mounted) {
                          ref.read(qiblaProvider.notifier).useManualLocation(
                                coords.latitude,
                                coords.longitude,
                                address: coords.address,
                              );
                        }
                      },
                      icon: const Icon(Icons.edit_location, size: 18),
                      label: const Text('Enter Location Manually'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build section header
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'CELESTIAL ALIGNMENT',
          style: AppTypography.label.copyWith(
            color: AppColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Qibla Direction',
          style: AppTypography.headline.copyWith(
            fontSize: 32,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Show dialog for manual location input (web fallback)
  Future<_ManualLocation?> _showLocationInputDialog() async {
    return showDialog<_ManualLocation>(
      context: context,
      builder: (context) {
        final latController = TextEditingController(text: '21.4225');
        final lonController = TextEditingController(text: '39.8262');
        final addressController =
            TextEditingController(text: 'Makkah, Saudi Arabia');

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppShapes.lgRadius),
          title: const Row(
            children: [
              Icon(Icons.edit_location, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Enter Coordinates'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GPS unavailable on web. Enter coordinates manually:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Latitude
              TextField(
                controller: latController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g., 21.4225',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.north),
                ),
              ),
              const SizedBox(height: 12),

              // Longitude
              TextField(
                controller: lonController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g., 39.8262',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.east),
                ),
              ),
              const SizedBox(height: 12),

              // Optional address
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Location Name (Optional)',
                  hintText: 'e.g., Makkah, Saudi Arabia',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latController.text.trim());
                final lon = double.tryParse(lonController.text.trim());

                if (lat != null &&
                    lon != null &&
                    lat >= -90 &&
                    lat <= 90 &&
                    lon >= -180 &&
                    lon <= 180) {
                  Navigator.pop(
                      context,
                      _ManualLocation(
                        latitude: lat,
                        longitude: lon,
                        address: addressController.text.trim().isEmpty
                            ? null
                            : addressController.text.trim(),
                      ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid coordinates'),
                      backgroundColor: AppColors.error,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: AppShapes.mdRadius),
              ),
              child: const Text('Use Location'),
            ),
          ],
        );
      },
    );
  }
}

/// Helper class for manual location input
class _ManualLocation {
  final double latitude;
  final double longitude;
  final String? address;

  _ManualLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

/// Loading indicator widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.compassFace,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.celestialGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator.adaptive(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.celestialGold),
            ),
            SizedBox(height: 16),
            Text(
              'Calculating direction...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget with retry option
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppShapes.lgRadius,
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                AppTypography.body.copyWith(color: AppColors.onErrorContainer),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('TRY AGAIN'),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 8),
            Text(
              '💡 Tip: Allow location in browser, then visit Home page first.',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
