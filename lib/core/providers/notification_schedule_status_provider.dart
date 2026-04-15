import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ScheduleStatus { idle, scheduling, success, error }

class ScheduleState {
  final ScheduleStatus status;
  final String? message;
  const ScheduleState({this.status = ScheduleStatus.idle, this.message});
}

final notificationScheduleStatusProvider = 
    StateNotifierProvider<NotificationScheduleStatusNotifier, ScheduleState>((ref) {
  return NotificationScheduleStatusNotifier();
});

class NotificationScheduleStatusNotifier extends StateNotifier<ScheduleState> {
  NotificationScheduleStatusNotifier() : super(const ScheduleState());

  void start() {
    state = const ScheduleState(
      status: ScheduleStatus.scheduling,
      message: 'Rescheduling prayer alerts...',
    );
  }

  void complete() {
    state = const ScheduleState(
      status: ScheduleStatus.success,
      message: 'Prayer alerts updated successfully',
    );
    _resetAfterDelay(const Duration(seconds: 3));
  }

  void fail(String error) {
    state = ScheduleState(
      status: ScheduleStatus.error,
      message: 'Failed to update: $error',
    );
    _resetAfterDelay(const Duration(seconds: 5));
  }

  void _resetAfterDelay(Duration duration) {
    Future.delayed(duration, () {
      if (mounted) {
        state = const ScheduleState(status: ScheduleStatus.idle);
      }
    });
  }
}
