import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/config/google_auth_config.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/auth_models.dart';
import 'auth_controller.dart';

/// A short message at the bottom of the screen, kept on screen across the
/// navigation that follows signing in.
void showAuthToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB42318) : null,
        duration: Duration(seconds: error ? 5 : 3),
      ),
    );
}

/// "Continue with Google" for customers. Registered → signed in with a
/// welcome message. Not registered → [onNeedsSignup] gets the Google name
/// and email so the sign-up form can be finished. Every outcome shows a
/// message — success, cancel or failure — never silence.
Future<void> continueWithGoogleAsCustomer(
  BuildContext context,
  WidgetRef ref, {
  required void Function(GoogleSignupPrefill prefill) onNeedsSignup,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  void toast(String message, {bool error = false}) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB42318) : null,
        duration: Duration(seconds: error ? 5 : 3),
      ),
    );

  if (googleServerClientId.isEmpty) {
    toast(l10n.loginGoogleNotConfigured, error: true);
    return;
  }

  try {
    final googleSignIn = GoogleSignIn(serverClientId: googleServerClientId);
    // Always let the person pick the account, not the last one silently.
    await googleSignIn.signOut();
    final account = await googleSignIn.signIn();
    if (account == null) {
      toast(l10n.authGoogleCancelled);
      return;
    }

    final idToken = (await account.authentication).idToken;
    if (idToken == null) {
      toast(l10n.loginGoogleNoIdToken, error: true);
      return;
    }

    final pending = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle(idToken, asCustomer: true, askSignup: true);

    if (pending != null) {
      final email = pending.email ?? account.email;
      toast(l10n.authGoogleNoAccount(email));
      onNeedsSignup(
        GoogleSignupPrefill(
          idToken: idToken,
          name: pending.name ?? account.displayName,
          email: email,
        ),
      );
      return;
    }

    final name = ref.read(authControllerProvider).user?.name ?? '';
    toast(l10n.authWelcomeBack(name));
  } on ApiException catch (e) {
    toast(e.fieldError('id_token') ?? e.message, error: true);
  } catch (e) {
    toast(l10n.signInFailed('$e'), error: true);
  }
}
