import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// "Continue/Register with Google" button used on both auth screens —
/// the real multi-color Google "G" mark trails the label, matching the
/// same asset the web portal's `<x-icon.google>` component renders.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          const SizedBox(width: 10),
          SvgPicture.asset('assets/icons/google.svg', width: 20, height: 20),
        ],
      ),
    );
  }
}
