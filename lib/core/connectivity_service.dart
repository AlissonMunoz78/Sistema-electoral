import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  void Function(bool)? onConnectivityChanged;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void startMonitoring() {
    _connectivity.checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
    });
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_isOnline) {
        onConnectivityChanged?.call(true);
      }
      _isOnline = online;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
