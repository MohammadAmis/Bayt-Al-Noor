import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import '../../data/services/tasbih_service.dart';

class GoalManagement extends StatelessWidget {
  final TasbihService service;
  final TextEditingController customGoalController;
  final Function(int) onSetGoal;

  const GoalManagement({
    super.key,
    required this.service,
    required this.customGoalController,
    required this.onSetGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Set Session Goal',
              style: AppTypography.title.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PRESETS',
              style: AppTypography.label.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildPresetButton(context, 33),
            const SizedBox(width: 12),
            _buildPresetButton(context, 99),
            const SizedBox(width: 12),
            _buildPresetButton(context, 100),
          ],
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.outlineVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: customGoalController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          service.setGoal(int.tryParse(val) ?? service.sessionGoal);
                        }
                      },
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter target number...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: AppColors.outlineVariant, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.surface,
                child: Text(
                  'CUSTOM GOAL',
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(BuildContext context, int value) {
    bool isSelected = service.sessionGoal == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSetGoal(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$value',
              style: AppTypography.headline.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
