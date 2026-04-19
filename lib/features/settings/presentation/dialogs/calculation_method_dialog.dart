import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_tokens.dart';
import '../../domain/entities/calculation_method.dart';
import '../../providers/settings_providers.dart';

class CalculationMethodDialog extends ConsumerWidget {
  const CalculationMethodDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMethod = ref.watch(calculationMethodProvider);

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: AppShapes.xlRadius),
      title: Text(
        'Prayer Calculation Method',
        style: AppTypography.title.copyWith(color: AppColors.onSurface),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: RadioGroup<CalculationMethodOption>(
          groupValue: currentMethod,
          onChanged: (value) {
            if (value != null) {
              ref.read(calculationMethodProvider.notifier).update(value);
              Navigator.pop(context);
            }
          },
          child: ListView(
            shrinkWrap: true,
            children: CalculationMethodOption.values.map((method) {
              final isSelected = currentMethod == method;
  
              return ListTile(
                title: Text(
                  method.displayName,
                  style: AppTypography.body.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  method.recommendedRegions,
                  style: AppTypography.label.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                leading: Radio<CalculationMethodOption>(
                  value: method,
                  activeColor: AppColors.primary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                onTap: () {
                  ref.read(calculationMethodProvider.notifier).update(method);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: AppTypography.label.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}
