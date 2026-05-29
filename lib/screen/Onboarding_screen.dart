import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
// ─────────────────────────────────────────────
//  COLOR PALETTE  (from user's references)
// ─────────────────────────────────────────────
class CineColors {
  static const bg          = Color(0xFF190019);   // darkest — background
  static const deep        = Color(0xFF2B124C);   // deep purple
  static const mid         = Color(0xFF522B5B);   // mid purple
  static const muted       = Color(0xFF854F6C);   // muted rose-purple
  static const blush       = Color(0xFFDFB6B2);   // blush
  static const cream       = Color(0xFFFBE4D8);   // cream/light
  static const gold        = Color(0xFFC9A76C);   // CineJoy gold accent
}

// ─────────────────────────────────────────────
//  ONBOARDING DATA
// ─────────────────────────────────────────────
class _OnboardPage {
  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientTop,
    required this.gradientBottom,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientTop;
  final Color gradientBottom;
}

const _pages = [
  _OnboardPage(
    title: 'Welcome to CineJoy',
    subtitle: 'Your cinematic universe awaits.\nDiscover films & series you\'ll love.',
    icon: Icons.movie_filter_rounded,
    gradientTop: CineColors.deep,
    gradientBottom: CineColors.bg,
  ),
  _OnboardPage(
    title: 'Explore & Discover',
    subtitle: 'Browse trending movies, hidden gems,\nand curated collections just for you.',
    icon: Icons.explore_rounded,
    gradientTop: CineColors.mid,
    gradientBottom: CineColors.deep,
  ),
  _OnboardPage(
    title: 'Your Watchlist',
    subtitle: 'Save favourites, track what you\'ve seen,\nand never miss a release.',
    icon: Icons.bookmark_rounded,
    gradientTop: CineColors.muted,
    gradientBottom: CineColors.mid,
  ),
];

