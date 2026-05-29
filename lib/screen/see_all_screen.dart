import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmbd_service.dart';
import 'movie_detail_screen.dart';


// ─────────────────────────────────────────────
//  SEE ALL SCREEN
// ─────────────────────────────────────────────
class SeeAllScreen extends StatefulWidget {
  final String title;
  final Future<List<TmdbMovie>> future;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.future,
  });

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  String _sortBy = 'rating'; // 'rating' | 'year' | 'title'

  List<TmdbMovie> _sorted(List<TmdbMovie> movies) {
    final list = List<TmdbMovie>.from(movies);
    switch (_sortBy) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'year':
        list.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        break;
      case 'title':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFEEEEEE), size: 20),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFFFBE4D8),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Sort dropdown
                  _SortButton(
                    value: _sortBy,
                    onChanged: (v) => setState(() => _sortBy = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Grid
            Expanded(
              child: FutureBuilder<List<TmdbMovie>>(
                future: widget.future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFC9A76C)),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Erreur de chargement 😕',
                        style: GoogleFonts.dmSans(
                            color: const Color(0xFF777777)),
                      ),
                    );
                  }
                  if (!snap.hasData || snap.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun film trouvé',
                        style: GoogleFonts.dmSans(
                            color: const Color(0xFF777777)),
                      ),
                    );
                  }

                  final movies = _sorted(snap.data!);

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (_, i) => _MovieCard(movie: movies[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SORT BUTTON
// ─────────────────────────────────────────────
class _SortButton extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SortButton({required this.value, required this.onChanged});

  String get _label {
    switch (value) {
      case 'rating': return '⭐ Note';
      case 'year':   return '📅 Année';
      case 'title':  return '🔤 Titre';
      default:       return 'Trier';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1A1A1A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _SortSheet(
            current: value,
            onSelect: (v) {
              Navigator.pop(context);
              onChanged(v);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFFAF445A).withOpacity(0.5)),
        ),
        child: Text(
          _label,
          style: GoogleFonts.dmSans(
            color: const Color(0xFFAF445A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SORT SHEET
// ─────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _SortSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('rating', '⭐', 'Note'),
      ('year',   '📅', 'Année de sortie'),
      ('title',  '🔤', 'Titre (A-Z)'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trier par',
            style: GoogleFonts.dmSans(
              color: const Color(0xFFFBE4D8),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final isSelected = current == opt.$1;
            return GestureDetector(
              onTap: () => onSelect(opt.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFAF445A).withOpacity(0.15)
                      : const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: const Color(0xFFAF445A))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(opt.$2,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Text(
                      opt.$3,
                      style: GoogleFonts.dmSans(
                        color: isSelected
                            ? const Color(0xFFAF445A)
                            : const Color(0xFFEEEEEE),
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded,
                          color: Color(0xFFAF445A), size: 18),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COLOR HELPER
// ─────────────────────────────────────────────
Color _seeAllMovieColor(TmdbMovie m) {
  const colors = [
    Color(0xFF8B4513), Color(0xFFB8860B), Color(0xFF4169E1),
    Color(0xFF2E8B57), Color(0xFF8B6914), Color(0xFF4A4A6A),
    Color(0xFF556B2F), Color(0xFF1C3A5E), Color(0xFF2C1810),
    Color(0xFF3D2B1F), Color(0xFF4A3728), Color(0xFF5C3317),
    Color(0xFF1A3A4A), Color(0xFF3B1F2B),
  ];
  return colors[m.id % colors.length];
}

// ─────────────────────────────────────────────
//  MOVIE CARD
// ─────────────────────────────────────────────
class _MovieCard extends StatelessWidget {
  final TmdbMovie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
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
            color: _seeAllMovieColor(movie),
            description: movie.overview,
            movieId: movie.id,
            posterUrl: movie.posterUrl,
            backdropUrl: movie.backdropUrl,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFF1A1A1A),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC9A76C),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF1A1A1A),
                        child: const Icon(Icons.movie_outlined,
                            color: Color(0xFF777777)),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Icon(Icons.movie_outlined,
                          color: Color(0xFF777777)),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: const Color(0xFFEEEEEE),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          // Rating + Year
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFC9A76C), size: 11),
              const SizedBox(width: 2),
              Text(
                movie.ratingRounded.toString(),
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFC9A76C),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                movie.year,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF777777),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}