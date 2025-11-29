class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, List<String>>? errors;
  final Pagination? pagination;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      message: json['message'],
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List<dynamic>).map((e) => e.toString()).toList(),
              ),
            )
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;

  String get firstError {
    if (errors == null || errors!.isEmpty) return message ?? 'Erro desconhecido';
    final firstEntry = errors!.entries.first;
    return firstEntry.value.isNotEmpty 
        ? firstEntry.value.first 
        : message ?? 'Erro desconhecido';
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? json['current_page'] ?? 1,
      totalPages: json['totalPages'] ?? json['total_pages'] ?? 1,
      totalItems: json['totalItems'] ?? json['total_items'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? json['items_per_page'] ?? 20,
      hasNextPage: json['hasNextPage'] ?? json['has_next_page'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? json['has_previous_page'] ?? false,
    );
  }
}

