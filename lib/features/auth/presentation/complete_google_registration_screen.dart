import 'package:flutter/material.dart';

import '../data/auth_models.dart';
import 'register_screen.dart';

/// Thin wrapper: a Google sign-in with no matching DukaFlow account lands
/// here to collect the remaining business details, then submits through
/// the same RegisterScreen/AuthController.register(googleId: ...) path.
class CompleteGoogleRegistrationScreen extends StatelessWidget {
  const CompleteGoogleRegistrationScreen({super.key, required this.pending});

  final GoogleRegistrationRequired pending;

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(
      googleId: pending.googleId,
      prefillEmail: pending.email,
      prefillOwnerName: pending.name,
    );
  }
}
