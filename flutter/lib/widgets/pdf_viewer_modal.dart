import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/syncfusion_flutter_pdfviewer.dart';
import '../config/theme.dart';

class PDFViewerModal extends StatefulWidget {
  final String url;
  final String? title;

  const PDFViewerModal({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<PDFViewerModal> createState() => _PDFViewerModalState();
}

class _PDFViewerModalState extends State<PDFViewerModal> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pdfViewerController.jumpToPage(page);
    }
  }

  void _zoomIn() {
    final currentZoom = _pdfViewerController.zoomLevel;
    _pdfViewerController.zoomLevel = (currentZoom + 0.25).clamp(0.5, 4.0);
  }

  void _zoomOut() {
    final currentZoom = _pdfViewerController.zoomLevel;
    _pdfViewerController.zoomLevel = (currentZoom - 0.25).clamp(0.5, 4.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? 'Documento',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            onPressed: _zoomOut,
            tooltip: 'Reduzir zoom',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            onPressed: _zoomIn,
            tooltip: 'Aumentar zoom',
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF Viewer
          SfPdfViewer.network(
            widget.url,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            enableDoubleTapZooming: true,
            enableTextSelection: false,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
                _totalPages = details.document.pages.count;
              });
            },
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isLoading = false;
                _error = 'Erro ao carregar documento: ${details.error}';
              });
            },
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGold),
                  SizedBox(height: 16),
                  Text(
                    'Carregando documento...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Error message
          if (_error != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar documento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Bottom navigation bar
      bottomNavigationBar: !_isLoading && _error == null && _totalPages > 0
          ? Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous page
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    icon: Icon(
                      Icons.chevron_left,
                      color: _currentPage > 1
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),

                  // Page indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Página $_currentPage de $_totalPages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Next page
                  IconButton(
                    onPressed: _currentPage < _totalPages
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                    icon: Icon(
                      Icons.chevron_right,
                      color: _currentPage < _totalPages
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

void showPDFViewer(BuildContext context, String url, {String? title}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDFViewerModal(
        url: url,
        title: title,
      ),
    ),
  );
}

