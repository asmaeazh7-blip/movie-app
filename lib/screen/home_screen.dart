import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/tmbd_service.dart';
import 'movie_detail_screen.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class C {
  static const bg      = Color(0xFF0F0F0F);
  static const card    = Color(0xFF1A1A1A);
  static const card2   = Color(0xFF222222);
  static const purple  = Color(0xFF2B124C);
  static const wine    = Color(0xFF662549);
  static const rose    = Color(0xFFAF445A);
  static const gold    = Color(0xFFC9A76C);
  static const cream   = Color(0xFFFBE4D8);
  static const blush   = Color(0xFFDFB6B2);
  static const accent  = Color(0xFFE8435A);
  static const text    = Color(0xFFEEEEEE);
  static const sub     = Color(0xFF888888);
  static const hdGreen = Color(0xFF4CAF50);
  static const sdOrange= Color(0xFFFF9800);
}

const _categories = ['All', 'Adventure', 'Comedy', 'Fantasy', 'Action', 'Drama', 'Sci-Fi', 'Horror'];
const _tabLabels  = ['Top Rated', 'New', 'Trending', 'Movies'];

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = TMDBService();

  int _navIndex   = 0;
  int _catIndex   = 0;
  int _tabIndex   = 1;
  int _featuredIndex = 0;
  final _pageCtrl = PageController(viewportFraction: 0.88);

  // TMDB futures
  late Future<List<TmdbMovie>> _popularFuture;
  late Future<List<TmdbMovie>> _topRatedFuture;
  late Future<List<TmdbMovie>> _trendingFuture;
  late Future<List<TmdbMovie>> _nowPlayingFuture;

  @override
  void initState() {
    super.initState();
    _popularFuture    = _svc.fetchPopular();
    _topRatedFuture   = _svc.fetchTopRated();
    _trendingFuture   = _svc.fetchTrending();
    _nowPlayingFuture = _svc.fetchNowPlaying();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // Return the correct future based on tab index
  Future<List<TmdbMovie>> get _tabFuture {
    switch (_tabIndex) {
      case 0: return _topRatedFuture;
      case 2: return _trendingFuture;
      case 3: return _popularFuture;
      default: return _nowPlayingFuture; // New
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Featured Carousel (Popular movies)
                    FutureBuilder<List<TmdbMovie>>(
                      future: _popularFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 228,
                            child: Center(child: CircularProgressIndicator(color: C.gold)),
                          );
                        }
                        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                          return const SizedBox(height: 228, child: Center(
                            child: Text('Failed to load', style: TextStyle(color: C.sub)),
                          ));
                        }
                        final featured = snap.data!.take(5).toList();
                        return _FeaturedCarousel(
                          movies: featured,
                          ctrl: _pageCtrl,
                          currentIndex: _featuredIndex,
                          onPageChanged: (i) => setState(() => _featuredIndex = i),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Category Tabs
                    _CategoryTabs(
                      selected: _catIndex,
                      onTap: (i) => setState(() => _catIndex = i),
                    ),

                    const SizedBox(height: 20),

                    // ── Filter Tabs
                    _FilterTabs(
                      selected: _tabIndex,
                      onTap: (i) => setState(() => _tabIndex = i),
                    ),

                    const SizedBox(height: 16),

                    // ── Movie Grid (based on selected tab)
                    FutureBuilder<List<TmdbMovie>>(
                      future: _tabFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator(color: C.gold)),
                          );
                        }
                        if (!snap.hasData || snap.data!.isEmpty) {
                          return const SizedBox(height: 300, child: Center(
                            child: Text('No movies', style: TextStyle(color: C.sub)),
                          ));
                        }
                        return _MovieGrid(movies: snap.data!.take(4).toList());
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Top Rated Section
                    _SectionHeader(title: 'Top Rated', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    FutureBuilder<List<TmdbMovie>>(
                      future: _topRatedFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 200, child: Center(
                            child: CircularProgressIndicator(color: C.gold),
                          ));
                        }
                        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
                        return _HorizontalMovieList(movies: snap.data!.take(8).toList());
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Trending Section
                    _SectionHeader(title: 'Trending', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    FutureBuilder<List<TmdbMovie>>(
                      future: _trendingFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 200, child: Center(
                            child: CircularProgressIndicator(color: C.gold),
                          ));
                        }
                        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
                        return _HorizontalMovieList(movies: snap.data!.take(8).toList());
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────

/// Map a TMDB movie index to a deterministic accent color for the card gradient
Color _movieColor(TmdbMovie m) {
  final colors = [
    const Color(0xFF8B4513),
    const Color(0xFFB8860B),
    const Color(0xFF4169E1),
    const Color(0xFF2E8B57),
    const Color(0xFF8B6914),
    const Color(0xFF4A4A6A),
    const Color(0xFF556B2F),
    const Color(0xFF1C3A5E),
    const Color(0xFF2C1810),
    const Color(0xFF3D2B1F),
    const Color(0xFF4A3728),
    const Color(0xFF5C3317),
    const Color(0xFF1A3A4A),
    const Color(0xFF3B1F2B),
  ];
  return colors[m.id % colors.length];
}

