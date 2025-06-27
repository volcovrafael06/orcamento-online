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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user != null ? 'Logado como: ${user.email}' : 'Não logado'),
            const SizedBox(height: 20),
            const Text('Bem-vindo à Página Inicial!'),
            // Aqui virá o conteúdo principal do app
          ],
        ),
      ),
    );
  }
}
