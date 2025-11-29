import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../config/theme.dart';
import '../models/imovel_detalhes.dart';

// Import condicional - só importa PDFView se não for web
// No web, sempre abrimos no navegador, então não precisamos do plugin
import 'pdf_viewer_native.dart' if (dart.library.html) 'pdf_viewer_web.dart';

class DocumentoViewer extends StatefulWidget {
  final Documento documento;

  const DocumentoViewer({
    super.key,
    required this.documento,
  });

  @override
  State<DocumentoViewer> createState() => _DocumentoViewerState();
}

class _DocumentoViewerState extends State<DocumentoViewer> {
  bool _loading = true;
  String? _localPath;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  dynamic _pdfViewController; // PDFViewController quando não for web

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // No web, sempre abrir no navegador
      if (kIsWeb) {
        await _openInBrowser();
        return;
      }

      // Se for PDF e não for web, baixar e visualizar localmente
      if (widget.documento.isPdf) {
        await _downloadAndViewPdf();
      } else {
        // Para outros tipos, apenas abrir no navegador
        await _openInBrowser();
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar documento: $e';
        _loading = false;
      });
    }
  }

  Future<void> _downloadAndViewPdf() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        widget.documento.arquivoUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = widget.documento.nomeOriginal ?? 
          'documento_${widget.documento.id}.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() {
        _localPath = filePath;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao baixar PDF: $e';
        _loading = false;
      });
    }
  }

  Future<void> _openInBrowser() async {
    final url = Uri.parse(widget.documento.arquivoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (kIsWeb) {
        // No web, fecha o modal após abrir
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      setState(() {
        _error = 'Não foi possível abrir o documento';
        _loading = false;
      });
    }
  }

  Future<void> _downloadFile() async {
    try {
      if (widget.documento.isPdf && _localPath != null && !kIsWeb) {
        await Share.shareXFiles(
          [XFile(_localPath!)],
          text: widget.documento.nomeOriginal ?? 'Documento',
        );
      } else {
        // Para outros tipos ou web, abrir no navegador para download
        final url = Uri.parse(widget.documento.arquivoUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.documento.nomeOriginal ?? widget.documento.tipoDocumento.nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadFile,
              tooltip: 'Baixar/Compartilhar',
            ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _openInBrowser(),
            tooltip: 'Abrir no navegador',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: 16),
            Text('Carregando documento...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDocument,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // No web, sempre mostrar opção de abrir no navegador
    if (kIsWeb) {
      return _buildWebFallback();
    }

    // Se for PDF e tiver caminho local (e não for web), mostrar visualizador
    if (widget.documento.isPdf && _localPath != null) {
      return _buildPdfViewer();
    }

    // Para outros tipos, mostrar opção de abrir no navegador
    return _buildWebFallback();
  }

  Widget _buildPdfViewer() {
    // Só funciona em plataformas nativas (não web)
    if (kIsWeb) {
      return _buildWebFallback();
    }

    // Usar PDFView apenas em plataformas nativas
    return Column(
      children: [
        // Controles de navegação
        if (_totalPages > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0 && _pdfViewController != null
                      ? () {
                          // Navegação será feita pelo PDFView
                        }
                      : null,
                ),
                Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages - 1 && _pdfViewController != null
                      ? () {
                          // Navegação será feita pelo PDFView
                        }
                      : null,
                ),
              ],
            ),
          ),
        // Visualizador PDF (só funciona em Android/iOS)
        Expanded(
          child: _buildNativePdfViewer(),
        ),
      ],
    );
  }

  Widget _buildNativePdfViewer() {
    if (kIsWeb) {
      return _buildWebFallback();
    }

    // Usar NativePdfViewer que funciona apenas em plataformas nativas
    return NativePdfViewer(
      filePath: _localPath!,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
          _isReady = true;
        });
      },
      onError: (error) {
        setState(() {
          _error = 'Erro ao carregar PDF: $error';
        });
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
          _totalPages = total ?? 0;
        });
      },
      onViewCreated: (controller) {
        _pdfViewController = controller;
      },
    );
  }

  Widget _buildWebFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.documento.isPdf 
                  ? Icons.picture_as_pdf 
                  : widget.documento.isImage 
                      ? Icons.image 
                      : Icons.description,
              size: 64,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              widget.documento.nomeOriginal ?? widget.documento.tipoDocumento.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.documento.tamanhoFormatado.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.documento.tamanhoFormatado,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 24),
            if (kIsWeb)
              const Text(
                'Clique no botão abaixo para abrir o documento no navegador.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: Text(kIsWeb ? 'Abrir no navegador' : 'Abrir no navegador'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

