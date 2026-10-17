import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/catalog/data/catalog_models.dart';
import '../../l10n/l10n_extension.dart';

/// "by Silverlands" with the producer's logo.
class ProducerLine extends StatelessWidget {
  const ProducerLine({super.key, required this.producer, this.large = false});

  final ProducerInfo? producer;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = producer;
    if (p == null) return const SizedBox.shrink();
    final size = large ? 32.0 : 18.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (p.logoUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: p.logoUrl!,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => SizedBox(width: size, height: size),
            ),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            context.l10n.producerBy(p.name),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: large ? 14 : 12,
              color: DukaColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
