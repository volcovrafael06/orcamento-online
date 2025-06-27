import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persifix_app/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:persifix_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:persifix_app/src/features/auth/presentation/screens/home_screen_placeholder.dart';

// Provedor para o GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier); // Para escutar o estado

  return GoRouter(
    initialLocation: '/login', // Ou '/', dependendo da lógica de redirecionamento
    debugLogDiagnostics: true, // Útil para depuração

    // Listener para mudanças de rota e estado de autenticação
    refreshListenable: GoRouterRefreshStream(ref.watch(authNotifierProvider.notifier).authStateChangesForRouter()),

    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = ref.read(authNotifierProvider); // Lê o estado atual
      final loggingIn = state.matchedLocation == '/login';

      // Se não estiver logado e tentando acessar algo diferente de /login, redireciona para /login
      if (authStatus != AuthStatus.authenticated && !loggingIn) {
        return '/login';
      }

      // Se estiver logado e na tela de login, redireciona para a home
      if (authStatus == AuthStatus.authenticated && loggingIn) {
        return '/';
      }

      return null; // Sem redirecionamento
    },

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreenPlaceholder(),
        // TODO: Adicionar rotas filhas aqui para outras features
      ),
      // Adicionar outras rotas aqui
    ],
  );
});


// Classe auxiliar para transformar um Stream em um Listenable para o GoRouter
// Isso é necessário porque o GoRouter espera um Listenable para o refreshListenable.
// O AuthNotifier precisa expor um Stream que emita um evento sempre que o estado de autenticação mudar.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Adicionar este método ao AuthNotifier em auth_providers.dart
// (Isso é uma indicação, a modificação real do arquivo será feita em um passo separado se necessário)
/*
  // Em AuthNotifier (flutter_app/lib/src/features/auth/presentation/providers/auth_providers.dart)
  Stream<void> authStateChangesForRouter() {
    // Este stream deve emitir um evento sempre que o estado de autenticação mudar
    // de uma forma que o GoRouter precise reavaliar os redirecionamentos.
    // Uma maneira simples é apenas mapear o stream de AuthState para um Stream<void>.
    return _authService.authStateChanges.map((_) => null);
  }
*/
