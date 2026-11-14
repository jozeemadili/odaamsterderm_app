import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';

/// Initials for a circle avatar: "Amsterdam Group" → "AG".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

/// A circle with the maroon-to-leaf ring, like a story on Instagram.
class RingAvatar extends StatelessWidget {
  const RingAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 64,
  });

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = size > 40 ? 2.5 : 1.8;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [DukaColors.indigo, DukaColors.leaf],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(ring),
        decoration: BoxDecoration(
          color: DukaColors.card,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => _initialsBox(),
                )
              : _initialsBox(),
        ),
      ),
    );
  }

  Widget _initialsBox() => Container(
    color: DukaColors.maroonTint,
    alignment: Alignment.center,
    child: Text(
      initialsOf(name),
      style: GoogleFonts.montserrat(
        fontSize: size * 0.28,
        fontWeight: FontWeight.w800,
        color: DukaColors.indigo,
      ),
    ),
  );
}

/// A product as an Instagram-style post: maker on top, a big swipeable
/// photo, Ask AI / share / one main button, then price, name and a detail
/// line as the caption. Used by the marketplace feed and store pages.
class ProductPost extends StatefulWidget {
  const ProductPost({
    super.key,
    required this.makerName,
    this.makerLogoUrl,
    this.subtitle,
    this.showAvailable = false,
    required this.photos,
    this.price,
    required this.noPriceText,
    this.noPriceIsProblem = false,
    required this.name,
    this.detail,
    required this.onOpen,
    this.onAskAi,
    this.shareText,
    required this.actionLabel,
    this.actionIcon,
    required this.onAction,
  });

  final String makerName;
  final String? makerLogoUrl;
  final String? subtitle;

  /// Show the green "Available" pill next to the maker.
  final bool showAvailable;
  final List<String> photos;

  /// Formatted price ("TZS 1,000"); null shows [noPriceText] instead.
  final String? price;
  final String noPriceText;

  /// [noPriceText] in red (out of stock) rather than grey (not in stores).
  final bool noPriceIsProblem;
  final String name;

  /// Shown after the name in grey: pack sizes or stock left.
  final String? detail;
  final VoidCallback onOpen;
  final VoidCallback? onAskAi;
  final String? shareText;
  final String actionLabel;
  final IconData? actionIcon;
  final VoidCallback onAction;

  @override
  State<ProductPost> createState() => _ProductPostState();
}

class _ProductPostState extends State<ProductPost> {
  int _photo = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = widget;
    final photos = w.photos;

    return Container(
      decoration: BoxDecoration(
        color: DukaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DukaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maker, like the account that posted it.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                RingAvatar(
                  name: w.makerName,
                  imageUrl: w.makerLogoUrl,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.makerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (w.subtitle != null && w.subtitle!.isNotEmpty)
                        Text(
                          w.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: DukaColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (w.showAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: DukaColors.leafTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.marketAvailable,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DukaColors.leafDeep,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // The photo — swipe for the back of the pack.
          GestureDetector(
            onTap: w.onOpen,
            child: AspectRatio(
              // No photo yet: a shorter placeholder instead of an empty square.
              aspectRatio: photos.isEmpty ? 2 : 1,
              child: Container(
                color: DukaColors.soft,
                child: photos.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 56,
                          color: DukaColors.muted,
                        ),
                      )
                    : Stack(
                        children: [
                          PageView.builder(
                            itemCount: photos.length,
                            onPageChanged: (i) => setState(() => _photo = i),
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: CachedNetworkImage(
                                imageUrl: photos[i],
                                fit: BoxFit.contain,
                                placeholder: (_, _) => const SizedBox.shrink(),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.broken_image_outlined,
                                  color: DukaColors.muted,
                                ),
                              ),
                            ),
                          ),
                          if (photos.length > 1)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${_photo + 1}/${photos.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),

          // Actions, then the dots under the photo.
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
            child: Row(
              children: [
                if (w.onAskAi != null)
                  IconButton(
                    tooltip: l10n.marketAskAbout,
                    onPressed: w.onAskAi,
                    icon: Icon(
                      Icons.auto_awesome_outlined,
                      color: DukaColors.indigo,
                    ),
                  ),
                if (w.shareText != null)
                  IconButton(
                    tooltip: l10n.marketShare,
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: w.shareText),
                    ),
                    icon: Icon(Icons.send_outlined, color: DukaColors.ink),
                  ),
                Expanded(
                  child: photos.length > 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < photos.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: i == _photo ? 7 : 6,
                                height: i == _photo ? 7 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _photo
                                      ? DukaColors.indigo
                                      : DukaColors.line,
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                FilledButton.icon(
                  onPressed: w.onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: DukaColors.leaf,
                    foregroundColor: DukaColors.ink,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  icon: w.actionIcon == null
                      ? const SizedBox.shrink()
                      : Icon(w.actionIcon, size: 18),
                  label: Text(w.actionLabel),
                ),
              ],
            ),
          ),

          // Caption: price, then name and the detail line.
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.price ?? w.noPriceText,
                  style: w.price != null
                      ? GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: DukaColors.ink,
                        )
                      : TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: w.noPriceIsProblem
                              ? DukaColors.rose
                              : DukaColors.muted,
                        ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: w.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (w.detail != null)
                        TextSpan(
                          text: '  ${w.detail}',
                          style: TextStyle(color: DukaColors.muted),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
