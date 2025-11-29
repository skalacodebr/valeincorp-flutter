import 'package:flutter/material.dart';

/// Widget stub para web - sempre mostra mensagem para abrir no navegador
class NativePdfViewer extends StatelessWidget {
  final String filePath;
  final void Function(int?)? onRender;
  final void Function(dynamic)? onError;
  final void Function(int?, int?)? onPageChanged;
  final void Function(dynamic)? onViewCreated;

  const NativePdfViewer({
    super.key,
    required this.filePath,
    required this.onRender,
    required this.onError,
    required this.onPageChanged,
    this.onViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    // No web, não podemos visualizar PDF inline
    // Este widget nunca deve ser chamado no web
    return const Center(
      child: Text('Visualização de PDF não disponível no navegador'),
    );
  }
}

