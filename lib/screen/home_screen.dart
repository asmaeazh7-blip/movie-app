import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

// ─────────────────────────────────────────────
//  FAKE DATA
// ─────────────────────────────────────────────
class Movie {
  const Movie({
    required this.title,
    required this.year,
    required this.duration,
    required this.rating,
    required this.genre,
    required this.color,
    this.isHD = true,
    this.isFeatured = false,
  });
  final String title;
  final String year;
  final String duration;
  final double rating;
  final String genre;
  final Color color;
  final bool isHD;
  final bool isFeatured;
}

const _featured = [
  Movie(title: 'Day Shift', year: '2022', duration: '114 min', rating: 6.2, genre: 'Action', color: Color(0xFF8B4513), isFeatured: true),
  Movie(title: 'The Beekeeper', year: '2024', duration: '105 min', rating: 7.1, genre: 'Action', color: Color(0xFFB8860B), isFeatured: true),
  Movie(title: 'Minions', year: '2022', duration: '87 min', rating: 6.5, genre: 'Comedy', color: Color(0xFF4169E1), isFeatured: true),
];

const _newMovies = [
  Movie(title: 'Lilo & Stitch', year: '2025', duration: '108 min', rating: 7.2, genre: 'Family', color: Color(0xFF2E8B57)),
  Movie(title: 'House of David', year: '2025', duration: '95 min', rating: 7.8, genre: 'Drama', color: Color(0xFF8B6914)),
  Movie(title: 'Mickey 17', year: '2025', duration: '137 min', rating: 6.8, genre: 'Sci-Fi', color: Color(0xFF4A4A6A)),
  Movie(title: 'Prey', year: '2022', duration: '99 min', rating: 7.1, genre: 'Action', color: Color(0xFF556B2F)),
];

const _topRated = [
  Movie(title: 'Inception', year: '2010', duration: '148 min', rating: 8.8, genre: 'Sci-Fi', color: Color(0xFF1C3A5E)),
  Movie(title: 'Interstellar', year: '2014', duration: '169 min', rating: 8.6, genre: 'Sci-Fi', color: Color(0xFF2C1810)),
  Movie(title: 'Parasite', year: '2019', duration: '132 min', rating: 8.5, genre: 'Thriller', color: Color(0xFF3D2B1F)),
  Movie(title: 'Oppenheimer', year: '2023', duration: '180 min', rating: 8.4, genre: 'Drama', color: Color(0xFF4A3728)),
];

