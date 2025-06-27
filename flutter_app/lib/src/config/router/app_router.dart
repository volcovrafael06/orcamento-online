import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persifix_app/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:persifix_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:persifix_app/src/features/auth/presentation/screens/home_screen_placeholder.dart';
import 'package:persifix_app/src/features/customers/presentation/screens/customers_screen.dart';
import 'package:persifix_app/src/features/customers/presentation/screens/add_edit_customer_screen.dart';
import 'package:persifix_app/src/features/customers/presentation/providers/customer_providers.dart'; // Para selectedCustomerIdProvider

// Provedor para o GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,

    refreshListenable: GoRouterRefreshStream(ref.watch(authNotifierProvider.notifier).authStateChangesForRouter()),

    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = ref.read(authNotifierProvider);
      final loggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash'; // Exemplo se tiver splash

      if (isSplash) return null; // Não redirecionar se estiver no splash

      if (authStatus != AuthStatus.authenticated && !loggingIn) {
        return '/login';
      }

      if (authStatus == AuthStatus.authenticated && loggingIn) {
        return '/';
      }

      return null;
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
        routes: [ // Rotas filhas da Home
          GoRoute(
            path: 'customers', // Será acessado como /customers
            name: 'customers',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(
                path: 'new', // Será /customers/new
                name: 'newCustomer',
                builder: (context, state) {
                  // Ao navegar para new, garantir que não há cliente selecionado
                  Future.microtask(() => ref.read(selectedCustomerIdProvider.notifier).state = null);
                  return const AddEditCustomerScreen(customerId: null);
                },
              ),
              GoRoute(
                path: 'edit/:id', // Será /customers/edit/some-uuid
                name: 'editCustomer',
                builder: (context, state) {
                  final customerId = state.pathParameters['id'];
                  // Atualiza o provider do ID selecionado ANTES de construir a tela
                  // Idealmente, a tela AddEditCustomerScreen usaria este provider para buscar os dados se necessário
                  Future.microtask(() => ref.read(selectedCustomerIdProvider.notifier).state = customerId);
                  return AddEditCustomerScreen(customerId: customerId);
                },
              ),
            ]
          ),
          // Adicionar outras rotas de features aqui, como /products, /budgets etc.
        ]
      ),
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
