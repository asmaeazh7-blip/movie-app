import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmbd_service.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class DC {
  static const bg      = Color(0xFF0D0D0D);
  static const card    = Color(0xFF1A1A1A);
  static const card2   = Color(0xFF222222);
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
    this.movieId,
    this.posterUrl,
    this.backdropUrl,
  });

  final String title;
  final String year;
  final String duration;
  final double rating;
  final String genre;
  final Color color;
  final String? description;
  final int? movieId;
  final String? posterUrl;
  final String? backdropUrl;

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

  TmdbMovieDetail? _detail;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
    if (widget.movieId != null) {
      _loadDetail(widget.movieId!);
    }
  }

  Future<void> _loadDetail(int id) async {
    setState(() => _loadingDetail = true);
    try {
      final detail = await TMDBService().fetchMovieDetail(id);
      if (mounted) setState(() { _detail = detail; _loadingDetail = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  // ── helpers
  String get _displayTitle  => _detail?.title      ?? widget.title;
  String get _displayYear   => _detail?.year       ?? widget.year;
  String get _displayDur    => _detail?.durationStr ?? widget.duration;
  double get _displayRating => _detail?.ratingRounded ?? widget.rating;
  String get _displayOverview =>
      (_detail?.overview.isNotEmpty == true ? _detail!.overview : null) ??
      widget.description ??
      'No overview available.';
  String get _displayGenre  => _detail?.genreStr ?? widget.genre;
  String? get _posterUrl    => _detail?.posterUrl.isNotEmpty == true
      ? _detail!.posterUrl
      : widget.posterUrl;
  String? get _backdropUrl  => _detail?.backdropUrl.isNotEmpty == true
      ? _detail!.backdropUrl
      : widget.backdropUrl;

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
              // ── Hero App Bar
              SliverAppBar(
                expandedHeight: 380,
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
                  background: _HeroBackground(
                    posterUrl: _posterUrl,
                    backdropUrl: _backdropUrl,
                    color: widget.color,
                    title: _displayTitle,
                  ),
                ),
              ),

              // ── Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        _displayTitle,
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Genre tags
                      if (_loadingDetail)
                        Row(children: [
                          _shimmerTag(60),
                          const SizedBox(width: 8),
                          _shimmerTag(40),
                        ])
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (_displayGenre.isNotEmpty)
                              ..._displayGenre.split(' • ')
                                  .map((g) => _Tag(label: g, isPrimary: true)),
                            _Tag(label: 'HD'),
                            _Tag(label: _displayYear),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.star_rounded,
                            value: _displayRating.toStringAsFixed(1),
                            label: 'Rating',
                            color: DC.gold,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.access_time_rounded,
                            value: _loadingDetail ? '...' : _displayDur,
                            label: 'Duration',
                            color: DC.accent,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.calendar_today_rounded,
                            value: _displayYear,
                            label: 'Year',
                            color: const Color(0xFF4CAF50),
                          ),
                        ],
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
                          _IconAction(
                            icon: _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _liked ? DC.accent : DC.sub,
                            onTap: () => setState(() => _liked = !_liked),
                          ),
                          const SizedBox(width: 12),
                          _IconAction(
                            icon: Icons.share_rounded,
                            color: DC.sub,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Overview
                      _SectionTitle('Overview'),
                      const SizedBox(height: 8),
                      _loadingDetail
                          ? _shimmerBlock(80)
                          : Text(
                              _displayOverview,
                              style: GoogleFonts.dmSans(
                                color: DC.sub,
                                fontSize: 14,
                                height: 1.65,
                              ),
                            ),

                      // ── Backdrops (screenshots)
                      if (_detail != null && _detail!.backdrops.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionTitle('Screenshots'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _detail!.backdrops.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: _detail!.backdrops[i].url,
                                width: 160,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 160,
                                  color: DC.card2,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: DC.gold, strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  width: 160,
                                  color: DC.card2,
                                  child: const Icon(Icons.broken_image_outlined,
                                      color: DC.sub),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_loadingDetail) ...[
                        const SizedBox(height: 28),
                        _SectionTitle('Screenshots'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, __) => _shimmerRect(160, 100),
                          ),
                        ),
                      ],

                      // ── Cast
                      if (_detail != null && _detail!.cast.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionTitle('Cast'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _detail!.cast.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (_, i) =>
                                _CastChip(member: _detail!.cast[i]),
                          ),
                        ),
                      ] else if (_loadingDetail) ...[
                        const SizedBox(height: 28),
                        _SectionTitle('Cast'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (_, __) => Column(
                              children: [
                                _shimmerRect(56, 56, radius: 28),
                                const SizedBox(height: 6),
                                _shimmerRect(48, 10),
                              ],
                            ),
                          ),
                        ),
                      ],

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

  Widget _shimmerTag(double w) => Container(
        width: w,
        height: 24,
        decoration: BoxDecoration(
          color: DC.card2,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _shimmerBlock(double h) => Container(
        height: h,
        decoration: BoxDecoration(
          color: DC.card2,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _shimmerRect(double w, double h, {double radius = 8}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: DC.card2,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ─────────────────────────────────────────────
//  HERO BACKGROUND — shows real poster + backdrop
// ─────────────────────────────────────────────
class _HeroBackground extends StatelessWidget {
  const _HeroBackground({
    required this.posterUrl,
    required this.backdropUrl,
    required this.color,
    required this.title,
  });
  final String? posterUrl;
  final String? backdropUrl;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop image or gradient fallback
        if (backdropUrl != null && backdropUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: backdropUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.4), Colors.black],
                ),
              ),
            ),
            errorWidget: (_, __, ___) => _GradientFallback(color: color),
          )
        else
          _GradientFallback(color: color),

        // Dark overlay for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
                DC.bg,
              ],
            ),
          ),
        ),

        // Poster card centered
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 120,
              height: 178,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: (posterUrl != null && posterUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: posterUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: color.withOpacity(0.4),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: DC.gold, strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _PosterFallback(
                            color: color, title: title),
                      )
                    : _PosterFallback(color: color, title: title),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.4), Colors.black],
          ),
        ),
      );
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({required this.color, required this.title});
  final Color color;
  final String title;
  @override
  Widget build(BuildContext context) => Container(
        color: color.withOpacity(0.5),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
//  WIDGETS
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.dmSans(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      );
}

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
              style: GoogleFonts.dmSans(color: DC.sub, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: DC.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _CastChip extends StatelessWidget {
  const _CastChip({required this.member});
  final TmdbCastMember member;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DC.card2,
              border:
                  Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            ),
            child: ClipOval(
              child: member.profileUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: member.profileUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                            color: DC.gold, strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) =>
                          _AvatarFallback(name: member.name),
                    )
                  : _AvatarFallback(name: member.name),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name.split(' ').first,
            style: GoogleFonts.dmSans(color: DC.sub, fontSize: 10),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'
        : parts[0].isNotEmpty
            ? parts[0][0]
            : '?';
    return Container(
      color: DC.card2,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.dmSans(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BACKGROUND PAINTER (kept for compatibility)
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}