const _categories = ['All', 'Adventure', 'Comedy', 'Fantasy', 'Action', 'Drama', 'Sci-Fi', 'Horror'];

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _catIndex = 0;
  int _tabIndex = 1; // 0=Top Rated, 1=New, 2=Trending, 3=Movies
  final _pageCtrl = PageController(viewportFraction: 0.88);
  int _featuredIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            _TopBar(),
            
            // ── Scrollable Content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Featured Carousel
                    _FeaturedCarousel(
                      ctrl: _pageCtrl,
                      onPageChanged: (i) => setState(() => _featuredIndex = i),
                      currentIndex: _featuredIndex,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Category Tabs
                    _CategoryTabs(
                      selected: _catIndex,
                      onTap: (i) => setState(() => _catIndex = i),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Filter Tabs (Top Rated / New / Trending / Movies)
                    _FilterTabs(
                      selected: _tabIndex,
                      onTap: (i) => setState(() => _tabIndex = i),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Movie Grid
                    _MovieGrid(movies: _tabIndex == 0 ? _topRated : _newMovies),
                    
                    const SizedBox(height: 20),
                    
                    // Top Rated Section
                    _SectionHeader(title: 'Top Rated', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    _HorizontalMovieList(movies: _topRated),
                    
                    const SizedBox(height: 20),
                    
                    // Movies Section
                    _SectionHeader(title: 'Movies', onSeeAll: () {}),
                    const SizedBox(height: 12),
                    _HorizontalMovieList(movies: _newMovies),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // ── Bottom Navigation ──
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
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
          // Logo
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
          // Search icon
          _IconBtn(icon: Icons.search_rounded, onTap: () {}),
          const SizedBox(width: 8),
          // Notification
          _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
          const SizedBox(width: 8),
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [C.purple, C.wine],
              ),
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
//  FEATURED CAROUSEL
// ─────────────────────────────────────────────
class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({
    required this.ctrl,
    required this.onPageChanged,
    required this.currentIndex,
  });
  final PageController ctrl;
  final ValueChanged<int> onPageChanged;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onPageChanged,
            itemCount: _featured.length,
            itemBuilder: (_, i) {
              final m = _featured[i];
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
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_featured.length, (i) {
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
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            movie.color,
            movie.color.withOpacity(0.6),
            Colors.black.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: movie.color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(painter: _CardPatternPainter(movie.color)),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Rating badge
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
                        movie.rating.toString(),
                        style: GoogleFonts.dmSans(
                          color: C.cream, fontSize: 12, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  style: GoogleFonts.dmSans(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800, height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${movie.year}  •  ${movie.duration}  •  ${movie.genre}',
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
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.3),
        40.0 + i * 25,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
//  CATEGORY TABS (All, Adventure, Comedy...)
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
//  FILTER TABS (Top Rated / New / Trending)
// ─────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  static const _tabs = ['Top Rated', 'New', 'Trending', 'Movies'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Text(
                    _tabs[i],
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
//  MOVIE GRID  (2 columns)
// ─────────────────────────────────────────────
class _MovieGrid extends StatelessWidget {
  const _MovieGrid({required this.movies});
  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: movies.length > 4 ? 4 : movies.length,
        itemBuilder: (_, i) => _MovieCard(movie: movies[i]),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(
          title: movie.title,
          year: movie.year,
          duration: movie.duration,
          rating: movie.rating,
          genre: movie.genre,
          color: movie.color,
        )));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              movie.color.withOpacity(0.9),
              movie.color.withOpacity(0.4),
              Colors.black.withOpacity(0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: movie.color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(painter: _CardPatternPainter(movie.color)),
              ),
            ),
            // HD/SD badge
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: movie.isHD ? C.hdGreen : C.sdOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  movie.isHD ? 'HD' : 'SD',
                  style: GoogleFonts.spaceMono(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Bookmark
            Positioned(
              top: 8, right: 8,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 16),
              ),
            ),
            // Movie title icon (big)
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: Colors.white.withOpacity(0.15),
                  size: 64,
                ),
              ),
            ),
            // Info at bottom
            Positioned(
              left: 10, right: 10, bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        movie.year,
                        style: GoogleFonts.dmSans(color: C.sub, fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, color: C.sub, size: 3),
                      const SizedBox(width: 6),
                      Text(
                        movie.duration,
                        style: GoogleFonts.dmSans(color: C.sub, fontSize: 11),
                      ),
                    ],
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
//  HORIZONTAL MOVIE LIST
// ─────────────────────────────────────────────
class _HorizontalMovieList extends StatelessWidget {
  const _HorizontalMovieList({required this.movies});
  final List<Movie> movies;

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
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    m.color.withOpacity(0.9),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: m.color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomPaint(painter: _CardPatternPainter(m.color)),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white.withOpacity(0.12),
                        size: 50,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8, right: 8, bottom: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
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
                              m.year,
                              style: GoogleFonts.dmSans(color: C.sub, fontSize: 10),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, color: C.gold, size: 11),
                            const SizedBox(width: 2),
                            Text(
                              m.rating.toString(),
                              style: GoogleFonts.dmSans(color: C.gold, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.search_rounded, label: 'Search'),
    (icon: Icons.favorite_rounded, label: 'Favorites'),
    (icon: Icons.person_rounded, label: 'Profile'),
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
          // middle FAB-style search
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
                Icon(
                  _items[i].icon,
                  color: active ? C.gold : C.sub,
                  size: 24,
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 4 : 0,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: C.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}