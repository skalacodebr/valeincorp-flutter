import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class ClickTrackingService {
  final ApiService _apiService = ApiService();

  /// Registra um clique de compartilhamento
  /// 
  /// [entityType] - Tipo da entidade: 'empreendimento' ou 'unidade'
  /// [entityId] - ID da entidade compartilhada
  /// [sharePlatform] - Plataforma de compartilhamento: 'whatsapp', 'link', 'facebook', 'twitter', 'instagram'
  Future<ApiResponse<void>> trackShare({
    required String entityType,
    required int entityId,
    String? sharePlatform,
  }) async {
    try {
      final data = <String, dynamic>{
        'entity_type': entityType,
        'entity_id': entityId,
        'action_type': 'share',
      };

      if (sharePlatform != null) {
        data['share_platform'] = sharePlatform;
      }

      final response = await _apiService.post(
        ApiConfig.clickTrackingTrack,
        data: data,
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Compartilhamento rastreado com sucesso',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao rastrear compartilhamento',
      );
    } catch (e) {
      debugPrint('[ClickTrackingService] Erro ao rastrear compartilhamento: $e');
      // Não falhar o compartilhamento se o tracking falhar
      // Apenas logar o erro
      return ApiResponse(
        success: false,
        message: 'Erro ao rastrear compartilhamento: $e',
      );
    }
  }

  /// Registra uma visualização
  /// 
  /// [entityType] - Tipo da entidade: 'empreendimento' ou 'unidade'
  /// [entityId] - ID da entidade visualizada
  Future<ApiResponse<void>> trackView({
    required String entityType,
    required int entityId,
  }) async {
    try {
      final data = <String, dynamic>{
        'entity_type': entityType,
        'entity_id': entityId,
        'action_type': 'view',
      };

      final response = await _apiService.post(
        ApiConfig.clickTrackingTrack,
        data: data,
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Visualização rastreada com sucesso',
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Erro ao rastrear visualização',
      );
    } catch (e) {
      debugPrint('[ClickTrackingService] Erro ao rastrear visualização: $e');
      // Não falhar a visualização se o tracking falhar
      return ApiResponse(
        success: false,
        message: 'Erro ao rastrear visualização: $e',
      );
    }
  }
}

