// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'pwa_install_service.dart';

class _WebPwaInstallService implements PwaInstallService {
  _WebPwaInstallService() {
    _controller = StreamController<bool>.broadcast();
    _beforeInstallListener = (event) {
      event.preventDefault();
      _deferredPrompt = event;
      _controller.add(true);
    };
    _appInstalledListener = (_) {
      _deferredPrompt = null;
      _controller.add(false);
    };
    html.window.addEventListener('beforeinstallprompt', _beforeInstallListener);
    html.window.addEventListener('appinstalled', _appInstalledListener);
  }

  late final StreamController<bool> _controller;
  late final html.EventListener _beforeInstallListener;
  late final html.EventListener _appInstalledListener;
  dynamic _deferredPrompt;

  @override
  bool get canInstall => _deferredPrompt != null;

  @override
  Stream<bool> get canInstallStream => _controller.stream;

  @override
  Future<bool> promptInstall() async {
    final prompt = _deferredPrompt;
    if (prompt == null) return false;
    try {
      await (prompt as dynamic).prompt();
      return true;
    } catch (_) {
      return false;
    } finally {
      _deferredPrompt = null;
      _controller.add(false);
    }
  }

  @override
  void dispose() {
    html.window.removeEventListener(
      'beforeinstallprompt',
      _beforeInstallListener,
    );
    html.window.removeEventListener('appinstalled', _appInstalledListener);
    _controller.close();
  }
}

PwaInstallService createPwaInstallService() => _WebPwaInstallService();
