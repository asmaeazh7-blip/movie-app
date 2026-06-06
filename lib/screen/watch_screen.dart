import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({
    super.key,
    required this.seriesName,
    required this.episodeName,
    required this.episodeNumber,
    required this.seasonNumber,
  });

  final String seriesName;
  final String episodeName;
  final int episodeNumber;
  final int seasonNumber;

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  int _progress = 0;
  bool _isFullscreen = false;

  static const _bg     = Color(0xFF0D0D0D);
  static const _accent = Color(0xFFE8435A);
  static const _card2  = Color(0xFF222222);
  static const _sub    = Color(0xFF888888);
  static const _wine   = Color(0xFF662549);

  String get _searchUrl {
    final ep = widget.episodeNumber.toString().padLeft(2, '0');
    final q  = Uri.encodeQueryComponent(
      '${widget.seriesName} الحلقة $ep الموسم ${widget.seasonNumber}',
    );
    return 'https://wecima.cx/?s=$q';
  }

  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,   // autoplay video
    allowsInlineMediaPlayback: true,           // inline (not fullscreen-forced)
    useWideViewPort: true,
    loadWithOverviewMode: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    supportMultipleWindows: false,
    allowsBackForwardNavigationGestures: true,
    userAgent:
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Mobile Safari/537.36',
  );

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: !_isFullscreen,
        bottom: !_isFullscreen,
        child: Column(
          children: [
            // ── Top bar
            if (!_isFullscreen)
              Container(
                height: 56,
                color: _bg,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () async {
                        if (await _webViewController?.canGoBack() ?? false) {
                          _webViewController?.goBack();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.seriesName,
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'E${widget.episodeNumber.toString().padLeft(2, '0')} — ${widget.episodeName}',
                            style: GoogleFonts.spaceMono(
                                color: _sub, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () => _webViewController?.reload(),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                ),
              ),

            // ── Progress bar
            if (_isLoading)
              LinearProgressIndicator(
                value: _progress / 100,
                backgroundColor: _card2,
                color: _accent,
                minHeight: 2,
              ),

            // ── WebView
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(_searchUrl),
                ),
                initialSettings: _settings,
                onWebViewCreated: (c) => _webViewController = c,
                onLoadStart: (_, __) =>
                    setState(() => _isLoading = true),
                onLoadStop: (_, __) =>
                    setState(() => _isLoading = false),
                onProgressChanged: (_, p) =>
                    setState(() => _progress = p),
                // Handle new windows / popups inline
                onCreateWindow: (c, req) async {
                  _webViewController?.loadUrl(
                    urlRequest: req.request,
                  );
                  return true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}