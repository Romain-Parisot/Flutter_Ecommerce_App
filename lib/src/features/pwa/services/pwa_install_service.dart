import 'dart:async';

import 'pwa_install_stub.dart'
    if (dart.library.html) 'pwa_install_web.dart'
    as impl;

abstract class PwaInstallService {
  bool get canInstall;
  Stream<bool> get canInstallStream;
  Future<bool> promptInstall();
  void dispose();
}

PwaInstallService createPwaInstallService() => impl.createPwaInstallService();
