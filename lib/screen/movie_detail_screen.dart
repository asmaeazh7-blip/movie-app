import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  COLORS (dark movie UI)
// ─────────────────────────────────────────────
class DC {
  static const bg      = Color(0xFF0D0D0D);
  static const card    = Color(0xFF1A1A1A);
  static const accent  = Color(0xFFE8435A);
  static const gold    = Color(0xFFC9A76C);
  static const cream   = Color(0xFFFBE4D8);
  static const sub     = Color(0xFF888888);
  static const divider = Color(0xFF2A2A2A);
}

// ─────────────────────────────────────────────
//  MOVIE DETAIL SCREEN
// ─────────────────────────────────────────────
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.title,
    required this.year,
    required this.duration,
    required this.rating,
    required this.genre,
    required this.color,
    this.description,
  });

  final String title;
  final String year;
  final String duration;
  final double rating;
  final String genre;
  final Color color;
  final String? description;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _bookmarked = false;
  bool _liked = false;
  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heroFade =
        CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DC.bg,
      body: FadeTransition(
        opacity: _heroFade,
        child: SlideTransition(
          position: _heroSlide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Sliver App Bar ──
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: DC.bg,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => setState(() => _bookmarked = !_bookmarked),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: _bookmarked ? DC.gold : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient hero background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.7),
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                      // Decorative film poster visual
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DetailBgPainter(widget.color),
                        ),
                      ),
                      // Movie poster center
                      Center(
                        child: Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.color.withOpacity(0.9),
                                widget.color.withOpacity(0.5),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.movie_rounded,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 60,
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Text(
                                  widget.title,
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom fade
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                DC.bg,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body Content ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        widget.title,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tags row
                      Wrap(
                        spacing: 8,
                        children: [
                          _Tag(label: widget.genre, isPrimary: true),
                          _Tag(label: 'HD'),
                          _Tag(label: widget.year),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats row (Rating, Duration, Year)
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.star_rounded,
                            value: widget.rating.toStringAsFixed(1),
                            label: 'Rating',
                            color: DC.gold,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.access_time_rounded,
                            value: widget.duration,
                            label: 'Duration',
                            color: DC.accent,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.calendar_today_rounded,
                            value: widget.year,
                            label: 'Year',
                            color: const Color(0xFF4CAF50),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Overview',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description ??
                            'A riveting cinematic experience that draws you into a world of suspense, drama, and unforgettable moments. Follow the story as it unfolds across stunning visuals and powerful performances that will leave you breathless.',
                        style: GoogleFonts.dmSans(
                          color: DC.sub,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [DC.accent, Color(0xFF662549)],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DC.accent.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_arrow_rounded,
                                        color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Watch Now',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Like button
                          GestureDetector(
                            onTap: () => setState(() => _liked = !_liked),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: DC.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _liked
                                      ? DC.accent.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Icon(
                                _liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _liked ? DC.accent : DC.sub,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Share button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: DC.card,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Icon(
                                Icons.share_rounded,
                                color: DC.sub,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Screenshots / clips row
                      Text(
                        'Screenshots',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, i) => Container(
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  widget.color.withOpacity(0.6 - i * 0.08),
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                color: Colors.white.withOpacity(0.6),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Cast section
                      Text(
                        'Cast',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _castNames.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (_, i) => _CastChip(
                            name: _castNames[i],
                            color: _castColors[i % _castColors.length],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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

// ─────────────────────────────────────────────
//  WIDGETS
// ─────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.isPrimary = false});
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary ? DC.accent.withOpacity(0.15) : DC.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary
              ? DC.accent.withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: isPrimary ? DC.accent : DC.sub,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: DC.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: DC.sub,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CastChip extends StatelessWidget {
  const _CastChip({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = name.split(' ');
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              parts.map((p) => p[0]).take(2).join(),
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          parts.first,
          style: GoogleFonts.dmSans(
            color: DC.sub,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  BACKGROUND PAINTER
// ─────────────────────────────────────────────
class _DetailBgPainter extends CustomPainter {
  const _DetailBgPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = color.withOpacity(0.08);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15), 120, paint);

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.8), 100, paint);

    // Film strip lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.1 + i * 0.18);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────
const _castNames = ['Jamie Fox', 'Dave Bautista', 'Snoop Dogg', 'Karla Souza', 'Steve Howey'];
const _castColors = [
  Color(0xFF8B4513),
  Color(0xFF4169E1),
  Color(0xFF2E8B57),
  Color(0xFFB8860B),
  Color(0xFF662549),
];
