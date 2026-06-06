import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmbd_service.dart';
import 'series_detail_screen.dart';

// ─────────────────────────────────────────────
//  COLORS (shared with home_screen)
// ─────────────────────────────────────────────
class SRC {
  static const bg       = Color(0xFF0D0D0D);
  static const card     = Color(0xFF1A1A1A);
  static const card2    = Color(0xFF222222);
  static const purple   = Color(0xFF2B124C);
  static const wine     = Color(0xFF662549);
  static const rose     = Color(0xFFAF445A);
  static const gold     = Color(0xFFC9A76C);
  static const cream    = Color(0xFFFBE4D8);
  static const accent   = Color(0xFFE8435A);
  static const text     = Color(0xFFEEEEEE);
  static const sub      = Color(0xFF777777);
  static const divider  = Color(0xFF2A2A2A);
}

const _seriesTabLabels = ['Popular', 'Top Rated', 'Trending', 'On Air'];

const _seriesCategories = [
  'All', 'Action', 'Comedy', 'Drama', 'Sci-Fi', 'Mystery', 'Crime', 'Animation'
];

const _seriesCountries = <String, String>{
  'TR': '🇹🇷 Turkey',
  'KR': '🇰🇷 Korea',
  'IN': '🇮🇳 India',
  'MA': '🇲🇦 Morocco',
  'JP': '🇯🇵 Japan',
  'ES': '🇪🇸 Spain',
  'FR': '🇫🇷 France',
  'IT': '🇮🇹 Italy',
  'US': '🇺🇸 USA',
};

