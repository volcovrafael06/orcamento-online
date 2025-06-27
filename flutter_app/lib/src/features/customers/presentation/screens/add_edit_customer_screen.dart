import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persifix_app/src/features/customers/domain/customer.dart';
import 'package:persifix_app/src/features/customers/presentation/providers/customer_providers.dart';
import 'package:go_router/go_router.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final String? customerId; // Null para modo 'Adicionar', preenchido para modo 'Editar'

  const AddEditCustomerScreen({super.key, this.customerId});

  @override
  ConsumerState<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos do formulário
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cpfCnpjController;
  late TextEditingController _inscricaoEstadualController;
  String? _tipoPessoaValue; // Para o DropdownButtonFormField

  Customer? _editingCustomer; // Cliente que está sendo editado, se houver

  bool get _isEditMode => widget.customerId != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cpfCnpjController = TextEditingController();
    _inscricaoEstadualController = TextEditingController();

    if (_isEditMode) {
      // Tenta carregar os dados do cliente que está sendo editado
      // Idealmente, o selectedCustomerProvider já teria sido atualizado antes de navegar para esta tela.
      // Ou, poderíamos buscar o cliente aqui se ele não estiver disponível.
      _editingCustomer = ref.read(selectedCustomerProvider);

      if (_editingCustomer != null) {
        _nameController.text = _editingCustomer!.name;
        _emailController.text = _editingCustomer!.email ?? '';
        _phoneController.text = _editingCustomer!.phone ?? '';
        _addressController.text = _editingCustomer!.address ?? '';
        _cpfCnpjController.text = _editingCustomer!.cpfCnpj ?? '';
        _inscricaoEstadualController.text = _editingCustomer!.inscricaoEstadual ?? '';
        _tipoPessoaValue = _editingCustomer!.tipoPessoa;
      } else {
        // Se o cliente não for encontrado no provider (ex: refresh da página, deep link)
        // Poderíamos adicionar uma lógica para buscar o cliente pelo ID aqui usando um FutureProvider
        // ou mostrar uma mensagem de erro/voltar. Por enquanto, deixaremos os campos vazios.
        // Ou, melhor, o selectedCustomerProvider poderia ser um AsyncValue e lidaríamos com o estado de carregamento aqui.
        // Para simplificar este passo, assumimos que selectedCustomerProvider tem o valor correto.
        print("AVISO: Cliente para edição não encontrado no provider. Campos podem estar vazios.");
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cpfCnpjController.dispose();
    _inscricaoEstadualController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Salva os valores dos FormFields

      final customerNotifier = ref.read(customerListNotifierProvider.notifier);
      final scaffoldMessenger = ScaffoldMessenger.of(context); // Para mostrar SnackBars
      final router = GoRouter.of(context); // Para navegação

      // Criar o objeto Customer com os dados do formulário
      // Se estiver editando, use o ID existente, senão, o Supabase irá gerar um novo ID.
      // 'id' e 'createdAt' não são definidos aqui para novos clientes.
      // Para clientes existentes, o 'id' vem de _editingCustomer.id
      // e 'createdAt' vem de _editingCustomer.createdAt
      final customerToSave = Customer(
        id: _isEditMode ? _editingCustomer!.id : '', // ID é importante para update
        name: _nameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        cpfCnpj: _cpfCnpjController.text.isNotEmpty ? _cpfCnpjController.text : null,
        inscricaoEstadual: _inscricaoEstadualController.text.isNotEmpty ? _inscricaoEstadualController.text : null,
        tipoPessoa: _tipoPessoaValue,
        createdAt: _isEditMode ? _editingCustomer?.createdAt : null, // Preserva o createdAt original
      );

      // Indicar carregamento
      ref.read(customerOperationLoadingProvider.notifier).state = true;

      try {
        if (_isEditMode) {
          await customerNotifier.updateCustomer(customerToSave);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Cliente atualizado com sucesso!')),
          );
        } else {
          await customerNotifier.addCustomer(customerToSave);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Cliente adicionado com sucesso!')),
          );
        }
        // Após salvar, volta para a tela de lista de clientes
        if (router.canPop()) {
          router.pop();
        } else {
          // Se não puder dar pop (ex: deep link direto para esta tela), vá para a lista
          router.go('/customers');
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erro ao salvar cliente: ${e.toString()}')),
        );
      } finally {
        ref.read(customerOperationLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(customerOperationLoadingProvider);
    // Se estiver em modo de edição e _editingCustomer for null após initState,
    // pode ser que o `selectedCustomerProvider` ainda não tenha resolvido.
    // Uma abordagem mais robusta seria usar `ref.watch(selectedCustomerProvider)` aqui
    // e lidar com seus estados de carregamento/erro para popular o formulário.
    // Para este exemplo, estamos simplificando.

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Cliente' : 'Adicionar Cliente'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome Completo / Razão Social*'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tipoPessoaValue,
                      decoration: const InputDecoration(labelText: 'Tipo de Pessoa'),
                      items: ['FISICA', 'JURIDICA']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label == 'FISICA' ? 'Física' : 'Jurídica'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoPessoaValue = value;
                        });
                      },
                      // validator: (value) => value == null ? 'Campo obrigatório' : null, // Se for obrigatório
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cpfCnpjController,
                      decoration: const InputDecoration(labelText: 'CPF / CNPJ'),
                      keyboardType: TextInputType.number,
                      // Adicionar máscara ou validação específica de CPF/CNPJ se necessário
                    ),
                    const SizedBox(height: 16),
                     TextFormField(
                      controller: _inscricaoEstadualController,
                      decoration: const InputDecoration(labelText: 'Inscrição Estadual / RG'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !value.contains('@')) {
                          return 'Email inválido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Endereço'),
                      keyboardType: TextInputType.streetAddress,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0)
                      ),
                      child: Text(_isEditMode ? 'Salvar Alterações' : 'Adicionar Cliente'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
