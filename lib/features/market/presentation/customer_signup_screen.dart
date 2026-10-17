import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/config/google_auth_config.dart';
import '../../../core/widgets/google_auth_button.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';

/// Marketplace customer sign-up (email/password or Google).
class CustomerSignupScreen extends ConsumerStatefulWidget {
  const CustomerSignupScreen({super.key});

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

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _password]) {
      c.dispose();
    }
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
          .registerCustomer(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('email') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _google() async {
    setState(() => _error = null);
    try {
      final account = await GoogleSignIn(
        serverClientId: googleServerClientId,
      ).signIn();
      if (account == null) return;
      final idToken = (await account.authentication).idToken;
      if (idToken == null) return;
      await ref
          .read(authControllerProvider.notifier)
          .loginWithGoogle(idToken, asCustomer: true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? '' : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                style: const TextStyle(color: DukaColors.muted),
              ),
              const SizedBox(height: 20),
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
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.customerPhoneLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                validator: _required,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.customerEmailLabel),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                validator: (v) => (v == null || v.length < 8) ? '' : null,
                decoration: InputDecoration(
                  labelText: l10n.customerPasswordLabel,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(l10n.customerCreateAccount),
              ),
              const SizedBox(height: 8),
              GoogleAuthButton(
                onPressed: _submitting ? null : _google,
                label: l10n.loginContinueWithGoogle,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(l10n.customerSellInstead),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
