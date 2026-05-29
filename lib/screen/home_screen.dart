import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmbd_service.dart';
import 'movie_detail_screen.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class C {
  static const bg       = Color(0xFF0D0D0D);
  static const card     = Color(0xFF1A1A1A);
  static const card2    = Color(0xFF222222);
  static const purple   = Color(0xFF2B124C);
  static const wine     = Color(0xFF662549);
  static const rose     = Color(0xFFAF445A);
  static const gold     = Color(0xFFC9A76C);
  static const cream    = Color(0xFFFBE4D8);
  static const blush    = Color(0xFFDFB6B2);
  static const accent   = Color(0xFFE8435A);
  static const text     = Color(0xFFEEEEEE);
  static const sub      = Color(0xFF777777);
  static const hdGreen  = Color(0xFF3DAA6B);
  static const sdOrange = Color(0xFFFF9800);
}

const _categories = ['All', 'Action', 'Comedy', 'Drama', 'Sci-Fi', 'Horror', 'Fantasy', 'Adventure'];
const _tabLabels  = ['Top Rated', 'New', 'Trending', 'Movies'];

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _svc = TMDBService();

  int _navIndex       = 0;
  int _catIndex       = 0;
  int _tabIndex       = 1;
  int _featuredIndex  = 0;

  final _pageCtrl = PageController(viewportFraction: 0.88);

  late Future<List<TmdbMovie>> _popularFuture;
  late Future<List<TmdbMovie>> _topRatedFuture;
  late Future<List<TmdbMovie>> _trendingFuture;
  late Future<List<TmdbMovie>> _nowPlayingFuture;

  // Search
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  Future<List<TmdbMovie>>? _searchFuture;

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
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<TmdbMovie>> get _tabFuture {
    switch (_tabIndex) {
      case 0: return _topRatedFuture;
      case 2: return _trendingFuture;
      case 3: return _popularFuture;
      default: return _nowPlayingFuture;
    }
  }

  void _onSearch(String q) {
    if (q.trim().isEmpty) {
      setState(() => _searchFuture = null);
      return;
    }
    setState(() => _searchFuture = _svc.searchMovies(q.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar
            _TopBar(
              onSearchTap: () => setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchCtrl.clear();
                  _searchFuture = null;
                }
              }),
            ),

            // ── Search Field (expandable)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: _searchOpen
                  ? _SearchField(
                      controller: _searchCtrl,
                      onChanged: _onSearch,
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Body
            Expanded(
              child: _searchFuture != null
                  ? _SearchResults(future: _searchFuture!)
                  : _HomeBody(
                      popularFuture:    _popularFuture,
                      topRatedFuture:   _topRatedFuture,
                      trendingFuture:   _trendingFuture,
                      tabFuture:        _tabFuture,
                      catIndex:         _catIndex,
                      tabIndex:         _tabIndex,
                      featuredIndex:    _featuredIndex,
                      pageCtrl:         _pageCtrl,
                      onCatTap:   (i) => setState(() => _catIndex = i),
                      onTabTap:   (i) => setState(() => _tabIndex = i),
                      onPageChanged: (i) => setState(() => _featuredIndex = i),
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
//  HOME BODY
// ─────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.popularFuture,
    required this.topRatedFuture,
    required this.trendingFuture,
    required this.tabFuture,
    required this.catIndex,
    required this.tabIndex,
    required this.featuredIndex,
    required this.pageCtrl,
    required this.onCatTap,
    required this.onTabTap,
    required this.onPageChanged,
  });

  final Future<List<TmdbMovie>> popularFuture;
  final Future<List<TmdbMovie>> topRatedFuture;
  final Future<List<TmdbMovie>> trendingFuture;
  final Future<List<TmdbMovie>> tabFuture;
  final int catIndex, tabIndex, featuredIndex;
  final PageController pageCtrl;
  final ValueChanged<int> onCatTap, onTabTap, onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ── Featured Carousel
          FutureBuilder<List<TmdbMovie>>(
            future: popularFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 230,
                  child: Center(child: CircularProgressIndicator(color: C.gold)),
                );
              }
              if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                return _ErrorBox(height: 230, message: 'Failed to load featured');
              }
              return _FeaturedCarousel(
                movies: snap.data!.take(6).toList(),
                ctrl: pageCtrl,
                currentIndex: featuredIndex,
                onPageChanged: onPageChanged,
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Category Chips
          _CategoryChips(selected: catIndex, onTap: onCatTap),

          const SizedBox(height: 20),

          // ── Filter Tabs
          _FilterTabs(selected: tabIndex, onTap: onTabTap),

          const SizedBox(height: 16),

          // ── Movie Grid
          FutureBuilder<List<TmdbMovie>>(
            future: tabFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 300,
                    child: Center(child: CircularProgressIndicator(color: C.gold)));
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return _ErrorBox(height: 300, message: 'No movies found');
              }
              return _MovieGrid(movies: snap.data!.take(4).toList());
            },
          ),

          const SizedBox(height: 24),

          // ── Top Rated Section
          _SectionHeader(title: 'Top Rated ⭐', onSeeAll: () {}),
          const SizedBox(height: 12),
          FutureBuilder<List<TmdbMovie>>(
            future: topRatedFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200,
                    child: Center(child: CircularProgressIndicator(color: C.gold)));
              }
              if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
              return _HorizontalMovieList(movies: snap.data!.take(10).toList());
            },
          ),

          const SizedBox(height: 24),

          // ── Trending Section
          _SectionHeader(title: 'Trending 🔥', onSeeAll: () {}),
          const SizedBox(height: 12),
          FutureBuilder<List<TmdbMovie>>(
            future: trendingFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200,
                    child: Center(child: CircularProgressIndicator(color: C.gold)));
              }
              if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
              return _HorizontalMovieList(movies: snap.data!.take(10).toList());
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SEARCH FIELD
// ─────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          autofocus: true,
          style: GoogleFonts.dmSans(color: C.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: GoogleFonts.dmSans(color: C.sub, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: C.sub, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SEARCH RESULTS
// ─────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.future});
  final Future<List<TmdbMovie>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TmdbMovie>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: C.gold));
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return Center(
            child: Text('No results found', style: GoogleFonts.dmSans(color: C.sub, fontSize: 15)),
          );
        }
        final movies = snap.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: movies.length,
          itemBuilder: (_, i) => _SearchTile(movie: movies[i]),
        );
      },
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.movie});
  final TmdbMovie movie;

  @override
  Widget build(BuildContext context) {
    final color = _movieColor(movie);
    return GestureDetector(
      onTap: () => _openDetail(context, movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _Poster(url: movie.posterUrl, color: color, width: 56, height: 76),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(color: C.text, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(movie.year, style: GoogleFonts.dmSans(color: C.sub, fontSize: 12)),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: C.gold, size: 13),
                      const SizedBox(width: 3),
                      Text(movie.ratingRounded.toString(),
                        style: GoogleFonts.dmSans(color: C.gold, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  if (movie.overview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(color: C.sub, fontSize: 11)),
                  ]
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
//  HELPERS
// ─────────────────────────────────────────────
Color _movieColor(TmdbMovie m) {
  const colors = [
    Color(0xFF8B4513), Color(0xFFB8860B), Color(0xFF4169E1),
    Color(0xFF2E8B57), Color(0xFF8B6914), Color(0xFF4A4A6A),
    Color(0xFF556B2F), Color(0xFF1C3A5E), Color(0xFF2C1810),
    Color(0xFF3D2B1F), Color(0xFF4A3728), Color(0xFF5C3317),
    Color(0xFF1A3A4A), Color(0xFF3B1F2B),
  ];
  return colors[m.id % colors.length];
}

void _openDetail(BuildContext context, TmdbMovie m) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MovieDetailScreen(
        title: m.title,
        year: m.year,
        duration: '—',
        rating: m.ratingRounded,
        genre: '',
        color: _movieColor(m),
        description: m.overview,
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  CACHED POSTER
// ─────────────────────────────────────────────
class _Poster extends StatelessWidget {
  const _Poster({required this.url, required this.color,
    this.width, this.height, this.fit});
  final String url;
  final Color color;
  final double? width, height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: width, height: height,
        color: color.withOpacity(0.5),
        child: const Icon(Icons.movie_rounded, color: Colors.white30, size: 36),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width, height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (_, __) => Container(
        width: width, height: height,
        color: color.withOpacity(0.3),
        child: const Center(
          child: CircularProgressIndicator(color: C.gold, strokeWidth: 1.5)),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width, height: height,
        color: color.withOpacity(0.4),
        child: const Icon(Icons.broken_image_rounded, color: Colors.white24, size: 36),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ERROR BOX
// ─────────────────────────────────────────────
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.height, required this.message});
  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: C.sub, size: 36),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.dmSans(color: C.sub, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSearchTap});
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [C.gold, C.rose],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(color: C.rose.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 10),
          Text(
            'CineJoy',
            style: GoogleFonts.caveat(
              fontSize: 28, fontWeight: FontWeight.w700, color: C.cream,
            ),
          ),
          const Spacer(),
          // Search button
          _IconBtn(icon: Icons.search_rounded, onTap: onSearchTap),
          const SizedBox(width: 8),
          // Notification button
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
          const SizedBox(width: 8),
          // Avatar
          Container(
            width: 38, height: 38,
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
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Icon(icon, color: C.sub, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FEATURED CAROUSEL
// ─────────────────────────────────────────────
class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({
    required this.movies, required this.ctrl,
    required this.currentIndex, required this.onPageChanged,
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
          height: 210,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onPageChanged,
            itemCount: movies.length,
            itemBuilder: (_, i) {
              final m = movies[i];
              return AnimatedScale(
                scale: i == currentIndex ? 1.0 : 0.94,
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
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(movies.length, (i) {
            final active = i == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? C.gold : C.sub.withOpacity(0.35),
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
      onTap: () => _openDetail(context, movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: color,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.45), blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop
              if (movie.backdropUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: movie.backdropUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: color),
                  errorWidget: (_, __, ___) => Container(color: color),
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
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Info
              Positioned(
                left: 16, right: 60, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rating badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: C.gold, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            movie.ratingRounded.toString(),
                            style: GoogleFonts.dmSans(
                              color: C.cream, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w800, height: 1.1),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      movie.year,
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.65), fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Bookmark
              Positioned(
                top: 12, right: 12,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(9),
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
//  CATEGORY CHIPS
// ─────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onTap});
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
                  color: active ? C.rose : Colors.white.withOpacity(0.07),
                ),
                boxShadow: active
                    ? [BoxShadow(color: C.rose.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
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
              padding: const EdgeInsets.only(right: 22),
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
                    height: 2.5,
                    width: active ? 26 : 0,
                    decoration: BoxDecoration(
                      color: C.gold,
                      borderRadius: BorderRadius.circular(2),
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
//  MOVIE GRID  (2 columns)
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
    // Alternate HD/SD badge
    final isHD = movie.id % 3 != 0;
    return GestureDetector(
      onTap: () => _openDetail(context, movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.3),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster
              _Poster(url: movie.posterUrl, color: color),

              // Bottom gradient + info
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 28, 8, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.88)],
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
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(movie.year,
                            style: GoogleFonts.dmSans(color: C.sub, fontSize: 10)),
                          const SizedBox(width: 6),
                          const Icon(Icons.star_rounded, color: C.gold, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            movie.ratingRounded.toString(),
                            style: GoogleFonts.dmSans(
                              color: C.gold, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // HD / SD badge
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isHD ? C.hdGreen : C.sdOrange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    isHD ? 'HD' : 'SD',
                    style: GoogleFonts.spaceMono(
                      color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              // Bookmark
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 15),
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
              color: C.cream, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: GoogleFonts.dmSans(
                color: C.rose, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HORIZONTAL MOVIE LIST
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
            onTap: () => _openDetail(context, m),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Poster(url: m.posterUrl, color: color),
                    Positioned(
                      left: 0, right: 0, bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(7, 22, 7, 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.88)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(m.year,
                                  style: GoogleFonts.dmSans(color: C.sub, fontSize: 10)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, color: C.gold, size: 11),
                                const SizedBox(width: 2),
                                Text(m.ratingRounded.toString(),
                                  style: GoogleFonts.dmSans(
                                    color: C.gold, fontSize: 10, fontWeight: FontWeight.w700)),
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
          BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          // Center search button (bigger, colored)
          if (i == 1) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [C.rose, C.wine],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: C.rose.withOpacity(0.5), blurRadius: 18, offset: const Offset(0, 4)),
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