import 'package:flutter/material.dart';

class MuteDurationSelector extends StatelessWidget {
  final Function(Duration?) onSelect;

  const MuteDurationSelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: false,
      onClosing: () {},
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mute Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.timer, size: 20),
              title: const Text('8 Hours'),
              onTap: () => _select(context, const Duration(hours: 8)),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, size: 20),
              title: const Text('1 Week'),
              onTap: () => _select(context, const Duration(days: 7)),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, size: 20),
              title: const Text('Always'),
              onTap: () => _select(context, null), // null = forever
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, Duration? duration) {
    onSelect(duration);
    Navigator.pop(context);
  }
}