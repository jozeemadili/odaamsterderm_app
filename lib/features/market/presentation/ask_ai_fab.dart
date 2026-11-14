import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../ai/data/ai_models.dart';
import '../../ai/presentation/ai_providers.dart';

/// The farm assistant as a floating button on the marketplace and store
/// pages. Hidden while the admin has the AI switched off.
class AskAiFab extends ConsumerWidget {
  const AskAiFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ai = ref.watch(aiConfigProvider).valueOrNull ?? AiConfig.off;
    if (!ai.searchEnabled && !ai.orderEnabled) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      heroTag: 'ask-ai-fab',
      onPressed: () => context.push('/market/ai-order'),
      backgroundColor: DukaColors.maroon,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_awesome, color: DukaColors.leaf),
      label: Text(
        context.l10n.aiAskAi,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
