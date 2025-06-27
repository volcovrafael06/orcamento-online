import 'package:flutter/foundation.dart';

@immutable
class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final String? cpfCnpj;
  final String? inscricaoEstadual;
  final String? tipoPessoa; // Ex: 'FISICA', 'JURIDICA'

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.cpfCnpj,
    this.inscricaoEstadual,
    this.tipoPessoa,
  });

  // Construtor factory para criar a partir de JSON (vindo do Supabase)
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      cpfCnpj: json['cpf_cnpj'] as String?,
      inscricaoEstadual: json['inscricao_estadual'] as String?,
      tipoPessoa: json['tipo_pessoa'] as String?,
    );
  }

  // Método para converter para JSON (para enviar ao Supabase)
  // Nota: 'id' e 'created_at' geralmente não são enviados ao criar/atualizar,
  // pois são gerenciados pelo banco de dados. Ajuste conforme necessário.
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Geralmente não enviado explicitamente ao criar/atualizar
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      // 'created_at': createdAt?.toIso8601String(), // Geralmente não enviado
      'cpf_cnpj': cpfCnpj,
      'inscricao_estadual': inscricaoEstadual,
      'tipo_pessoa': tipoPessoa,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    bool setPhoneNull = false,
    String? address,
    bool setAddressNull = false,
    DateTime? createdAt,
    bool setCreatedAtNull = false,
    String? cpfCnpj,
    bool setCpfCnpjNull = false,
    String? inscricaoEstadual,
    bool setInscricaoEstadualNull = false,
    String? tipoPessoa,
    bool setTipoPessoaNull = false,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email, // Para Strings, passar null diretamente funciona
      phone: setPhoneNull ? null : (phone ?? this.phone),
      address: setAddressNull ? null : (address ?? this.address),
      createdAt: setCreatedAtNull ? null : (createdAt ?? this.createdAt),
      cpfCnpj: setCpfCnpjNull ? null : (cpfCnpj ?? this.cpfCnpj),
      inscricaoEstadual: setInscricaoEstadualNull ? null : (inscricaoEstadual ?? this.inscricaoEstadual),
      tipoPessoa: setTipoPessoaNull ? null : (tipoPessoa ?? this.tipoPessoa),
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, email: $email, phone: $phone, address: $address, createdAt: $createdAt, cpfCnpj: $cpfCnpj, inscricaoEstadual: $inscricaoEstadual, tipoPessoa: $tipoPessoa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Customer &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.address == address &&
        other.createdAt == createdAt &&
        other.cpfCnpj == cpfCnpj &&
        other.inscricaoEstadual == inscricaoEstadual &&
        other.tipoPessoa == tipoPessoa;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        createdAt.hashCode ^
        cpfCnpj.hashCode ^
        inscricaoEstadual.hashCode ^
        tipoPessoa.hashCode;
  }
}

// Helper para ValueGetter no copyWith para campos anuláveis
// Isso permite diferenciar entre não fornecer um valor (manter o antigo)
// e fornecer explicitamente `null`.
class ValueGetter<T> {
  final T Function() _value;
  ValueGetter(this._value);
  T call() => _value();
}
