import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_3/src/features/pwa/application/pwa_install_controller.dart';
import 'package:flutter_application_3/src/features/pwa/services/pwa_install_service.dart';

class _FakePwaInstallService implements PwaInstallService {
  _FakePwaInstallService({required bool initialCanInstall, this.promptResult = true})
      : _canInstall = initialCanInstall;

  bool _canInstall;
  bool promptCalled = false;
  final bool promptResult;
  final _controller = StreamController<bool>.broadcast();

  @override
  bool get canInstall => _canInstall;

  @override
  Stream<bool> get canInstallStream => _controller.stream;

  @override
  Future<bool> promptInstall() async {
    promptCalled = true;
    return promptResult;
  }

  void emitCanInstall(bool value) {
    _canInstall = value;
    _controller.add(value);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('PwaInstallController', () {
    test('exposes initial availability and updates via stream', () async {
      final fakeService = _FakePwaInstallService(initialCanInstall: false);
      final controller = PwaInstallController(fakeService);

      expect(controller.state.canInstall, isFalse);

      fakeService.emitCanInstall(true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.canInstall, isTrue);
      controller.dispose();
      fakeService.dispose();
    });

    test('promptInstall triggers service and updates state', () async {
      final fakeService = _FakePwaInstallService(initialCanInstall: true, promptResult: true);
      final controller = PwaInstallController(fakeService);

      final result = await controller.promptInstall();

      expect(result, isTrue);
      expect(fakeService.promptCalled, isTrue);
      expect(controller.state.isPrompting, isFalse);
      expect(controller.state.lastResult, isTrue);

      controller.dispose();
      fakeService.dispose();
    });
  });
}