// ─────────────────────────────────────────────
//  SERIES SCREEN
// ─────────────────────────────────────────────
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final _svc = TMDBService();

  int _catIndex = 0;
  int _tabIndex = 0;
  String? _selectedCountry;

  late Future<List<TmdbSeries>> _popularFuture;
  late Future<List<TmdbSeries>> _topRatedFuture;
  late Future<List<TmdbSeries>> _trendingFuture;
  late Future<List<TmdbSeries>> _airingFuture;

  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();
  Future<List<TmdbSeries>>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    final country = _selectedCountry;
    final genreId = _catIndex > 0
        ? tmdbTvGenreIds[_seriesCategories[_catIndex]]
        : null;

    if (country != null) {
      final f = _svc.fetchSeriesByCountry(country);
      _popularFuture  = f;
      _topRatedFuture = f;
      _trendingFuture = f;
      _airingFuture   = f;
    } else if (genreId != null) {
      final f = _svc.fetchSeriesByGenre(genreId);
      _popularFuture  = f;
      _topRatedFuture = f;
      _trendingFuture = f;
      _airingFuture   = f;
    } else {
      _popularFuture  = _svc.fetchPopularSeries();
      _topRatedFuture = _svc.fetchTopRatedSeries();
      _trendingFuture = _svc.fetchTrendingSeries();
      _airingFuture   = _svc.fetchAiringToday();
    }
  }

  Future<List<TmdbSeries>> get _tabFuture {
    switch (_tabIndex) {
      case 1: return _topRatedFuture;
      case 2: return _trendingFuture;
      case 3: return _airingFuture;
      default: return _popularFuture;
    }
  }

  void _onSearch(String q) {
    if (q.trim().isEmpty) {
      setState(() => _searchFuture = null);
      return;
    }
    setState(() => _searchFuture = _svc.searchSeries(q.trim()));
  }

  void _openCountrySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SRC.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CountrySheet(
        selected: _selectedCountry,
        onSelect: (code) {
          setState(() {
            _selectedCountry = code;
            _loadAll();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SRC.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            // Search field
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: _searchOpen
                  ? _buildSearchField()
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: _searchFuture != null
                  ? _buildSearchResults()
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            'Series',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Country filter
          GestureDetector(
            onTap: _openCountrySheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedCountry != null ? SRC.wine : SRC.card2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedCountry != null ? SRC.rose : SRC.divider,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCountry != null
                        ? _seriesCountries[_selectedCountry]!
                        : '🌍 All',
                    style: GoogleFonts.lato(
                        color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Search icon
          GestureDetector(
            onTap: () => setState(() {
              _searchOpen = !_searchOpen;
              if (!_searchOpen) {
                _searchCtrl.clear();
                _searchFuture = null;
              }
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _searchOpen ? SRC.accent : SRC.card2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        style: GoogleFonts.lato(color: Colors.white),
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search series...',
          hintStyle: GoogleFonts.lato(color: SRC.sub),
          prefixIcon: const Icon(Icons.search_rounded, color: SRC.sub),
          filled: true,
          fillColor: SRC.card2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ── Main body
  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // Featured hero
        SliverToBoxAdapter(child: _buildFeatured()),
        // Category pills
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: _buildCategoryPills(),
          ),
        ),
        // Tab strip
        SliverToBoxAdapter(child: _buildTabStrip()),
        // Grid
        SliverToBoxAdapter(child: _buildGrid()),
      ],
    );
  }

  // ── Featured carousel (popular)
  Widget _buildFeatured() {
    return FutureBuilder<List<TmdbSeries>>(
      future: _popularFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: SRC.accent),
            ),
          );
        }
        final list = snap.data ?? [];
        if (list.isEmpty) return const SizedBox.shrink();

        // Show top 5 as horizontal featured
        return SizedBox(
          height: 200,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: list.take(5).length,
            itemBuilder: (_, i) {
              final s = list[i];
              return GestureDetector(
                onTap: () => _goToDetail(s),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 20, 8, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: s.backdropUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: s.backdropUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(color: SRC.purple),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xDD0D0D0D),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: SRC.accent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '📺 SERIES',
                                style: GoogleFonts.spaceMono(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.name,
                              style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: SRC.gold, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  s.ratingRounded.toString(),
                                  style: GoogleFonts.spaceMono(
                                      color: SRC.gold, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s.year,
                                  style: GoogleFonts.spaceMono(
                                      color: SRC.sub, fontSize: 11),
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
      },
    );
  }

  // ── Category pills
  Widget _buildCategoryPills() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _seriesCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _catIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _catIndex = i;
              _loadAll();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [SRC.accent, SRC.wine])
                    : null,
                color: selected ? null : SRC.card2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.transparent : SRC.divider,
                ),
              ),
              child: Text(
                _seriesCategories[i],
                style: GoogleFonts.lato(
                  color: selected ? Colors.white : SRC.sub,
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab strip
  Widget _buildTabStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: List.generate(_seriesTabLabels.length, (i) {
          final sel = i == _tabIndex;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? SRC.accent.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _seriesTabLabels[i],
                style: GoogleFonts.lato(
                  color: sel ? SRC.accent : SRC.sub,
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Series grid
  Widget _buildGrid() {
    return FutureBuilder<List<TmdbSeries>>(
      future: _tabFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
                child: CircularProgressIndicator(color: SRC.accent)),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'Failed to load series.',
                style: GoogleFonts.lato(color: SRC.sub),
              ),
            ),
          );
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No series found.',
                style: GoogleFonts.lato(color: SRC.sub),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: list.length,
          itemBuilder: (_, i) => _SeriesCard(
            series: list[i],
            onTap: () => _goToDetail(list[i]),
          ),
        );
      },
    );
  }

  // ── Search results
  Widget _buildSearchResults() {
    return FutureBuilder<List<TmdbSeries>>(
      future: _searchFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: SRC.accent));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return Center(
            child: Text('No series found.',
                style: GoogleFonts.lato(color: SRC.sub)),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: list.length,
          itemBuilder: (_, i) => _SeriesCard(
            series: list[i],
            onTap: () => _goToDetail(list[i]),
          ),
        );
      },
    );
  }

  void _goToDetail(TmdbSeries s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeriesDetailScreen(
          seriesId: s.id,
          name: s.name,
          year: s.year,
          rating: s.ratingRounded,
          overview: s.overview,
          posterUrl: s.posterUrl,
          backdropUrl: s.backdropUrl,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SERIES CARD
// ─────────────────────────────────────────────
class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series, required this.onTap});
  final TmdbSeries series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  series.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: series.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: SRC.card2),
                          errorWidget: (_, __, ___) =>
                              Container(color: SRC.card2),
                        )
                      : Container(
                          color: SRC.card2,
                          child: const Icon(Icons.tv_rounded,
                              color: SRC.sub, size: 40),
                        ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: SRC.gold, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            series.ratingRounded.toString(),
                            style: GoogleFonts.spaceMono(
                                color: SRC.gold, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // TV badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: SRC.accent.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'TV',
                        style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            series.name,
            style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            series.year,
            style: GoogleFonts.spaceMono(color: SRC.sub, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COUNTRY SHEET
// ─────────────────────────────────────────────
class _CountrySheet extends StatelessWidget {
  const _CountrySheet({required this.selected, required this.onSelect});
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Country',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // All option
            _CountryTile(
              flag: '🌍',
              label: 'All Countries',
              selected: selected == null,
              onTap: () => onSelect(null),
            ),
            const SizedBox(height: 8),
            ..._seriesCountries.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CountryTile(
                  flag: e.value.split(' ')[0],
                  label: e.value.substring(3),
                  selected: selected == e.key,
                  onTap: () => onSelect(e.key),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? SRC.wine : SRC.card2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? SRC.rose : SRC.divider),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: SRC.gold, size: 20),
          ],
        ),
      ),
    );
  }
}