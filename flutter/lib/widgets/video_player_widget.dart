import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../config/theme.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool autoPlay;
  final bool isFullScreen;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.title,
    this.autoPlay = false,
    this.isFullScreen = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.autoPlay) {
          _controller.play();
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _openFullScreen() {
    _controller.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoUrl: widget.videoUrl,
          title: widget.title,
          initialPosition: _controller.value.position,
        ),
      ),
    ).then((_) {
      // Quando voltar da tela cheia, reinicializar o vídeo
      if (mounted) {
        _controller.seekTo(_controller.value.position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          
          // Controls overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play/Pause button - abre em tela cheia ao clicar play
                  IconButton(
                    onPressed: () {
                      if (!_isPlaying && !widget.isFullScreen) {
                        // Se não está reproduzindo e não está em tela cheia, abre em tela cheia
                        _openFullScreen();
                      } else {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      }
                    },
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botão de tela cheia (canto inferior direito)
          if (_showControls && !widget.isFullScreen)
            Positioned(
              bottom: 50,
              right: 8,
              child: IconButton(
                onPressed: _openFullScreen,
                icon: const Icon(
                  Icons.fullscreen,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
          
          // Progress bar
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(_controller.value.position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value: _controller.value.position.inMilliseconds.toDouble(),
                        min: 0,
                        max: _controller.value.duration.inMilliseconds.toDouble(),
                        activeColor: AppColors.primaryGold,
                        inactiveColor: Colors.white.withOpacity(0.3),
                        onChanged: (value) {
                          _controller.seekTo(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Full screen video player com suporte a rotação
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final Duration? initialPosition;

  const FullScreenVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.initialPosition,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Permitir todas as orientações ao entrar na tela cheia
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Esconder a barra de status e navegação para experiência imersiva
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Ir para posição inicial se fornecida
        if (widget.initialPosition != null) {
          await _controller.seekTo(widget.initialPosition!);
        }
        // Auto-play ao abrir em tela cheia
        _controller.play();
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Restaurar orientação para apenas retrato ao sair
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Restaurar barras do sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _closeFullScreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() => _showControls = !_showControls);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video
              if (_isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                ),

              // Título no topo
              if (_showControls && widget.title != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 60,
                  child: Text(
                    widget.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Botão fechar
              if (_showControls)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: _closeFullScreen,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

              // Play/Pause central
              if (_showControls && _isInitialized)
                Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 70,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),

              // Progress bar e controles inferiores
              if (_showControls && _isInitialized)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        Expanded(
                          child: Slider(
                            value: _controller.value.position.inMilliseconds.toDouble(),
                            min: 0,
                            max: _controller.value.duration.inMilliseconds.toDouble(),
                            activeColor: AppColors.primaryGold,
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) {
                              _controller.seekTo(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        // Botão para sair da tela cheia
                        IconButton(
                          onPressed: _closeFullScreen,
                          icon: const Icon(
                            Icons.fullscreen_exit,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void showVideoPlayer(BuildContext context, String videoUrl, {String? title}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullScreenVideoPlayer(
        videoUrl: videoUrl,
        title: title,
      ),
    ),
  );
}
