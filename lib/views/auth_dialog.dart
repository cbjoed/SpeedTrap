import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

Future<void> showAuthDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _AuthDialog(),
  );
}

class _AuthDialog extends StatefulWidget {
  const _AuthDialog();

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final needsConfirmation = _isSignup && await auth.signUp(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      if (needsConfirmation) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tjek din email for at bekræfte kontoen.'),
        ));
      } else {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return AlertDialog(
      title: Text(_isSignup ? 'Opret konto' : 'Log ind'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!auth.isConfigured)
              const Text('Supabase er ikke konfigureret endnu.'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value == null || !value.contains('@') ? 'Indtast en gyldig email' : null,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Adgangskode'),
              validator: (value) => value == null || value.length < 6
                  ? 'Mindst 6 tegn'
                  : null,
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(auth.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() => _isSignup = !_isSignup),
          child: Text(_isSignup ? 'Jeg har en konto' : 'Opret konto'),
        ),
        FilledButton(
          onPressed: _isLoading || !auth.isConfigured ? null : () => _submit(auth),
          child: _isLoading
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isSignup ? 'Opret' : 'Log ind'),
        ),
      ],
    );
  }
}