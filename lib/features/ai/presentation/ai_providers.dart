import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/ai_models.dart';
import '../data/ai_repository.dart';

final aiRepositoryProvider = Provider(
  (ref) => AiRepository(ref.watch(apiClientProvider)),
);

/// Admin switches for the AI buttons; treated as off when unreachable.
final aiConfigProvider = FutureProvider.autoDispose<AiConfig>((ref) async {
  try {
    return await ref.watch(aiRepositoryProvider).config();
  } catch (_) {
    return AiConfig.off;
  }
});
