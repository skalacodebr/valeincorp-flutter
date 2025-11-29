import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// Widget para visualizar PDF em plataformas nativas (Android/iOS)
class NativePdfViewer extends StatelessWidget {
  final String filePath;
  final Function(int?) onRender;
  final void Function(dynamic) onError;
  final Function(int?, int?) onPageChanged;
  final Function(dynamic)? onViewCreated;

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
    return PDFView(
      filePath: filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: onRender,
      onError: onError,
      onPageError: (page, error) {
        onError('Erro na página $page: $error');
      },
      onViewCreated: onViewCreated != null 
          ? (PDFViewController controller) => onViewCreated!(controller)
          : null,
      onLinkHandler: (String? uri) {
        // Tratar links no PDF se necessário
      },
      onPageChanged: onPageChanged,
    );
  }
}

