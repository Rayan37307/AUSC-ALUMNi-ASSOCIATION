import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/phone.dart';

/// Phone + password accounts backed by Supabase Auth.
///
/// Supabase's phone provider requires a paid SMS service, so each phone
/// number is mapped to a placeholder email and signed up with the email
/// provider instead. No email is ever sent; "Confirm email" must be turned
/// off in Supabase → Authentication → Sign In / Providers → Email.
class AuthProvider with ChangeNotifier {
  /// Domain for the placeholder emails. Changing it later orphans existing
  /// accounts, so leave it alone once people have signed up.
  static const String _emailDomain = 'phone.ausc-alumni.app';

  GoTrueClient? _auth;
  StreamSubscription<AuthState>? _subscription;
  bool? _isAdmin;

  AuthProvider() {
    try {
      _auth = Supabase.instance.client.auth;
      _subscription = _auth!.onAuthStateChange.listen((event) {
        notifyListeners();
        if (event.session == null) {
          _isAdmin = false;
        } else {
          _loadAdminStatus();
        }
      });
      if (isSignedIn) _loadAdminStatus();
    } catch (e) {
      debugPrint('Auth unavailable: $e');
    }
  }

  User? get user => _auth?.currentUser;
  bool get isSignedIn => user != null;

  /// True when the signed-in account is listed in the Supabase `admins`
  /// table. Null while the check is still in flight.
  bool get isAdmin => _isAdmin == true;

  /// Ask Supabase whether this account is an administrator.
  ///
  /// Relies on the "Admins can read own record" RLS policy, so the query can
  /// only ever return the caller's own row.
  Future<void> _loadAdminStatus() async {
    final currentUser = _auth?.currentUser;
    if (currentUser == null) {
      if (_isAdmin != false) {
        _isAdmin = false;
        notifyListeners();
      }
      return;
    }

    try {
      final rows = await Supabase.instance.client
          .from('admins')
          .select('user_id')
          .eq('user_id', currentUser.id)
          .limit(1);
      final admin = rows.isNotEmpty;
      if (_isAdmin != admin) {
        _isAdmin = admin;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Admin check failed: $e');
      _isAdmin = false;
    }
  }

  String get displayName =>
      (user?.userMetadata?['full_name'] as String?)?.trim() ?? '';

  /// Canonical phone number (8801XXXXXXXXX) of the signed-in user.
  String get phone => (user?.userMetadata?['phone'] as String?) ?? '';

  String get firstName => displayName.split(' ').first;

  static String _emailFor(String canonicalPhone) =>
      '$canonicalPhone@$_emailDomain';

  GoTrueClient get _client {
    final auth = _auth;
    if (auth == null) {
      throw const AuthFailure('Accounts are unavailable right now.');
    }
    return auth;
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    final canonical = Phone.normalize(phone);
    if (canonical == null) {
      throw const AuthFailure('Enter a valid mobile number.');
    }

    try {
      final response = await _client.signUp(
        email: _emailFor(canonical),
        password: password,
        data: {'full_name': name.trim(), 'phone': canonical},
      );
      if (response.session == null) {
        // Supabase created the user but is waiting for email confirmation,
        // which can never arrive for a placeholder address.
        throw const AuthFailure(
          'Sign-up needs one more setup step: turn off "Confirm email" in '
          'Supabase Authentication settings.',
        );
      }
    } on AuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<void> signIn({required String phone, required String password}) async {
    final canonical = Phone.normalize(phone);
    if (canonical == null) {
      throw const AuthFailure('Enter a valid mobile number.');
    }

    try {
      await _client.signInWithPassword(
        email: _emailFor(canonical),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<void> signOut() async {
    try {
      _isAdmin = false;
      await _auth?.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  String _friendlyMessage(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('already registered') ||
        message.contains('already been registered') ||
        e.code == 'user_already_exists') {
      return 'An account with this number already exists. Try signing in.';
    }
    if (message.contains('invalid login credentials')) {
      return 'Incorrect mobile number or password.';
    }
    if (message.contains('email not confirmed')) {
      return 'This account is waiting for confirmation. Turn off "Confirm '
          'email" in Supabase Authentication settings.';
    }
    if (message.contains('password')) return e.message;
    if (message.contains('rate limit') || e.statusCode == '429') {
      return 'Too many attempts. Please wait a minute and try again.';
    }
    return 'Something went wrong. Check your connection and try again.';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}
