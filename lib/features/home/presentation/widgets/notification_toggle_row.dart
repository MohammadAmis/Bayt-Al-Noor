import 'package:bayt_al_noor/features/settings/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_tokens.dart';

class _NotificationToggleRow extends ConsumerWidget {
  final String prayerName;
  
  const _NotificationToggleRow({required this.prayerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final offset = ref.watch(notificationOffsetProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppShapes.fullRadius,
        border: Border.all(color: Colors.white.withValues(alpha:0.15)),
      ),
      child: Row(
        children: [
          Icon(
            notificationsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
            size: 18,
            color: Colors.white.withValues(alpha:0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notificationsEnabled ? 'Alert enabled' : 'Alerts disabled',
                  style: AppTypography.label.copyWith(
                    color: Colors.white.withValues(alpha:0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (notificationsEnabled)
                  Text(
                    '$offset min before $prayerName',
                    style: AppTypography.label.copyWith(
                      color: Colors.white.withValues(alpha:0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          // Toggle Switch
          Switch(
            value: notificationsEnabled,
            onChanged: (enabled) => ref.read(notificationsEnabledProvider.notifier).toggle(enabled),
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha:0.5),
            inactiveThumbColor: Colors.white.withValues(alpha:0.7),
            inactiveTrackColor: Colors.white.withValues(alpha:0.2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}