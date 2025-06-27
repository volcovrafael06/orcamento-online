import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:persifix_app/src/features/auth/data/auth_service.dart';

part 'auth_providers.g.dart'; // Arquivo gerado pelo build_runner

// Provedor para o AuthService
@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

// Provedor para o stream de estado de autenticação do Supabase
@riverpod
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

// Provedor para o usuário atual
@riverpod
User? currentUser(CurrentUserRef ref) {
  // Escuta as mudanças no authStateChanges e retorna o usuário atual
  // Isso pode ser otimizado para não reconstruir desnecessariamente se o estado não mudar o usuário
  // Mas para começar, é uma forma simples de obter o usuário atual reativamente.
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => ref.watch(authServiceProvider).currentUser, // Tenta pegar o síncrono enquanto carrega
    error: (_, __) => null,
  );
}

// Provedor de estado para controlar o estado de carregamento durante as operações de auth
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provedor para gerenciar o estado da autenticação de forma mais explícita (opcional, mas útil)
enum AuthStatus { unknown, authenticated, unauthenticated }

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthService _authService;

  @override
  AuthStatus build() {
    _authService = ref.watch(authServiceProvider);

    // Escuta as mudanças de estado de autenticação do Supabase
    final authStateSubscription = ref.listen<AsyncValue<AuthState>>(
      authStateChangesProvider,
      (_, next) {
        next.whenData((authState) {
          if (authState.session?.user != null) {
            state = AuthStatus.authenticated;
          } else {
            state = AuthStatus.unauthenticated;
          }
        });
      }
    );

    // Garante que a subscrição seja cancelada quando o provider for descartado
    ref.onDispose(() => authStateSubscription.close());

    // Estado inicial baseado no usuário atual síncrono
    if (_authService.currentUser != null) {
      return AuthStatus.authenticated;
    }
    return AuthStatus.unauthenticated;
  }

  Future<void> signInWithPassword({required String email, required String password}) async {
    ref.read(authLoadingProvider.notifier).state = true;
    try {
      await _authService.signInWithPassword(email: email, password: password);
      // O estado será atualizado pelo listener do authStateChangesProvider
    } catch (e) {
      // O erro já foi logado no AuthService, pode-se adicionar um feedback para o usuário aqui
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signUpWithPassword({required String email, required String password, Map<String, dynamic>? data}) async {
    ref.read(authLoadingProvider.notifier).state = true;
    try {
      await _authService.signUpWithPassword(email: email, password: password, data: data);
      // O estado será atualizado pelo listener ou o usuário precisará confirmar o email
    } catch (e) {
      rethrow;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    ref.read(authLoadingProvider.notifier).state = true;
    try {
      await _authService.signOut();
      // O estado será atualizado pelo listener do authStateChangesProvider
      state = AuthStatus.unauthenticated; // Força atualização imediata para UI
    } catch (e) {
      // Tratar erro
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Stream<void> authStateChangesForRouter() {
    // Este stream emite um evento sempre que o estado de autenticação do Supabase muda.
    // É usado pelo GoRouter para reavaliar os redirecionamentos.
    return _authService.authStateChanges.map((_) => null);
  }
}
