import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import '../providers/notification_orchestrator_provider.dart';

class AppLifecycleNotifier extends WidgetsBindingObserver {
  final ProviderContainer container;

  AppLifecycleNotifier(this.container) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ Force reschedule on resume (handles missed schedules or day shifts)
      container.read(notificationOrchestratorProvider);
      debugPrint('🌅 App resumed - triggering notification refresh');
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // Attempt to update local timezone if system locale/timezone shifts
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
      debugPrint('🌍 Timezone updated on locale change: ${DateTime.now().timeZoneName}');
    } catch (error) {
      debugPrint('⚠️ Failed to update timezone on locale change: $error');
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
