import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      _controller.sink.add(result != ConnectivityResult.none);
    });
  }

  Stream<bool> get connectivityStream => _controller.stream;

  void dispose() => _controller.close();
}
