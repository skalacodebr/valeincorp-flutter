import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/imovel.dart';

class MapWidget extends StatelessWidget {
  final Coordenadas? coordenadas;
  final String? endereco;
  final double height;

  const MapWidget({
    super.key,
    this.coordenadas,
    this.endereco,
    this.height = 200,
  });

  Future<void> _abrirNoGoogleMaps() async {
    String url;
    
    if (coordenadas != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${coordenadas!.latitude},${coordenadas!.longitude}';
    } else if (endereco != null && endereco!.isNotEmpty) {
      final query = Uri.encodeComponent(endereco!);
      url = 'https://www.google.com/maps/search/?api=1&query=$query';
    } else {
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _abrirNoGoogleMaps,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // Map placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.map,
                      size: 32,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toque para ver no mapa',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Open button
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Google Maps',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnderecoCard extends StatelessWidget {
  final Endereco endereco;
  final Coordenadas? coordenadas;

  const EnderecoCard({
    super.key,
    required this.endereco,
    this.coordenadas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Endereço',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEnderecoRow('Logradouro', endereco.logradouro),
          _buildEnderecoRow('Bairro', endereco.bairro),
          _buildEnderecoRow('Cidade', endereco.cidade),
          _buildEnderecoRow('Estado', endereco.estado),
          _buildEnderecoRow('CEP', endereco.cep),
          if (endereco.complemento != null && endereco.complemento!.isNotEmpty)
            _buildEnderecoRow('Complemento', endereco.complemento!),
          const SizedBox(height: 16),
          MapWidget(
            coordenadas: coordenadas,
            endereco: endereco.enderecoCompleto,
          ),
        ],
      ),
    );
  }

  Widget _buildEnderecoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

