import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Stream para o estado de autenticação atual
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;

  // Usuário atual
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Método de Login
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // TODO: Melhorar o tratamento de erros e feedback ao usuário
      print('AuthException signIn: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic error signIn: $e');
      rethrow;
    }
  }

  // Método de Cadastro (Sign Up)
  Future<void> signUpWithPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data, // Para metadados adicionais do usuário, se necessário
  }) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      // Supabase pode enviar um email de confirmação aqui.
      // O usuário pode precisar confirmar o email antes de poder fazer login,
      // dependendo das configurações do seu projeto Supabase.
    } on AuthException catch (e) {
      print('AuthException signUp: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic error signUp: $e');
      rethrow;
    }
  }

  // Método de Logout
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      print('AuthException signOut: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic error signOut: $e');
      rethrow;
    }
  }
}
