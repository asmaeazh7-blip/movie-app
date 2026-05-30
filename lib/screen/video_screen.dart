import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────
//  VIDEO SCREEN
// ─────────────────────────────────────────────
class VideoScreen extends StatefulWidget {
  const VideoScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  final String videoUrl;
  final String title;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    await _controller.initialize();
    _controller.play();
    setState(() {});

    // خبي controls بعد 3 ثواني
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    // رجع orientation عادي
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Player
            GestureDetector(
              onTap: _toggleControls,
              child: Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: _controller.value.isInitialized
                      ? _controller.value.aspectRatio
                      : 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ── Video
                      if (_controller.value.isInitialized)
                        VideoPlayer(_controller)
                      else
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC9A76C),
                          ),
                        ),

                      // ── Controls overlay
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              // ── Top bar
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── Center play/pause
                              const Spacer(),
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 2),
                                  ),
                                  child: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // ── Bottom: progress + time + fullscreen
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    12, 0, 12, 10),
                                child: Column(
                                  children: [
                                    // Progress bar
                                    _controller.value.isInitialized
                                        ? VideoProgressIndicator(
                                            _controller,
                                            allowScrubbing: true,
                                            colors: const VideoProgressColors(
                                              playedColor: Color(0xFFE8435A),
                                              bufferedColor: Colors.white30,
                                              backgroundColor: Colors.white12,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    const SizedBox(height: 6),
                                    // Time + fullscreen
                                    Row(
                                      children: [
                                        Text(
                                          _controller.value.isInitialized
                                              ? _formatDuration(
                                                  _controller.value.position)
                                              : '00:00',
                                          style: GoogleFonts.spaceMono(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          ' / ',
                                          style: GoogleFonts.spaceMono(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          _controller.value.isInitialized
                                              ? _formatDuration(
                                                  _controller.value.duration)
                                              : '00:00',
                                          style: GoogleFonts.spaceMono(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: _toggleFullscreen,
                                          child: Icon(
                                            _isFullscreen
                                                ? Icons.fullscreen_exit_rounded
                                                : Icons.fullscreen_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),

            // ── Info below player (portrait only)
            if (!_isFullscreen)
              Expanded(
                child: Container(
                  color: const Color(0xFF0D0D0D),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress info
                      if (_controller.value.isInitialized)
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (_, value, __) {
                            final pos = value.position.inSeconds;
                            final dur = value.duration.inSeconds;
                            final progress =
                                dur > 0 ? pos / dur : 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.1),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFE8435A)),
                                    minHeight: 4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                  style: GoogleFonts.spaceMono(
                                    color: const Color(0xFF777777),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
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