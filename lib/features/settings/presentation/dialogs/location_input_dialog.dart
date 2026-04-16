import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_tokens.dart';
import '../../providers/settings_providers.dart';

class LocationInputDialog extends ConsumerStatefulWidget {
  final String? initialLocation;
  final Function(String)? onSave;
  
  const LocationInputDialog({super.key, this.initialLocation, this.onSave});

  @override
  ConsumerState<LocationInputDialog> createState() => _LocationInputDialogState();
}

class _LocationInputDialogState extends ConsumerState<LocationInputDialog> {
  late final TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLocation ?? '');
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.xlRadius),
      title: Text(
        'Set Manual Location',
        style: AppTypography.title.copyWith(color: AppColors.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter city name or coordinates (e.g., "London, UK" or "51.5074, -0.1278")',
            style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Location name or coordinates',
              hintStyle: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: AppShapes.lgRadius, borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: AppTypography.body.copyWith(color: AppColors.onSurface),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveLocation(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.label.copyWith(color: AppColors.primary)),
        ),
        ElevatedButton(
          onPressed: _saveLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: AppShapes.fullRadius),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
  
  void _saveLocation() {
    final value = _controller.text.trim();
    if (widget.onSave != null) {
      widget.onSave!(value);
    } else {
      if (value.isEmpty) {
        // Clear manual location
        ref.read(manualLocationNameProvider.notifier).update(null);
      } else {
        ref.read(manualLocationNameProvider.notifier).update(value);
      }
    }
    Navigator.pop(context);
  }
}