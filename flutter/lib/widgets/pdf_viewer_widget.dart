import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final fileName = widget.pdfUrl.split('/').last;
      final filePath = '${dir.path}/$fileName';

      await dio.download(widget.pdfUrl, filePath);

      if (mounted) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar o documento';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sharePDF() async {
    if (_localPath != null) {
      await Share.shareXFiles(
        [XFile(_localPath!)],
        text: widget.title,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          if (_localPath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePDF,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGold),
            SizedBox(height: 16),
            Text('Carregando documento...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadPDF,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          preventLinkNavigation: false,
          onRender: (pages) {
            setState(() {
              _totalPages = pages ?? 0;
            });
          },
          onError: (error) {
            setState(() {
              _error = error.toString();
            });
          },
          onPageError: (page, error) {
            // Handle page error
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              _currentPage = page ?? 0;
            });
          },
        ),
        
        // Page indicator
        if (_totalPages > 0)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

void showPDFViewer(BuildContext context, String pdfUrl, String title) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFViewerScreen(
        pdfUrl: pdfUrl,
        title: title,
      ),
    ),
  );
}

