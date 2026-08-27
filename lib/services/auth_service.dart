import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  AuthService._(this._client);

  final SupabaseClient? _client;
  String? errorMessage;

  bool get isConfigured => _client != null;
  User? get currentUser => _client?.auth.currentUser;
  SupabaseClient? get client => _client;

  static Future<AuthService> create() async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || anonKey.isEmpty) {
      return AuthService._(null);
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
    final service = AuthService._(Supabase.instance.client);
    service._client!.auth.onAuthStateChange.listen((_) {
      service.errorMessage = null;
      service.notifyListeners();
    });
    return service;
  }

  Future<void> signIn(String email, String password) async {
    await _run(() => _client!.auth.signInWithPassword(
          email: email,
          password: password,
        ));
  }

  Future<bool> signUp(String email, String password) async {
    final response = await _run(() => _client!.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: _emailRedirectUrl,
        ));
    return response?.user != null && response?.session == null;
  }

  Future<void> signOut() async {
    await _run(() => _client!.auth.signOut());
  }

  String? get _emailRedirectUrl {
    if (!kIsWeb) return null;
    return Uri.base.origin + Uri.base.path;
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    errorMessage = null;
    try {
      return await action();
    } on AuthException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    } catch (_) {
      errorMessage = 'Der opstod en uventet fejl. Prøv igen.';
      notifyListeners();
      rethrow;
    }
  }
}
