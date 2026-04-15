import 'package:flutter/material.dart';
import '../../../../../core/design_tokens.dart';

class LocationSettingTile extends StatelessWidget {
  final String? locationName;
  final String? coordinates;
  final bool isAuto;
  final VoidCallback? onEdit;
  final VoidCallback? onRefresh;
  final bool isLoading;
  
  const LocationSettingTile({
    super.key,
    this.locationName,
    this.coordinates,
    this.isAuto = true,
    this.onEdit,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isAuto ? Icons.my_location_rounded : Icons.pin_drop_rounded,
        color: AppColors.primary,
      ),
      title: Text(
        locationName ?? (isAuto ? 'Detecting location...' : 'Set manually'),
        style: AppTypography.title.copyWith(color: AppColors.onSurface),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (coordinates != null)
            Text(
              coordinates!,
              style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          if (isAuto)
            Text(
              'Auto-detected via GPS',
              style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 11),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRefresh != null)
            IconButton(
              icon: isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded),
              onPressed: isLoading ? null : onRefresh,
              tooltip: 'Refresh location',
            ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: onEdit,
              tooltip: isAuto ? 'Enter manual location' : 'Edit location',
            ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}