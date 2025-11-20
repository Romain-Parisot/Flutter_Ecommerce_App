import 'dart:async';

import 'pwa_install_service.dart';

class _NoopPwaInstallService implements PwaInstallService {
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get canInstall => false;

  @override
  Stream<bool> get canInstallStream => _controller.stream;

  @override
  Future<bool> promptInstall() async => false;

  @override
  void dispose() {
    _controller.close();
  }
}

PwaInstallService createPwaInstallService() => _NoopPwaInstallService();
