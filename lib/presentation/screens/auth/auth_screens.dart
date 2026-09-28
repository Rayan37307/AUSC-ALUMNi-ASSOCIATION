import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/content/school_content.dart';
import '../../providers/auth_provider.dart';

/// After a successful sign-in, continue to [from] if the user was sent here
/// by a protected page, otherwise return to wherever they came from.
void _finish(BuildContext context, String? from) {
  if (from != null && from.isNotEmpty) {
    context.pushReplacement(from);
  } else if (context.canPop()) {
    context.pop();
  } else {
    context.go('/home');
  }
}

class LoginScreen extends StatefulWidget {
  final String? from;

  const LoginScreen({super.key, this.from});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().signIn(
        phone: _phone.text,
        password: _password.text,
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      final name = context.read<AuthProvider>().firstName;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(name.isEmpty ? 'Signed in' : 'Welcome back, $name')),
      );
      _finish(context, widget.from);
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      eyebrow: 'Welcome Back',
      title: 'Sign In',
      subtitle: 'Use the mobile number you registered with.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PhoneField(controller: _phone),
            const SizedBox(height: 14),
            _PasswordField(
              controller: _password,
              label: 'Password',
              action: TextInputAction.done,
              onSubmitted: _submit,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            if (_error != null) _ErrorNote(message: _error!),
            const SizedBox(height: 24),
            InkPillButton(
              label: 'Sign In',
              expand: true,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      footer: _SwitchPrompt(
        question: 'New to the association?',
        action: 'Create an account',
        onTap: () => context.pushReplacement(
          Uri(
            path: '/signup',
            queryParameters: widget.from == null ? null : {'from': widget.from},
          ).toString(),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  final String? from;

  const SignUpScreen({super.key, this.from});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const int _minPassword = 6;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().signUp(
        name: _name.text,
        phone: _phone.text,
        password: _password.text,
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created — welcome aboard!')),
      );
      _finish(context, widget.from);
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthLayout(
      eyebrow: 'Join the Network',
      title: 'Create Account',
      subtitle: 'Sign up with your mobile number to add your profile.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Enter your full name'
                  : null,
            ),
            const SizedBox(height: 14),
            _PhoneField(controller: _phone),
            const SizedBox(height: 14),
            _PasswordField(
              controller: _password,
              label: 'Password',
              helper: 'At least $_minPassword characters',
              action: TextInputAction.next,
              autofill: AutofillHints.newPassword,
              validator: (v) => (v == null || v.length < _minPassword)
                  ? 'Use at least $_minPassword characters'
                  : null,
            ),
            const SizedBox(height: 14),
            _PasswordField(
              controller: _confirm,
              label: 'Confirm password',
              action: TextInputAction.done,
              autofill: AutofillHints.newPassword,
              onSubmitted: _submit,
              validator: (v) =>
                  v != _password.text ? 'Passwords don\'t match' : null,
            ),
            if (_error != null) _ErrorNote(message: _error!),
            const SizedBox(height: 24),
            InkPillButton(
              label: 'Create Account',
              expand: true,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      footer: _SwitchPrompt(
        question: 'Already have an account?',
        action: 'Sign in',
        onTap: () => context.pushReplacement(
          Uri(
            path: '/login',
            queryParameters: widget.from == null ? null : {'from': widget.from},
          ).toString(),
        ),
      ),
    );
  }
}

/// Ember hero on top, form card overlapping it below.
class _AuthLayout extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  const _AuthLayout({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 300 + topInset,
              child: EmberBackground(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GlassBackButton(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go('/home'),
                      ),
                      const Spacer(),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              eyebrow,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SoftCard(
                      radius: 32,
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          AutofillGroup(child: form),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    footer,
                    const SizedBox(height: 12),
                    Text(
                      SchoolContent.associationName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 350.ms),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\- ]')),
        LengthLimitingTextInputFormatter(17),
      ],
      decoration: const InputDecoration(
        labelText: 'Mobile number',
        hintText: '01XXXXXXXXX',
        prefixIcon: Icon(Icons.phone_iphone_rounded),
      ),
      validator: Phone.validate,
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final TextInputAction action;
  final String autofill;
  final VoidCallback? onSubmitted;
  final FormFieldValidator<String> validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.action,
    required this.validator,
    this.helper,
    this.autofill = AutofillHints.password,
    this.onSubmitted,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.action,
      autofillHints: [widget.autofill],
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helper,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
    );
  }
}

class _ErrorNote extends StatelessWidget {
  final String message;

  const _ErrorNote({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.tagBgDark : AppColors.errorLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark ? AppColors.tagTextDark : AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).shakeX(hz: 4, amount: 3);
  }
}

class _SwitchPrompt extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const _SwitchPrompt({
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: AppColors.tagText),
          child: Text(action),
        ),
      ],
    );
  }
}
