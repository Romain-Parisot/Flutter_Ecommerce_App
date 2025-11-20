import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';

const _placeholderToken = 'REPLACE_WITH';

bool get isFirebaseConfigured {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    return !_hasPlaceholder(options);
  } catch (_) {
    return false;
  }
}

bool _hasPlaceholder(FirebaseOptions options) {
  return options.apiKey.startsWith(_placeholderToken) ||
      options.appId.startsWith(_placeholderToken) ||
      options.projectId.startsWith(_placeholderToken);
}