// ─────────────────────────────────────────────
//  ONBOARDING SCREEN
// ─────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onDone});
  final VoidCallback? onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _current = 0;

  // per-page entrance animations
  late AnimationController _entryCtrl;
  late Animation<double>   _blobScale;
  late Animation<double>   _iconFloat;
  late Animation<double>   _textFade;
  late Animation<Offset>   _textSlide;

  // floating bob animation (continuous)
  late AnimationController _bobCtrl;
  late Animation<double>   _bob;

  // decorative blobs rotation
  late AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();

    // entry animation
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _blobScale = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _iconFloat = CurvedAnimation(
        parent: _entryCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
    _textFade  = CurvedAnimation(
        parent: _entryCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    // bob
    _bobCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _bob = Tween<double>(begin: -12, end: 12).animate(
        CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut));

    // slow rotation for blobs
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 18))
      ..repeat();

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    _bobCtrl.dispose();
    _rotCtrl.dispose();
    super.dispose();
  }

  void _goToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => AuthScreen(
          onDone: () => Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          ),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic);
    } else {
      _goToAuth();
    }
  }

  void _skip() => _goToAuth();

  void _onPageChanged(int index) {
    setState(() => _current = index);
    _entryCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_current];
    final isLast = _current == _pages.length - 1;

    return Scaffold(
      backgroundColor: CineColors.bg,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [page.gradientTop, page.gradientBottom],
          ),
        ),
        child: Stack(
          children: [
            // ── decorative rotating blobs ──
            _RotatingBlobs(rotCtrl: _rotCtrl, page: page),

            // ── grain overlay ──
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.04,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/images/CineJoy.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black, BlendMode.color),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── main content ──
            SafeArea(
              child: Column(
                children: [
                  // skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, right: 20),
                      child: TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.spaceGrotesk(
                            color: CineColors.blush.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // PageView (illustration area)
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageCtrl,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (_, i) => _IllustrationArea(
                        page: _pages[i],
                        blobScale: _blobScale,
                        iconFloat: _iconFloat,
                        bob: _bob,
                        rotCtrl: _rotCtrl,
                      ),
                    ),
                  ),

                  // text + dots + button
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // title
                          FadeTransition(
                            opacity: _textFade,
                            child: SlideTransition(
                              position: _textSlide,
                              child: Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.caveat(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: CineColors.cream,
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // subtitle
                          FadeTransition(
                            opacity: _textFade,
                            child: SlideTransition(
                              position: _textSlide,
                              child: Text(
                                page.subtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14.5,
                                  color: CineColors.blush.withOpacity(0.85),
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (i) {
                              final active = i == _current;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? CineColors.gold
                                      : CineColors.muted.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 28),

                          // CTA button
                          GestureDetector(
                            onTap: _next,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFAF445A), Color(0xFF662549)],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFAF445A).withOpacity(0.45),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  isLast ? 'Get Started' : 'Next',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: CineColors.cream,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ILLUSTRATION AREA
// ─────────────────────────────────────────────
class _IllustrationArea extends StatelessWidget {
  const _IllustrationArea({
    required this.page,
    required this.blobScale,
    required this.iconFloat,
    required this.bob,
    required this.rotCtrl,
  });

  final _OnboardPage page;
  final Animation<double> blobScale;
  final Animation<double> iconFloat;
  final Animation<double> bob;
  final AnimationController rotCtrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([blobScale, iconFloat, bob, rotCtrl]),
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // outer glow blob
              Transform.scale(
                scale: blobScale.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        page.gradientTop.withOpacity(0.6),
                        page.gradientTop.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // main blob shape (rotated super-ellipse via CustomPaint)
              Transform.rotate(
                angle: rotCtrl.value * 2 * pi * 0.04,
                child: Transform.scale(
                  scale: blobScale.value * 0.92,
                  child: CustomPaint(
                    size: const Size(220, 200),
                    painter: _BlobPainter(
                      color1: page.gradientTop.withOpacity(0.85),
                      color2: CineColors.muted.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              // small decorative blob top-right
              Positioned(
                top: 30,
                right: 60,
                child: Transform.scale(
                  scale: blobScale.value * 0.7,
                  child: CustomPaint(
                    size: const Size(90, 80),
                    painter: _BlobPainter(
                      color1: CineColors.muted.withOpacity(0.5),
                      color2: CineColors.blush.withOpacity(0.2),
                    ),
                  ),
                ),
              ),

              // floating main icon
              Transform.translate(
                offset: Offset(0, bob.value * iconFloat.value),
                child: Opacity(
                  opacity: iconFloat.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CineColors.gold.withOpacity(0.9),
                          CineColors.muted,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CineColors.gold.withOpacity(0.35),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: 52,
                      color: CineColors.cream,
                    ),
                  ),
                ),
              ),

              // small floating accent icon
              Positioned(
                bottom: 48,
                right: 52,
                child: Transform.translate(
                  offset: Offset(0, -bob.value * 0.6 * iconFloat.value),
                  child: Opacity(
                    opacity: iconFloat.value * 0.8,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CineColors.blush.withOpacity(0.2),
                        border: Border.all(
                          color: CineColors.blush.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 22,
                        color: CineColors.gold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BLOB PAINTER  (organic shape)
// ─────────────────────────────────────────────
class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.color1, required this.color2});
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.85, 0, w, h * 0.25, w, h * 0.5);
    path.cubicTo(w, h * 0.82, w * 0.78, h, w * 0.5, h);
    path.cubicTo(w * 0.18, h, 0, h * 0.78, 0, h * 0.5);
    path.cubicTo(0, h * 0.2, w * 0.18, 0, w * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) =>
      old.color1 != color1 || old.color2 != color2;
}

// ─────────────────────────────────────────────
//  ROTATING BACKGROUND BLOBS
// ─────────────────────────────────────────────
class _RotatingBlobs extends StatelessWidget {
  const _RotatingBlobs({required this.rotCtrl, required this.page});
  final AnimationController rotCtrl;
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: rotCtrl,
      builder: (_, __) => Stack(
        children: [
          // top-left blob
          Positioned(
            top: -80,
            left: -60,
            child: Transform.rotate(
              angle: rotCtrl.value * 2 * pi,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      page.gradientTop.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // bottom-right blob
          Positioned(
            bottom: -60,
            right: -40,
            child: Transform.rotate(
              angle: -rotCtrl.value * 2 * pi * 0.7,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CineColors.muted.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // center-left faint accent
          Positioned(
            top: size.height * 0.35,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    CineColors.gold.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}