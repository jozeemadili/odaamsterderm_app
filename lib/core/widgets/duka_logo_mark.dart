import 'package:flutter/material.dart';

/// The Amsterdam Group ring mark on a white tile, as in the website's header.
class DukaLogoMark extends StatelessWidget {
  const DukaLogoMark({super.key, this.size = 44});

  /// Height of the tile; it is about 1.6 times as wide.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size * 1.6,
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.14,
        vertical: size * 0.12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Image.asset(
        'assets/images/amsterdam-mark.png',
        fit: BoxFit.contain,
        semanticLabel: 'Amsterdam Digital',
      ),
    );
  }
}
