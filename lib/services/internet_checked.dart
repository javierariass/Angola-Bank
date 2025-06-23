import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

late StreamSubscription<ConnectivityResult> _subscription;

void initConnectivityListener(Function(String) onStatusChange) {
  _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      onStatusChange('Internet connection available');
    } else {
      onStatusChange('No internet connection available');
    }
  });
}

void disposeConnectivityListener() {
  _subscription.cancel();
}