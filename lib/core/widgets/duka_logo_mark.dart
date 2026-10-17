import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The Odaamsterderm Hub monogram: a gold-outlined rounded square with a bold navy
/// "O", matching the logo. Drawn in code (no bitmap asset) so it renders
/// crisply at any size.
class DukaLogoMark extends StatelessWidget {
  const DukaLogoMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: DukaColors.gold, width: size * 0.06),
      ),
      alignment: Alignment.center,
      child: Text(
        'O',
        style: TextStyle(
          fontSize: size * 0.56,
          fontWeight: FontWeight.w800,
          height: 1,
          color: DukaColors.ink,
        ),
      ),
    );
  }
}
