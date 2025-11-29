import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 0,
  );

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formata valor como moeda (R$ 1.234,56)
  static String currency(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata valor como moeda compacta (R$ 1,2M)
  static String compactCurrency(double value) {
    return _compactCurrencyFormat.format(value);
  }

  /// Formata data (01/01/2024)
  static String date(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formata data e hora (01/01/2024 14:30)
  static String dateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Formata área (123 m²)
  static String area(double value) {
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} m²';
  }

  /// Formata telefone ((11) 99999-9999)
  static String phone(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7)}';
    } else if (numbers.length == 10) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6)}';
    }
    return value;
  }

  /// Formata CPF (123.456.789-01)
  static String cpf(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    if (numbers.length == 11) {
      return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9)}';
    }
    return value;
  }

  /// Formata CNPJ (12.345.678/0001-90)
  static String cnpj(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    if (numbers.length == 14) {
      return '${numbers.substring(0, 2)}.${numbers.substring(2, 5)}.${numbers.substring(5, 8)}/${numbers.substring(8, 12)}-${numbers.substring(12)}';
    }
    return value;
  }

  /// Formata CEP (12345-678)
  static String cep(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    if (numbers.length == 8) {
      return '${numbers.substring(0, 5)}-${numbers.substring(5)}';
    }
    return value;
  }

  /// Remove formatação de moeda e retorna valor numérico
  static double? parseCurrency(String value) {
    if (value.isEmpty) return null;
    final numbers = value.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.');
    return double.tryParse(numbers);
  }

  /// Formata porcentagem (75%)
  static String percentage(double value) {
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}%';
  }

  /// Pluraliza texto
  static String pluralize(int count, String singular, String plural) {
    return count == 1 ? '$count $singular' : '$count $plural';
  }

  /// Formata contagem de unidades
  static String unidades(int count) {
    return pluralize(count, 'unidade', 'unidades');
  }

  /// Formata contagem de quartos
  static String quartos(int count) {
    return pluralize(count, 'quarto', 'quartos');
  }

  /// Formata contagem de vagas
  static String vagas(int count) {
    return pluralize(count, 'vaga', 'vagas');
  }
}

