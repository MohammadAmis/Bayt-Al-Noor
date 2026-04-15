import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';
import '../../../../core/utils/location_service.dart';

/// Card displaying user's current location
class LocationCard extends StatelessWidget {
  final LocationData location;
  final String? locationName; // Optional reverse-geocoded name

  const LocationCard({
    super.key,
    required this.location,
    this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppShapes.xlRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.primaryFixed,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR LOCATION',
                  style: AppTypography.label.copyWith(
                    color: AppColors.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationName ?? 'Loading location...',
                  style: AppTypography.headline.copyWith(
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                if (location.accuracy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Accuracy: ±${location.accuracy!.toStringAsFixed(0)}m',
                    style: AppTypography.body.copyWith(
                      fontSize: 11,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}