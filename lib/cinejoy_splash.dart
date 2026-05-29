import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/onboarding_screen.dart';



class CineJoyApp extends StatelessWidget {
  const CineJoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineJoy',
      home: SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  SPLASH SCREEN
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // One controller per falling letter + scene
  late final AnimationController _sceneCtrl;
  late final AnimationController _eCtrl;
  late final AnimationController _jCtrl;
  late final AnimationController _oCtrl;
  late final AnimationController _yCtrl;
  late final AnimationController _flickerCtrl;

  // Scene (TV + CIN) fade-in
  late final Animation<double> _sceneOpacity;
  late final Animation<Offset> _sceneSlide;

  // E letter
  late final Animation<double> _eOpacity;
  late final Animation<double> _eRotation;
  late final Animation<Offset> _eSlide;

  // J letter
  late final Animation<double> _jOpacity;
  late final Animation<double> _jRotation;
  late final Animation<Offset> _jSlide;

  // O letter
  late final Animation<double> _oOpacity;
  late final Animation<double> _oRotation;
  late final Animation<Offset> _oSlide;

  // Y letter
  late final Animation<double> _yOpacity;
  late final Animation<double> _yRotation;
  late final Animation<Offset> _ySlide;

  // Flicker
  late final Animation<double> _flickerOpacity;

