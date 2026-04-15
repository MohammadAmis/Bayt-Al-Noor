import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_tokens.dart';
import '../../../../../core/providers/notification_schedule_status_provider.dart';

class ReschedulingStatusBanner extends ConsumerWidget {
  const ReschedulingStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(notificationScheduleStatusProvider);
    
    if (status.status == ScheduleStatus.idle) return const SizedBox.shrink();

    final isError = status.status == ScheduleStatus.error;
    final isSuccess = status.status == ScheduleStatus.success;

    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isError 
            ? AppColors.error.withValues(alpha: 0.12)
            : AppColors.primaryContainer.withValues(alpha: 0.9),
        borderRadius: AppShapes.lgRadius,
        border: Border.all(
          color: isError 
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (status.status == ScheduleStatus.scheduling)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                color: AppColors.primary
              ),
            )
          else
            Icon(
              isSuccess 
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              size: 18,
              color: isError ? AppColors.error : AppColors.primary,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.message ?? '',
              style: AppTypography.label.copyWith(
                color: isError 
                    ? AppColors.error
                    : AppColors.onPrimaryColorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
