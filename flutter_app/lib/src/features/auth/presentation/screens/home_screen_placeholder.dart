import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persifix_app/src/features/auth/presentation/providers/auth_providers.dart';

class HomeScreenPlaceholder extends ConsumerWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authNotifier.signOut();
              // A navegação será tratada pelo router/listener de autenticação
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user != null ? 'Logado como: ${user.email}' : 'Não logado',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Bem-vindo à Página Inicial!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Gerenciar Clientes'),
                onPressed: () {
                  // Navegar para a lista de clientes
                  GoRouter.of(context).go('/customers');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              // Adicionar mais botões para outras funcionalidades aqui
              // Ex: Produtos, Orçamentos, etc.
            ],
          ),
        ),
      ),
    );
  }
}
