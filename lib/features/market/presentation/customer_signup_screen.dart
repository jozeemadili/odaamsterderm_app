import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/google_auth_button.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/customer_google.dart';

/// Marketplace customer sign-up: email and password, or a Google account.
/// Arriving from "Continue with Google" with an unregistered account
/// ([prefill]) the name and email are filled in and only the phone is
/// missing — no password needed.
class CustomerSignupScreen extends ConsumerStatefulWidget {
  const CustomerSignupScreen({super.key, this.prefill});

  final GoogleSignupPrefill? prefill;

  @override
  ConsumerState<CustomerSignupScreen> createState() =>
      _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends ConsumerState<CustomerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  /// Signing up with this Google account (email locked, no password).
  GoogleSignupPrefill? _google;

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null) _useGoogle(widget.prefill!);
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  void _useGoogle(GoogleSignupPrefill prefill) {
    _google = prefill;
    if (_name.text.trim().isEmpty) _name.text = prefill.name ?? '';
    _email.text = prefill.email ?? '';
  }

  void _useEmailInstead() => setState(() {
    _google = null;
    _email.clear();
    _error = null;
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final auth = ref.read(authControllerProvider.notifier);
    try {
      final google = _google;
      if (google != null) {
        await auth.registerCustomerWithGoogle(
          idToken: google.idToken,
          name: _name.text.trim(),
          phone: _phone.text.trim(),
        );
      } else {
        await auth.registerCustomer(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      if (mounted) {
        showAuthToast(context, context.l10n.authWelcomeNew(_name.text.trim()));
        goHomeAfterSignIn(context, ref);
      }
    } on ApiException catch (e) {
      final message =
          e.fieldError('email') ??
          e.fieldError('phone') ??
          e.fieldError('id_token') ??
          e.message;
      setState(() => _error = message);
      if (mounted) showAuthToast(context, message, error: true);
    } catch (e) {
      // Not a server error (storage, network, parsing): still tell the person.
      if (mounted) {
        final message = context.l10n.signInFailed('$e');
        setState(() => _error = message);
        showAuthToast(context, message, error: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    // Registered → signed in; not registered → this form, prefilled.
    await continueWithGoogleAsCustomer(
      context,
      ref,
      onNeedsSignup: (prefill) {
        if (mounted) setState(() => _useGoogle(prefill));
      },
    );
    if (mounted) setState(() => _submitting = false);
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? '' : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final google = _google;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l10n.customerSignupTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.customerSignupSubtitle,
                style: TextStyle(color: DukaColors.muted),
              ),
              const SizedBox(height: 20),
              if (google != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DukaColors.leafTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: DukaColors.leafDeep,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.authSignupWithGoogle(google.email ?? ''),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _name,
                validator: _required,
                decoration: InputDecoration(labelText: l10n.customerNameLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                validator: _required,
                autofocus: google != null,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.customerPhoneLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                validator: _required,
                readOnly: google != null,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.customerEmailLabel,
                  suffixIcon: google != null
                      ? const Icon(Icons.lock_outline, size: 18)
                      : null,
                ),
              ),
              if (google == null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 8) ? '' : null,
                  decoration: InputDecoration(
                    labelText: l10n.customerPasswordLabel,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? Text(l10n.authSigningUp)
                    : Text(l10n.customerCreateAccount),
              ),
              const SizedBox(height: 8),
              if (google == null)
                GoogleAuthButton(
                  onPressed: _submitting ? null : _continueWithGoogle,
                  label: l10n.loginContinueWithGoogle,
                )
              else
                TextButton(
                  onPressed: _submitting ? null : _useEmailInstead,
                  child: Text(l10n.authUseEmailInstead),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
