import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/config/google_auth_config.dart';
import '../../../core/widgets/duka_logo_mark.dart';
import '../../../core/widgets/google_auth_button.dart';
import '../../../l10n/l10n_extension.dart';
import 'auth_controller.dart';
import 'complete_google_registration_screen.dart';

/// Self-service registration. Also reused by [CompleteGoogleRegistrationScreen]
/// for a Google sign-up that still needs business details, via [googleId]/
/// [prefillEmail]/[prefillOwnerName].
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    this.googleId,
    this.prefillEmail,
    this.prefillOwnerName,
  });

  final String? googleId;
  final String? prefillEmail;
  final String? prefillOwnerName;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _businessNameController = TextEditingController();
  late final _ownerNameController = TextEditingController(
    text: widget.prefillOwnerName ?? '',
  );
  late final _phoneController = TextEditingController();
  late final _emailController = TextEditingController(
    text: widget.prefillEmail ?? '',
  );
  final _passwordController = TextEditingController();

  int? _businessTypeId;
  int? _regionId;
  String? _error;
  bool _submitting = false;
  bool _googleSubmitting = false;

  bool get _isGoogleFlow => widget.googleId != null;

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
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
          .register(
            businessName: _businessNameController.text.trim(),
            ownerName: _ownerNameController.text.trim(),
            phone: _phoneController.text.trim(),
            businessTypeId: _businessTypeId,
            regionId: _regionId,
            email: _emailController.text.trim(),
            password: _isGoogleFlow ? null : _passwordController.text,
            googleId: widget.googleId,
          );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
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

      // pending == null means an account already existed and is now
      // signed in — the router redirects on the auth-state change, same
      // as the Login screen's Google button. Otherwise, swap to a fresh
      // copy of this screen pre-filled with the Google identity so the
      // rest of the form (business type, region, etc.) can be completed.
      if (pending != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompleteGoogleRegistrationScreen(pending: pending),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final businessTypesAsync = ref.watch(businessTypesProvider);
    final regionsAsync = ref.watch(regionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: DukaLogoMark(size: 44)),
                    const SizedBox(height: 20),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    if (!_isGoogleFlow) ...[
                      GoogleAuthButton(
                        onPressed: _googleSubmitting
                            ? null
                            : _continueWithGoogle,
                        label: _googleSubmitting
                            ? l10n.loginSigningIn
                            : l10n.registerWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              l10n.registerOrDivider,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _businessNameController,
                      decoration: InputDecoration(
                        labelText: l10n.registerBusinessNameLabel,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.registerRequiredValidator
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(
                        labelText: l10n.registerOwnerNameLabel,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.registerRequiredValidator
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.registerPhoneLabel,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.registerRequiredValidator
                          : null,
                    ),
                    const SizedBox(height: 12),
                    regionsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (regions) => DropdownButtonFormField<int?>(
                        initialValue: _regionId,
                        decoration: InputDecoration(
                          labelText: l10n.registerRegionLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.selectRegion),
                          ),
                          for (final r in regions)
                            DropdownMenuItem(value: r.id, child: Text(r.name)),
                        ],
                        onChanged: (v) => setState(() => _regionId = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    businessTypesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (types) => DropdownButtonFormField<int?>(
                        initialValue: _businessTypeId,
                        decoration: InputDecoration(
                          labelText: l10n.registerBusinessTypeLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.selectBusinessType),
                          ),
                          for (final t in types)
                            DropdownMenuItem(value: t.id, child: Text(t.name)),
                        ],
                        onChanged: (v) => setState(() => _businessTypeId = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isGoogleFlow,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.registerEmailLabel,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.registerRequiredValidator
                          : null,
                    ),
                    if (!_isGoogleFlow) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.registerPasswordLabel,
                        ),
                        validator: (v) => (v == null || v.length < 8)
                            ? l10n.registerPasswordLengthValidator
                            : null,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.registerButton),
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
