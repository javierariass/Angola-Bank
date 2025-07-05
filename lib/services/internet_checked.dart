import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

late StreamSubscription<ConnectivityResult> _subscription;

void initConnectivityListener(Function(String, bool) onStatusChange) {
  // Escucha cambios en tiempo real
  _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      onStatusChange('Internet connection available', true);
    } else {
      onStatusChange('No internet connection available', false);
    }
  });
}

void disposeConnectivityListener() {
  _subscription.cancel();
}