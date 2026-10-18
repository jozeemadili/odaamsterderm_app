import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The "odaamsterderm hub" wordmark, two-tone like the logo: navy
/// "odaamsterderm" + gold "hub".
class DukaWordmark extends StatelessWidget {
  const DukaWordmark({super.key, this.fontSize = 32});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'odaamsterderm',
            style: style.copyWith(color: DukaColors.ink),
          ),
          TextSpan(
            text: 'hub',
            style: style.copyWith(color: DukaColors.gold),
          ),
        ],
      ),
    );
  }
}
