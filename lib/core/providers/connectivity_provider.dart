import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);
});

// Helper: Check connectivity before API calls
final canFetchDataProvider = Provider<bool>((ref) {
  final isConnected = ref.watch(connectivityProvider).value ?? false;
  // NOTE: For now, we simulate hasCache as true since Hive is set up.
  const hasCache = true; 
  return isConnected || hasCache; 
});
