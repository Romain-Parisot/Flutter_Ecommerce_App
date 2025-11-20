import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pwa_install_service.dart';

final pwaInstallServiceProvider = Provider.autoDispose<PwaInstallService>((ref) {
  final service = createPwaInstallService();
  ref.onDispose(service.dispose);
  return service;
});

final pwaInstallControllerProvider =
    StateNotifierProvider.autoDispose<PwaInstallController, PwaInstallState>((ref) {
  final service = ref.watch(pwaInstallServiceProvider);
  final controller = PwaInstallController(service);
  ref.onDispose(controller.dispose);
  return controller;
});

class PwaInstallState {
  static const _sentinel = Object();

  const PwaInstallState({
    required this.canInstall,
    required this.isPrompting,
    this.lastResult,
  });

  factory PwaInstallState.initial(bool canInstall) {
    return PwaInstallState(
      canInstall: canInstall,
      isPrompting: false,
      lastResult: null,
    );
  }

  final bool canInstall;
  final bool isPrompting;
  final bool? lastResult;

  PwaInstallState copyWith({
    bool? canInstall,
    bool? isPrompting,
    Object? lastResult = _sentinel,
  }) {
    return PwaInstallState(
      canInstall: canInstall ?? this.canInstall,
      isPrompting: isPrompting ?? this.isPrompting,
      lastResult: identical(lastResult, _sentinel) ? this.lastResult : lastResult as bool?,
    );
  }
}

class PwaInstallController extends StateNotifier<PwaInstallState> {
  PwaInstallController(this._service)
      : super(PwaInstallState.initial(_service.canInstall)) {
    _sub = _service.canInstallStream.listen((value) {
      state = state.copyWith(canInstall: value, lastResult: null);
    });
  }

  final PwaInstallService _service;
  late final StreamSubscription<bool> _sub;

  Future<bool> promptInstall() async {
    if (!state.canInstall || state.isPrompting) {
      return false;
    }
    state = state.copyWith(isPrompting: true, lastResult: null);
    final result = await _service.promptInstall();
    state = state.copyWith(
      canInstall: _service.canInstall,
      isPrompting: false,
      lastResult: result,
    );
    return result;
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
