import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Global network state manager.
/// Broadcasts online/offline status and triggers auto-sync when reconnected.
class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._internal();
  factory ConnectivityMonitor() => _instance;

  ConnectivityMonitor._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();
  
  bool _isOnline = true; // Assume online initially
  bool get isOnline => _isOnline;
  
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Call this once in `main()` or app initialization
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    _updateStatus(result);
  }

  void _updateStatus(ConnectivityResult result) {
    final wasOffline = !_isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    // Only broadcast state changes
    if (_isOnline != wasOffline) {
      _onlineController.add(_isOnline);
    }
  }

  void dispose() {
    _onlineController.close();
  }
}