  @override
  void initState() {
    super.initState();
    const curve = Cubic(0.15, 1.0, 0.3, 1.0);
    const dur = Duration(milliseconds: 1100);

    // ── Scene ──
    _sceneCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _sceneOpacity = CurvedAnimation(parent: _sceneCtrl, curve: Curves.easeOut);
    _sceneSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sceneCtrl, curve: Curves.easeOut));
    _sceneCtrl.forward();

    // ── E (delay 0.3s) ──
    _eCtrl = AnimationController(vsync: this, duration: dur);
    _eOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_eCtrl);
    _eRotation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: -65.0, end: 8.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 6.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 9.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _eCtrl, curve: curve));
    _eSlide = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: const Offset(0, -0.7), end: const Offset(0, 0.05)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: const Offset(0, 0.05), end: const Offset(0, -0.02)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: const Offset(0, -0.02), end: Offset.zero), weight: 25),
    ]).animate(CurvedAnimation(parent: _eCtrl, curve: curve));
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _eCtrl.forward(); });

    // ── J (delay 1.6s) ──
    _jCtrl = AnimationController(vsync: this, duration: dur);
    _jOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_jCtrl);
    _jRotation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 180.0 - 40.0, end: 183.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 183.0, end: 179.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 179.0, end: 182.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _jCtrl, curve: curve));
    _jSlide = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.3, -0.4), end: const Offset(0.02, 0.04)), weight: 65),
      TweenSequenceItem(tween: Tween(begin: const Offset(0.02, 0.04), end: const Offset(-0.01, -0.02)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: const Offset(-0.01, -0.02), end: Offset.zero), weight: 20),
    ]).animate(CurvedAnimation(parent: _jCtrl, curve: curve));
    Future.delayed(const Duration(milliseconds: 1600), () { if (mounted) _jCtrl.forward(); });

    // ── O (delay 2.9s) ──
    _oCtrl = AnimationController(vsync: this, duration: dur);
    _oOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_oCtrl);
    _oRotation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 160.0, end: 185.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 185.0, end: 178.0), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 178.0, end: 182.0), weight: 22),
    ]).animate(CurvedAnimation(parent: _oCtrl, curve: curve));
    _oSlide = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: const Offset(0, -0.6), end: const Offset(0, 0.05)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: const Offset(0, 0.05), end: const Offset(0, -0.02)), weight: 18),
      TweenSequenceItem(tween: Tween(begin: const Offset(0, -0.02), end: Offset.zero), weight: 22),
    ]).animate(CurvedAnimation(parent: _oCtrl, curve: curve));
    Future.delayed(const Duration(milliseconds: 2900), () { if (mounted) _oCtrl.forward(); });

    // ── Y (delay 4.2s) ──
    _yCtrl = AnimationController(vsync: this, duration: dur);
    _yOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_yCtrl);
    _yRotation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 195.0, end: 178.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 178.0, end: 183.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 183.0, end: 180.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _yCtrl, curve: curve));
    _ySlide = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: const Offset(0, -0.65), end: const Offset(0, 0.05)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: const Offset(0, 0.05), end: const Offset(0, -0.02)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: const Offset(0, -0.02), end: Offset.zero), weight: 25),
    ]).animate(CurvedAnimation(parent: _yCtrl, curve: curve));
    Future.delayed(const Duration(milliseconds: 4200), () {
      if (mounted) {
        _yCtrl.forward();
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 800),
                pageBuilder: (_, __, ___) => OnboardingScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          }
        });
      }
    });

    // ── Flicker (looping, 8s) ──
    _flickerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _flickerOpacity = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 93),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 5),
    ]).animate(_flickerCtrl);
  }

  @override
  void dispose() {
    _sceneCtrl.dispose();
    _eCtrl.dispose();
    _jCtrl.dispose();
    _oCtrl.dispose();
    _yCtrl.dispose();
    _flickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C0A2B),
      body: Stack(
        children: [
          // ── Vignette ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.16, 0.04),
                    radius: 0.75,
                    colors: [Colors.transparent, Color(0xB80C0209)],
                    stops: [0.30, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Flicker overlay ──
          AnimatedBuilder(
            animation: _flickerCtrl,
            builder: (_, __) => Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _flickerOpacity.value,
                  child: Container(color: const Color(0x06C9A76C)),
                ),
              ),
            ),
          ),

          // ── Main content: scene + fallen letters side by side ──
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: TV scene (CIN + TV + legs)
                FadeTransition(
                  opacity: _sceneOpacity,
                  child: SlideTransition(
                    position: _sceneSlide,
                    child: const _TvScene(),
                  ),
                ),

                const SizedBox(width: 8),

                // Right: fallen letters column
                SizedBox(
                  width: 90,
                  height: 440,
                  child: Stack(
                    children: [
                      // E — upper right, tilted
                      Positioned(
                        top: 20,
                        right: 0,
                        child: _FallenLetter(
                          letter: 'E',
                          fontSize: 118,
                          opacityAnim: _eOpacity,
                          rotationAnim: _eRotation,
                          slideAnim: _eSlide,
                          transformOrigin: Alignment.bottomRight,
                        ),
                      ),
                      // J — mid, upside-down
                      Positioned(
                        top: 160,
                        right: 4,
                        child: _FallenLetter(
                          letter: 'J',
                          fontSize: 90,
                          opacityAnim: _jOpacity,
                          rotationAnim: _jRotation,
                          slideAnim: _jSlide,
                        ),
                      ),
                      // O — lower mid
                      Positioned(
                        top: 270,
                        right: 6,
                        child: _FallenLetter(
                          letter: 'O',
                          fontSize: 90,
                          opacityAnim: _oOpacity,
                          rotationAnim: _oRotation,
                          slideAnim: _oSlide,
                        ),
                      ),
                      // Y — bottom
                      Positioned(
                        top: 370,
                        right: 2,
                        child: _FallenLetter(
                          letter: 'Y',
                          fontSize: 90,
                          opacityAnim: _yOpacity,
                          rotationAnim: _yRotation,
                          slideAnim: _ySlide,
                          transformOrigin: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FALLEN LETTER WIDGET
// ─────────────────────────────────────────────
class _FallenLetter extends StatelessWidget {
  const _FallenLetter({
    required this.letter,
    required this.fontSize,
    required this.opacityAnim,
    required this.rotationAnim,
    required this.slideAnim,
    this.transformOrigin = Alignment.center,
  });

  final String letter;
  final double fontSize;
  final Animation<double> opacityAnim;
  final Animation<double> rotationAnim; // degrees
  final Animation<Offset> slideAnim;    // fractional offset used as pixel-ish nudge
  final Alignment transformOrigin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([opacityAnim, rotationAnim, slideAnim]),
      builder: (_, __) {
        return Opacity(
          opacity: opacityAnim.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              slideAnim.value.dx * fontSize,
              slideAnim.value.dy * fontSize,
            ),
            child: Transform(
              alignment: transformOrigin,
              transform: Matrix4.rotationZ(rotationAnim.value * pi / 180),
              child: Text(
                letter,
                style: GoogleFonts.caveat(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  color: const Color(0xFFC9A76C),
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  TV SCENE  (CIN label + TV body + legs)
// ─────────────────────────────────────────────
class _TvScene extends StatelessWidget {
  const _TvScene();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CIN label
        Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 0),
          child: Text(
            'CIN',
            style: GoogleFonts.caveat(
              fontWeight: FontWeight.w700,
              fontSize: 94,
              color: const Color(0xFFC9A76C),
              height: 1.0,
              letterSpacing: 4,
            ),
          ),
        ),

        // TV body
        Container(
          width: 340,
          decoration: BoxDecoration(
            color: const Color(0xFF3D3D50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF4E4E64), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 48,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16).copyWith(right: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen column
              Expanded(
                child: Column(
                  children: [
                    // Screen
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF04040A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF14141E), width: 3),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Noise
                              const _NoiseCanvas(),
                              // Glitch lines
                              const _GlitchLines(),
                              // Badge
                              Positioned(
                                top: 8, left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'BACK\nFLADLY\nSECRETES',
                                    style: GoogleFonts.spaceMono(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 7.5,
                                      color: Colors.white,
                                      height: 1.6,
                                      letterSpacing: 0.04,
                                    ),
                                  ),
                                ),
                              ),
                              // Scanlines
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(painter: _ScanlinesPainter()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bottom strip
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A38),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF3A3A4C)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right control column
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    // Main dial
                    const _Dial(size: 32),
                    const SizedBox(height: 6),
                    // Speaker dots
                    SizedBox(
                      width: 28,
                      child: Wrap(
                        spacing: 4, runSpacing: 4,
                        children: List.generate(15, (_) => const _SpeakerDot()),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Channel buttons
                    ...List.generate(3, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Container(
                        width: 28, height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFF252530),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF35354A)),
                        ),
                      ),
                    )),
                    const Spacer(),
                    // Small dial
                    const _Dial(size: 22),
                  ],
                ),
              ),
            ],
          ),
        ),

        // TV Legs SVG via CustomPaint
        SizedBox(
          width: 340,
          height: 80,
          child: CustomPaint(painter: _LegsPainter()),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  DIAL WIDGET
// ─────────────────────────────────────────────
class _Dial extends StatelessWidget {
  const _Dial({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.28, -0.28),
          radius: 0.8,
          colors: [Color(0xFF7A7A8C), Color(0xFF2C2C3A)],
        ),
        border: Border.all(color: const Color(0xFF5A5A6E), width: 2),
      ),
      child: Center(
        child: Transform.rotate(
          angle: -30 * pi / 180,
          child: Container(
            width: size * 0.35, height: size * 0.1,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A26),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SPEAKER DOT
// ─────────────────────────────────────────────
class _SpeakerDot extends StatelessWidget {
  const _SpeakerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E2C),
        border: Border.all(color: const Color(0xFF2E2E3C)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NOISE CANVAS  (web-safe: CustomPainter + AnimationController)
// ─────────────────────────────────────────────
class _NoiseCanvas extends StatefulWidget {
  const _NoiseCanvas();

  @override
  State<_NoiseCanvas> createState() => _NoiseCanvasState();
}

class _NoiseCanvasState extends State<_NoiseCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: 0.20,
        child: CustomPaint(
          painter: _NoiseDirectPainter(_random),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _NoiseDirectPainter extends CustomPainter {
  _NoiseDirectPainter(this.random);
  final Random random;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1.5;
    final cols = (size.width / 3).ceil();
    final rows = (size.height / 3).ceil();
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final v = random.nextInt(256);
        paint.color = Color.fromARGB(180, v, v, v);
        canvas.drawRect(
          Rect.fromLTWH(x * 3.0, y * 3.0, 3, 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_NoiseDirectPainter _) => true;
}


// ─────────────────────────────────────────────
//  GLITCH LINES
// ─────────────────────────────────────────────
class _GlitchLines extends StatefulWidget {
  const _GlitchLines();

  @override
  State<_GlitchLines> createState() => _GlitchLinesState();
}

class _GlitchLinesState extends State<_GlitchLines>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _lines = [
    _Line(0.17, 0.78, Color(0xFFFF44F0), 6, 0),
    _Line(0.29, 1.00, Color(0xFF44F0FF), 6, 200),
    _Line(0.41, 0.60, Color(0xFFF0E044), 5, 500),
    _Line(0.54, 0.88, Color(0xFFFF4488), 6, 800),
    _Line(0.65, 0.52, Color(0xFF44FFAA), 5, 350),
    _Line(0.75, 0.72, Color(0xFF9944FF), 5, 1050),
    _Line(0.23, 0.33, Colors.white,      2, 1900),
    _Line(0.58, 0.25, Colors.white,      2, 2300),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _GlitchPainter(_lines, _ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Line {
  const _Line(this.top, this.width, this.color, this.height, this.delayMs);
  final double top, width;
  final Color color;
  final int height;
  final int delayMs;
}

class _GlitchPainter extends CustomPainter {
  _GlitchPainter(this.lines, this.t);
  final List<_Line> lines;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final l in lines) {
      // offset phase by delay
      final phase = (t + l.delayMs / 2500) % 1.0;
      double dx = 0;
      double op = 0.88;
      if (phase < 0.15)       { dx = -11 * sin(phase / 0.15 * pi); op = 1.0; }
      else if (phase < 0.35)  { dx =  8  * sin((phase-0.15)/0.2 * pi); op = 0.6; }
      else if (phase < 0.58)  { dx = -4  * sin((phase-0.35)/0.23 * pi); op = 0.9; }
      else if (phase < 0.80)  { dx =  6  * sin((phase-0.58)/0.22 * pi); op = 0.7; }

      final paint = Paint()
        ..color = l.color.withOpacity(op)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          dx,
          size.height * l.top,
          size.width * l.width,
          l.height.toDouble(),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GlitchPainter old) => old.t != t;
}

// ─────────────────────────────────────────────
//  SCANLINES PAINTER
// ─────────────────────────────────────────────
class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..style = PaintingStyle.fill;
    double y = 2;
    while (y < size.height) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), paint);
      y += 4;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
//  TV LEGS PAINTER
// ─────────────────────────────────────────────
class _LegsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, 76), width: 220, height: 14),
      shadowPaint,
    );

    void drawLeg({
      required double x, required double y,
      required double w, required double h,
      required double angleDeg, required Color color,
      required double footX, required double footY,
      required double footW, required double footH,
    }) {
      final angle = angleDeg * pi / 180;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final legPaint = Paint()..color = color;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-w / 2, 0, w, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rrect, legPaint);

      final footPaint = Paint()..color = const Color(0xFFC9A76C);
      final footRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-footW / 2, h - footH / 2, footW, footH),
        const Radius.circular(3),
      );
      canvas.drawRRect(footRRect, footPaint);
      canvas.restore();
    }

    // Inner legs
    drawLeg(x: 88, y: 0, w: 6, h: 44, angleDeg: -5,
        color: const Color(0xFF252532), footX: 0, footY: 40, footW: 10, footH: 6);
    drawLeg(x: 253, y: 0, w: 6, h: 44, angleDeg: 5,
        color: const Color(0xFF252532), footX: 0, footY: 40, footW: 10, footH: 6);
    // Outer legs
    drawLeg(x: 75, y: 0, w: 7, h: 58, angleDeg: -9,
        color: const Color(0xFF31313F), footX: 0, footY: 52, footW: 12, footH: 7);
    drawLeg(x: 262, y: 0, w: 7, h: 58, angleDeg: 9,
        color: const Color(0xFF31313F), footX: 0, footY: 52, footW: 12, footH: 7);
  }

  @override
  bool shouldRepaint(_) => false;
}