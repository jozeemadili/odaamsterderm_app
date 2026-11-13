import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Skeleton loading: grey placeholder shapes in the layout of the content
/// that is coming, with a soft light sweeping across them. Used instead of
/// a spinner wherever a whole screen, list or section is loading.

/// Sweeps a highlight across its child's [Bone]s, left to right, forever.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = DukaColors.dark
        ? const Color(0xFF2B1F22)
        : const Color(0xFFE9E8E1);
    final shine = DukaColors.dark
        ? const Color(0xFF3D2E32)
        : const Color(0xFFF7F7F2);

    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: [base, shine, base],
            stops: const [0.35, 0.5, 0.65],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            transform: _Slide(_controller.value),
          ).createShader(rect),
          child: child,
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.t);

  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
}

/// One placeholder shape. Its colour is replaced by the shimmer.
class Bone extends StatelessWidget {
  const Bone({
    super.key,
    this.width,
    this.height = 12,
    this.radius = 6,
    this.circle = false,
  });

  /// A circle of [size] (avatars).
  const Bone.circle(double size, {super.key})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(radius),
    ),
  );
}

/// A rounded card outline that holds bones (the card itself doesn't shimmer).
class _BoneCard extends StatelessWidget {
  const _BoneCard({required this.child, this.padding = 12});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: DukaColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: DukaColors.line),
    ),
    child: Shimmer(child: child),
  );
}

/// One list row: square or round thumbnail, two lines, a short trailing value.
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key, this.round = false});

  final bool round;

  @override
  Widget build(BuildContext context) => _BoneCard(
    child: Row(
      children: [
        round
            ? const Bone.circle(44)
            : const Bone(width: 52, height: 52, radius: 10),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(widthFactor: .7, child: Bone(height: 13)),
              SizedBox(height: 8),
              FractionallySizedBox(widthFactor: .45, child: Bone(height: 10)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Bone(width: 56, height: 14),
      ],
    ),
  );
}

/// A whole list loading: [count] rows.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 8,
    this.round = false,
    this.padding = const EdgeInsets.all(16),
    this.shrinkWrap = false,
  });

  final int count;
  final bool round;
  final EdgeInsets padding;

  /// True when placed inside another scroll view (a section of a page).
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < count; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SkeletonRow(round: round),
        ),
    ];
    if (shrinkWrap) {
      return Padding(
        padding: padding,
        child: Column(children: rows),
      );
    }
    return ListView(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      children: rows,
    );
  }
}

/// A detail page loading: a header block, a few lines, then cards.
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key, this.image = false});

  /// Start with a big photo (product pages).
  final bool image;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      if (image) ...[
        _BoneCard(
          padding: 0,
          child: const AspectRatio(aspectRatio: 1.2, child: Bone(radius: 16)),
        ),
        const SizedBox(height: 16),
      ],
      _BoneCard(
        padding: 16,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(widthFactor: .75, child: Bone(height: 20)),
            SizedBox(height: 10),
            FractionallySizedBox(widthFactor: .4, child: Bone(height: 12)),
            SizedBox(height: 18),
            Bone(width: 120, height: 24),
            SizedBox(height: 16),
            Bone(height: 10),
            SizedBox(height: 8),
            Bone(height: 10),
            SizedBox(height: 8),
            FractionallySizedBox(widthFactor: .6, child: Bone(height: 10)),
          ],
        ),
      ),
      const SizedBox(height: 14),
      for (var i = 0; i < 3; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: SkeletonRow(),
        ),
    ],
  );
}

/// The dashboard / report loading: a row of stat tiles, a chart, rows.
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    children: [
      Row(
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _BoneCard(
                padding: 14,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(width: 60, height: 10),
                    SizedBox(height: 12),
                    Bone(width: 100, height: 22),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _BoneCard(
                padding: 14,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(width: 60, height: 10),
                    SizedBox(height: 12),
                    Bone(width: 80, height: 22),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 12),
      _BoneCard(
        padding: 16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final h in [60.0, 110.0, 80.0, 140.0, 95.0, 120.0, 70.0]) ...[
              Expanded(child: Bone(height: h, radius: 6)),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < 3; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: SkeletonRow(),
        ),
    ],
  );
}

/// A marketplace post loading: maker line, square photo, caption.
class SkeletonFeedPost extends StatelessWidget {
  const SkeletonFeedPost({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: DukaColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: DukaColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Bone.circle(36),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(width: 120, height: 12),
                    SizedBox(height: 6),
                    Bone(width: 80, height: 9),
                  ],
                ),
              ],
            ),
          ),
          const AspectRatio(aspectRatio: 1, child: Bone(radius: 0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Bone.circle(24),
                    const SizedBox(width: 14),
                    const Bone.circle(24),
                    const Spacer(),
                    Bone(width: 64, height: 30, radius: 15),
                  ],
                ),
                const SizedBox(height: 14),
                const Bone(width: 90, height: 16),
                const SizedBox(height: 8),
                const FractionallySizedBox(
                  widthFactor: .7,
                  child: Bone(height: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Horizontal rows loading: store circles or small product cards.
class SkeletonStrip extends StatelessWidget {
  const SkeletonStrip.stories({super.key}) : cards = false;

  const SkeletonStrip.cards({super.key}) : cards = true;

  final bool cards;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: cards ? 172 : 92,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, _) => cards
          ? SizedBox(
              width: 128,
              child: _BoneCard(
                padding: 0,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(height: 100, radius: 0),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Bone(width: 90, height: 11),
                          SizedBox(height: 8),
                          Bone(width: 60, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Shimmer(
              child: SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Bone.circle(64),
                    SizedBox(height: 8),
                    Bone(width: 52, height: 9),
                  ],
                ),
              ),
            ),
    ),
  );
}
