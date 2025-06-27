import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persifix_app/src/features/customers/presentation/providers/customer_providers.dart';
import 'package:persifix_app/src/features/customers/domain/customer.dart';
import 'package:go_router/go_router.dart'; // Para navegação

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCustomers = ref.watch(customerListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        // Poderíamos adicionar ações como pesquisar aqui no futuro
      ),
      body: asyncCustomers.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: Text('Nenhum cliente encontrado. Adicione um novo!'),
            );
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Dismissible(
                key: Key(customer.id), // Chave única para o widget Dismissible
                direction: DismissDirection.endToStart, // Deslizar da direita para a esquerda
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // Mostrar um diálogo de confirmação antes de excluir
                  return await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar Exclusão'),
                        content: Text('Tem certeza que deseja excluir ${customer.name}?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), // Não exclui
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), // Exclui
                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  ) ?? false; // Retorna false se o diálogo for dispensado sem seleção
                },
                onDismissed: (direction) async {
                  try {
                    await ref.read(customerListNotifierProvider.notifier).deleteCustomer(customer.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${customer.name} excluído com sucesso')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir ${customer.name}: $e')),
                    );
                    // Se houve erro, a lista não será invalidada no notifier,
                    // mas idealmente o notifier deveria lidar com o estado de erro
                    // e a UI reconstruir para mostrar o item novamente ou uma mensagem de erro.
                    // Para simplicidade, estamos apenas mostrando um SnackBar.
                    // O item pode desaparecer visualmente mas ainda existir nos dados se a exclusão falhar
                    // e o estado não for atualizado corretamente. O CustomerListNotifier já trata
                    // a invalidação em caso de sucesso.
                  }
                },
                child: ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.email ?? customer.phone ?? 'Sem contato'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Armazena o ID do cliente selecionado para a tela de edição/detalhes
                    ref.read(selectedCustomerIdProvider.notifier).state = customer.id;
                    // Navega para a tela de adicionar/editar cliente, passando o ID na rota
                    // A rota /customers/edit/:id precisará ser definida no GoRouter
                    context.go('/customers/edit/${customer.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro ao carregar clientes: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate(customerListNotifierProvider),
                child: const Text('Tentar Novamente'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Limpa qualquer ID de cliente selecionado anteriormente, pois estamos criando um novo
          ref.read(selectedCustomerIdProvider.notifier).state = null;
          // Navega para a tela de adicionar novo cliente
          context.go('/customers/new');
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Cliente',
      ),
    );
  }
}
