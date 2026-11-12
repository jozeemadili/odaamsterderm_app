import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme.dart';

/// The "Amsterdam Digital" wordmark, two-tone like the logo: green
/// "Amsterdam" + maroon "Digital".
class DukaWordmark extends StatelessWidget {
  const DukaWordmark({super.key, this.fontSize = 32});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Amsterdam ',
            style: style.copyWith(color: DukaColors.leafDeep),
          ),
          TextSpan(
            text: 'Digital',
            style: style.copyWith(color: DukaColors.indigo),
          ),
        ],
      ),
    );
  }
}
