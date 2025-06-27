import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:persifix_app/src/features/customers/domain/customer.dart';

class CustomerService {
  final SupabaseClient _supabaseClient;

  // Construtor pode receber uma instância do SupabaseClient,
  // ou podemos usar Supabase.instance.client diretamente.
  // Para testabilidade, injetar é melhor, mas para simplicidade inicial:
  CustomerService({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  String get _tableName => 'clientes'; // Nome da tabela no Supabase

  // Buscar todos os clientes
  Future<List<Customer>> fetchCustomers() async {
    try {
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('name', ascending: true); // Ordenar por nome, por exemplo

      // Supabase < 2.0.0 retornava `response.data`
      // Supabase >= 2.0.0 retorna diretamente a lista no `response` se não houver erro.
      // A checagem de erro implícita é que se `response` não for uma lista, algo deu errado
      // ou a API mudou. O SDK atual lança exceção em caso de erro de select.
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Customer.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // TODO: Adicionar logging mais robusto ou um sistema de tratamento de erro específico
      print('Erro em fetchCustomers: $e');
      rethrow; // Re-lança a exceção para ser tratada pela camada de apresentação/provider
    }
  }

  // Adicionar um novo cliente
  // O Supabase geralmente gera o 'id' e 'created_at'
  Future<Customer> addCustomer(Customer customer) async {
    try {
      // O método toJson() no Customer model deve omitir 'id' e 'created_at'
      // ou campos que são gerados pelo banco.
      final Map<String, dynamic> customerData = customer.toJson();

      // Remover campos que não devem ser enviados na criação, se ainda presentes no toJson por engano
      customerData.remove('id');
      customerData.remove('created_at');

      final List<dynamic> response = await _supabaseClient
          .from(_tableName)
          .insert(customerData)
          .select(); // .select() retorna o registro inserido

      if (response.isEmpty) {
        throw Exception('Falha ao adicionar cliente: Nenhum dado retornado.');
      }
      // O Supabase retorna uma lista, pegamos o primeiro (e único) item.
      return Customer.fromJson(response.first as Map<String, dynamic>);
    } catch (e) {
      print('Erro em addCustomer: $e');
      rethrow;
    }
  }

  // Atualizar um cliente existente
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      // O toJson deve idealmente preparar os dados corretamente para atualização.
      // Não se deve atualizar 'id' ou 'created_at'.
      final Map<String, dynamic> customerData = customer.toJson();
      customerData.remove('created_at'); // Garante que created_at não seja enviado para update

      final List<dynamic> response = await _supabaseClient
          .from(_tableName)
          .update(customerData)
          .eq('id', customer.id) // Condição para qual cliente atualizar
          .select();

      if (response.isEmpty) {
        throw Exception('Falha ao atualizar cliente ou cliente não encontrado.');
      }
      return Customer.fromJson(response.first as Map<String, dynamic>);
    } catch (e) {
      print('Erro em updateCustomer: $e');
      rethrow;
    }
  }

  // Deletar um cliente pelo ID
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _supabaseClient
          .from(_tableName)
          .delete()
          .eq('id', customerId); // Condição para qual cliente deletar

      // O método delete não retorna o objeto deletado por padrão no Supabase.
      // Se a linha não existir, ele não lança erro, apenas não deleta nada.
      // Poderíamos adicionar um .select() antes do delete para verificar se existe, se necessário.
    } catch (e) {
      print('Erro em deleteCustomer: $e');
      rethrow;
    }
  }
}