// ─────────────────────────────────────────────
//  NETWORK POSTER  (with fallback gradient)
// ─────────────────────────────────────────────
class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.movie, this.width, this.height, this.fit});
  final TmdbMovie movie;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (movie.posterUrl.isEmpty) {
      return Container(
        width: width, height: height,
        color: _movieColor(movie).withOpacity(0.5),
        child: const Icon(Icons.movie_rounded, color: Colors.white30, size: 40),
      );
    }
    return Image.network(
      movie.posterUrl,
      width: width, height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (_, child, prog) => prog == null
          ? child
          : Container(
              width: width, height: height,
              color: _movieColor(movie).withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(color: C.gold, strokeWidth: 2)),
            ),
      errorBuilder: (_, __, ___) => Container(
        width: width, height: height,
        color: _movieColor(movie).withOpacity(0.4),
        child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 40),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [C.gold, C.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'CineJoy',
            style: GoogleFonts.caveat(
              fontSize: 26, fontWeight: FontWeight.w700, color: C.cream,
            ),
          ),
          const Spacer(),
          _IconBtn(icon: Icons.search_rounded, onTap: () {}),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [C.purple, C.wine]),
              border: Border.all(color: C.gold.withOpacity(0.5), width: 1.5),
            ),
            child: const Icon(Icons.person_rounded, color: C.cream, size: 20),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Icon(icon, color: C.sub, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FEATURED CAROUSEL  (real TMDB posters)
// ─────────────────────────────────────────────
class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({
    required this.movies,
    required this.ctrl,
    required this.currentIndex,
    required this.onPageChanged,
  });
  final List<TmdbMovie> movies;
  final PageController ctrl;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onPageChanged,
            itemCount: movies.length,
            itemBuilder: (_, i) {
              final m = movies[i];
              return AnimatedScale(
                scale: i == currentIndex ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _FeaturedCard(movie: m),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(movies.length, (i) {
            final active = i == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? C.gold : C.sub.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.movie});
  final TmdbMovie movie;

  @override
  Widget build(BuildContext context) {
    final color = _movieColor(movie);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(
            title: movie.title,
            year: movie.year,
            duration: '—',
            rating: movie.ratingRounded,
            genre: '',
            color: color,
            description: movie.overview,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop image
              if (movie.backdropUrl.isNotEmpty)
                Image.network(
                  movie.backdropUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: color),
                )
              else
                Container(color: color),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 16, right: 16, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: C.gold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                movie.ratingRounded.toString(),
                                style: GoogleFonts.dmSans(
                                  color: C.cream, fontSize: 12, fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800, height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      movie.year,
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.7), fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Bookmark
              Positioned(
                top: 12, right: 12,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 18),
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
//  CATEGORY TABS
// ─────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? C.rose : C.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? C.rose : Colors.white.withOpacity(0.08),
                ),
                boxShadow: active
                    ? [BoxShadow(color: C.rose.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Text(
                _categories[i],
                style: GoogleFonts.dmSans(
                  color: active ? Colors.white : C.sub,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER TABS
// ─────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_tabLabels.length, (i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    _tabLabels[i],
                    style: GoogleFonts.dmSans(
                      color: active ? C.cream : C.sub,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 2,
                    width: active ? 24 : 0,
                    decoration: BoxDecoration(
                      color: C.gold,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOVIE GRID  (2 columns, real posters)
// ─────────────────────────────────────────────
class _MovieGrid extends StatelessWidget {
  const _MovieGrid({required this.movies});
  final List<TmdbMovie> movies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: movies.length,
        itemBuilder: (_, i) => _MovieCard(movie: movies[i]),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});
  final TmdbMovie movie;

  @override
  Widget build(BuildContext context) {
    final color = _movieColor(movie);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(
            title: movie.title,
            year: movie.year,
            duration: '—',
            rating: movie.ratingRounded,
            genre: '',
            color: color,
            description: movie.overview,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              if (movie.posterUrl.isNotEmpty)
                Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: color.withOpacity(0.4)),
                )
              else
                Container(color: color.withOpacity(0.4)),

              // Bottom gradient + info
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            movie.year,
                            style: GoogleFonts.dmSans(color: C.sub, fontSize: 10),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.star_rounded, color: C.gold, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            movie.ratingRounded.toString(),
                            style: GoogleFonts.dmSans(
                              color: C.gold, fontSize: 10, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // HD badge
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: C.hdGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'HD',
                    style: GoogleFonts.spaceMono(
                      color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Bookmark
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 14),
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
//  SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: C.cream, fontSize: 18, fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: GoogleFonts.dmSans(
                color: C.rose, fontSize: 13, fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HORIZONTAL MOVIE LIST  (real posters)
// ─────────────────────────────────────────────
class _HorizontalMovieList extends StatelessWidget {
  const _HorizontalMovieList({required this.movies});
  final List<TmdbMovie> movies;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (_, i) {
          final m = movies[i];
          final color = _movieColor(m);
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(
                  title: m.title,
                  year: m.year,
                  duration: '—',
                  rating: m.ratingRounded,
                  genre: '',
                  color: color,
                  description: m.overview,
                ),
              ),
            ),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (m.posterUrl.isNotEmpty)
                      Image.network(m.posterUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: color.withOpacity(0.4)),
                      )
                    else
                      Container(color: color.withOpacity(0.4)),

                    Positioned(
                      left: 0, right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(7, 20, 7, 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(m.year, style: GoogleFonts.dmSans(color: C.sub, fontSize: 10)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, color: C.gold, size: 11),
                                const SizedBox(width: 2),
                                Text(
                                  m.ratingRounded.toString(),
                                  style: GoogleFonts.dmSans(color: C.gold, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ],
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
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM NAVIGATION
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_rounded,     label: 'Home'),
    (icon: Icons.search_rounded,   label: 'Search'),
    (icon: Icons.favorite_rounded, label: 'Favorites'),
    (icon: Icons.person_rounded,   label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: C.card,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          if (i == 1) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [C.rose, C.wine],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: C.rose.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(_items[i].icon, color: Colors.white, size: 24),
              ),
            );
          }
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_items[i].icon, color: active ? C.gold : C.sub, size: 24),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 4 : 0,
                  height: 4,
                  decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}