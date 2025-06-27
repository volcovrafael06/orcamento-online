import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:persifix_app/src/features/customers/domain/customer.dart';
import 'package:persifix_app/src/features/customers/data/customer_service.dart';

part 'customer_providers.g.dart'; // Arquivo gerado pelo build_runner

// 1. Provedor para o CustomerService
@Riverpod(keepAlive: true)
CustomerService customerService(CustomerServiceRef ref) {
  // Aqui poderíamos injetar dependências no CustomerService se ele as tivesse,
  // como uma instância configurada do SupabaseClient, se não usássemos o singleton.
  return CustomerService();
}

// 2. AsyncNotifierProvider para a lista de clientes e operações CRUD
@riverpod
class CustomerListNotifier extends _$CustomerListNotifier {
  // O método build é chamado uma vez quando o provider é lido pela primeira vez.
  // Ele deve retornar o estado inicial (geralmente uma Future ou os dados diretamente se síncrono).
  @override
  Future<List<Customer>> build() async {
    // Obtém o CustomerService usando ref.watch para que, se o CustomerService mudar (improvável aqui),
    // este provider seja reconstruído.
    final customerService = ref.watch(customerServiceProvider);
    return customerService.fetchCustomers();
  }

  // Método para adicionar um cliente
  Future<void> addCustomer(Customer customer) async {
    final customerService = ref.read(customerServiceProvider);
    // Define o estado para loading para que a UI possa reagir
    state = const AsyncValue.loading();
    try {
      await customerService.addCustomer(customer);
      // Após adicionar com sucesso, invalida o estado atual para forçar um refetch.
      // Isso fará com que o método build() seja chamado novamente.
      ref.invalidateSelf();
      // Espera a reconstrução para garantir que a UI tenha os dados mais recentes
      await future;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      // Poderia re-lançar ou tratar o erro de forma mais específica para a UI
    }
  }

  // Método para atualizar um cliente
  Future<void> updateCustomer(Customer customer) async {
    final customerService = ref.read(customerServiceProvider);
    state = const AsyncValue.loading();
    try {
      await customerService.updateCustomer(customer);
      ref.invalidateSelf();
      await future;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // Método para deletar um cliente
  Future<void> deleteCustomer(String customerId) async {
    final customerService = ref.read(customerServiceProvider);
    state = const AsyncValue.loading();
    try {
      await customerService.deleteCustomer(customerId);
      ref.invalidateSelf();
      await future;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // Método para buscar um cliente específico da lista atual (se necessário)
  // Ou poderia ser um novo provider `family` se a busca for direto do DB.
  Customer? getCustomerById(String customerId) {
    // Acessa o estado atual de forma segura
    return state.whenData((customers) {
      try {
        return customers.firstWhere((c) => c.id == customerId);
      } catch (e) {
        return null; // Não encontrado
      }
    }).valueOrNull;
  }
}

// Provedor para o estado de carregamento de uma operação específica (opcional)
// Pode ser útil para mostrar indicadores de carregamento em botões específicos, etc.
final customerOperationLoadingProvider = StateProvider<bool>((ref) => false);

// Provedor para um cliente selecionado (se você tiver uma tela de detalhes/edição)
// Usar `family` se for buscar por ID do backend, ou um StateProvider se for apenas
// para passar o objeto Customer para a tela de edição.
final selectedCustomerIdProvider = StateProvider<String?>((ref) => null);

final selectedCustomerProvider = Provider<Customer?>((ref) {
  final selectedId = ref.watch(selectedCustomerIdProvider);
  if (selectedId == null) return null;

  // Tenta obter o cliente da lista já carregada
  final customers = ref.watch(customerListNotifierProvider).asData?.value;
  if (customers != null) {
    try {
      return customers.firstWhere((c) => c.id == selectedId);
    } catch (e) {
      // Cliente não encontrado na lista atual, pode indicar necessidade de buscar individualmente
      // ou que a lista está desatualizada. Por ora, retorna null.
      return null;
    }
  }
  return null;
});
