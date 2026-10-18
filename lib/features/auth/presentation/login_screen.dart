import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/config/google_auth_config.dart';
import '../../../core/widgets/duka_logo_mark.dart';
import '../../../core/widgets/duka_wordmark.dart';
import '../../../core/widgets/google_auth_button.dart';
import '../../../l10n/l10n_extension.dart';
import 'auth_controller.dart';
import 'complete_google_registration_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _submitting = false;
  bool _googleSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      // Not a server error (storage, network, parsing): still tell the person.
      if (mounted) setState(() => _error = context.l10n.signInFailed('$e'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    if (googleServerClientId.isEmpty) {
      setState(() => _error = context.l10n.loginGoogleNotConfigured);
      return;
    }

    setState(() {
      _googleSubmitting = true;
      _error = null;
    });

    try {
      final googleSignIn = GoogleSignIn(serverClientId: googleServerClientId);
      final account = await googleSignIn.signIn();
      if (account == null) return; // user cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        setState(() => _error = context.l10n.loginGoogleNoIdToken);
        return;
      }

      final pending = await ref
          .read(authControllerProvider.notifier)
          .loginWithGoogle(idToken);

      if (pending != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CompleteGoogleRegistrationScreen(pending: pending),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      // Not a server error (storage, network, parsing): still tell the person.
      if (mounted) setState(() => _error = context.l10n.signInFailed('$e'));
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    const Center(child: DukaLogoMark(size: 56)),
                    const SizedBox(height: 12),
                    const Center(child: DukaWordmark(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.loginEmailLabel,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.loginEmailValidator
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.loginPasswordLabel,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.loginPasswordValidator
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.loginButton),
                    ),
                    const SizedBox(height: 12),
                    GoogleAuthButton(
                      onPressed: _googleSubmitting ? null : _continueWithGoogle,
                      label: _googleSubmitting
                          ? l10n.loginSigningIn
                          : l10n.loginContinueWithGoogle,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.push('/signup'),
                      child: Text(l10n.customerCreateAccount),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(l10n.loginRegisterPrompt),
                    ),
                    TextButton.icon(
                      onPressed: () => context.go('/market'),
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(l10n.marketBrowse),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
