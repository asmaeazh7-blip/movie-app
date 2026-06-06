import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmbd_service.dart';
import 'Youtube_screen.dart';
import 'watch_screen.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class SC {
  static const bg      = Color(0xFF0D0D0D);
  static const card    = Color(0xFF1A1A1A);
  static const card2   = Color(0xFF222222);
  static const accent  = Color(0xFFE8435A);
  static const gold    = Color(0xFFC9A76C);
  static const cream   = Color(0xFFFBE4D8);
  static const sub     = Color(0xFF888888);
  static const divider = Color(0xFF2A2A2A);
  static const purple  = Color(0xFF2B124C);
  static const wine    = Color(0xFF662549);
  static const rose    = Color(0xFFAF445A);
}

// ─────────────────────────────────────────────
//  SERIES DETAIL SCREEN
// ─────────────────────────────────────────────
class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({
    super.key,
    required this.seriesId,
    required this.name,
    required this.year,
    required this.rating,
    required this.overview,
    this.posterUrl,
    this.backdropUrl,
    this.genreStr,
  });

  final int seriesId;
  final String name;
  final String year;
  final double rating;
  final String overview;
  final String? posterUrl;
  final String? backdropUrl;
  final String? genreStr;

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen>
    with SingleTickerProviderStateMixin {
  final _svc = TMDBService();

  TmdbSeriesDetail? _detail;
  bool _loadingDetail = true;

  // Season / episode state
  int _selectedSeasonIndex = 0;
  List<TmdbEpisode>? _episodes;
  bool _loadingEpisodes = false;

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
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroCtrl.forward();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _svc.fetchSeriesDetail(widget.seriesId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _loadingDetail = false;
        });
        if (detail.seasons.isNotEmpty) {
          _loadEpisodes(detail.seasons[0].seasonNumber);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _loadEpisodes(int seasonNumber) async {
    setState(() { _loadingEpisodes = true; _episodes = null; });
    try {
      final eps = await _svc.fetchSeasonEpisodes(widget.seriesId, seasonNumber);
      if (mounted) setState(() { _episodes = eps; _loadingEpisodes = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingEpisodes = false);
    }
  }

  void _watchEpisode(TmdbEpisode episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WatchScreen(
          seriesId: widget.seriesId,
          seriesName: widget.name,
          episodeName: episode.name,
          episodeNumber: episode.episodeNumber,
          seasonNumber: _selectedSeasonIndex + 1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  String get _displayName   => _detail?.name     ?? widget.name;
  String get _displayYear   => _detail?.year      ?? widget.year;
  double get _displayRating => _detail?.ratingRounded ?? widget.rating;
  String get _displayOverview => _detail?.overview ?? widget.overview;
  String get _displayGenre  => _detail?.genreStr  ?? widget.genreStr ?? '';
  String get _backdrop      => _detail?.backdropUrl ?? widget.backdropUrl ?? '';
  String get _poster        => _detail?.posterUrl  ?? widget.posterUrl  ?? '';

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SC.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  // ── AppBar with backdrop
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: SC.bg,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _bookmarked ? SC.gold : Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => setState(() => _bookmarked = !_bookmarked),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _backdrop.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _backdrop,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: SC.purple),
                    errorWidget: (_, __, ___) =>
                        Container(color: SC.purple),
                  )
                : Container(color: SC.purple),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x880D0D0D),
                    Color(0xFF0D0D0D),
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            // TV Badge
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SC.rose, SC.wine],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '📺 TV Series',
                  style: GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Play trailer button — always visible
            Center(
              child: GestureDetector(
                onTap: _detail?.trailerKey != null
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YoutubeScreen(
                            trailerKey: _detail!.trailerKey!,
                            title: _displayName,
                          ),
                        ),
                      )
                    : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _loadingDetail
                        ? Colors.black45
                        : _detail?.trailerKey != null
                            ? SC.accent.withOpacity(0.9)
                            : Colors.black45,
                    shape: BoxShape.circle,
                    boxShadow: _detail?.trailerKey != null
                        ? [
                            BoxShadow(
                                color: SC.accent.withOpacity(0.5),
                                blurRadius: 20),
                          ]
                        : [],
                  ),
                  child: _loadingDetail
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          _detail?.trailerKey != null
                              ? Icons.play_arrow_rounded
                              : Icons.play_disabled_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main content
  Widget _buildContent() {
    return FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroInfo(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 24),
            if (_detail != null) ...[
              _buildStats(),
              const SizedBox(height: 24),
            ],
            _buildOverview(),
            const SizedBox(height: 24),
            if (_detail != null && _detail!.cast.isNotEmpty) ...[
              _buildCast(),
              const SizedBox(height: 24),
            ],
            if (_detail != null && _detail!.seasons.isNotEmpty) ...[
              _buildSeasonsSection(),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Hero info row
  Widget _buildHeroInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Poster
          if (_poster.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: _poster,
                width: 90,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 90, height: 130,
                  color: SC.card2,
                  child: const Icon(Icons.tv_rounded, color: SC.sub),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 90, height: 130, color: SC.card2,
                  child: const Icon(Icons.tv_rounded, color: SC.sub),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: SC.gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _displayRating.toString(),
                      style: GoogleFonts.spaceMono(
                          color: SC.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _displayYear,
                      style: GoogleFonts.spaceMono(color: SC.sub, fontSize: 13),
                    ),
                  ],
                ),
                if (_displayGenre.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _displayGenre,
                    style: GoogleFonts.spaceMono(color: SC.sub, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_detail != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _detail!.status == 'Ended'
                          ? SC.sub.withOpacity(0.2)
                          : SC.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _detail!.status == 'Ended' ? SC.sub : SC.accent,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _detail!.status,
                      style: GoogleFonts.spaceMono(
                        color: _detail!.status == 'Ended' ? SC.sub : SC.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons
  Widget _buildActionButtons() {
    final hasTrailer = _detail?.trailerKey != null;
    final isLoading  = _loadingDetail;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Watch Trailer button
          Expanded(
            child: GestureDetector(
              onTap: hasTrailer
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => YoutubeScreen(
                          trailerKey: _detail!.trailerKey!,
                          title: _displayName,
                        ),
                      ),
                    )
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasTrailer
                        ? [SC.accent, SC.wine]
                        : [SC.sub, SC.card2],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: hasTrailer
                      ? [
                          BoxShadow(
                              color: SC.accent.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4)),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    else
                      Icon(
                        hasTrailer
                            ? Icons.play_arrow_rounded
                            : Icons.videocam_off_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isLoading
                          ? 'Loading...'
                          : hasTrailer
                              ? 'Watch Trailer'
                              : 'No Trailer',
                      style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: SC.card2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _liked ? SC.accent : SC.divider, width: 1),
              ),
              child: Icon(
                _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _liked ? SC.accent : SC.sub,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row: seasons / episodes
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.layers_rounded,
            value: '${_detail!.numberOfSeasons}',
            label: _detail!.numberOfSeasons == 1 ? 'Season' : 'Seasons',
          ),
          const SizedBox(width: 12),
          _StatChip(
            icon: Icons.play_circle_outline_rounded,
            value: '${_detail!.numberOfEpisodes}',
            label: 'Episodes',
          ),
        ],
      ),
    );
  }

  // ── Overview
  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synopsis',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _displayOverview.isNotEmpty ? _displayOverview : 'No overview available.',
            style: GoogleFonts.lato(color: SC.sub, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Cast
  Widget _buildCast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Cast',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _detail!.cast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final member = _detail!.cast[i];
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: member.profileUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: member.profileUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: SC.card2,
                            child: const Icon(Icons.person_rounded,
                                color: SC.sub, size: 28),
                          ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 68,
                    child: Text(
                      member.name,
                      style: GoogleFonts.lato(
                          color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 68,
                    child: Text(
                      member.character,
                      style: GoogleFonts.lato(color: SC.sub, fontSize: 9),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Seasons & Episodes section
  Widget _buildSeasonsSection() {
    final seasons = _detail!.seasons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'المواسم والحلقات',  // "Seasons & Episodes" in Arabic
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        // Season tabs
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: seasons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final selected = i == _selectedSeasonIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSeasonIndex = i);
                  _loadEpisodes(seasons[i].seasonNumber);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(colors: [SC.accent, SC.wine])
                        : null,
                    color: selected ? null : SC.card2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? Colors.transparent : SC.divider,
                    ),
                  ),
                  child: Text(
                    seasons[i].name.contains('Season')
                        ? 'S${seasons[i].seasonNumber}'
                        : seasons[i].name,
                    style: GoogleFonts.spaceMono(
                      color: selected ? Colors.white : SC.sub,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Season info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                seasons[_selectedSeasonIndex].name,
                style: GoogleFonts.lato(
                    color: SC.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${seasons[_selectedSeasonIndex].episodeCount} episodes'
                '  ${seasons[_selectedSeasonIndex].year}',
                style: GoogleFonts.lato(color: SC.sub, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Episodes list
        _loadingEpisodes
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: SC.accent),
                ),
              )
            : _episodes == null || _episodes!.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Text(
                      'No episodes available.',
                      style: GoogleFonts.lato(color: SC.sub, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _episodes!.length,
                    separatorBuilder: (_, __) => Divider(
                      color: SC.divider,
                      height: 1,
                    ),
                    itemBuilder: (_, i) => _EpisodeTile(
                      episode: _episodes![i],
                      onWatch: () => _watchEpisode(_episodes![i]),
                    ),
                  ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  STAT CHIP
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: SC.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SC.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: SC.gold, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: GoogleFonts.lato(color: SC.sub, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EPISODE TILE
// ─────────────────────────────────────────────
class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode, required this.onWatch});
  final TmdbEpisode episode;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: episode.stillUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: episode.stillUrl,
                    width: 110,
                    height: 66,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 110,
                      height: 66,
                      color: SC.card2,
                      child: const Icon(Icons.play_circle_outline_rounded,
                          color: SC.sub),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 110,
                      height: 66,
                      color: SC.card2,
                      child: const Icon(Icons.play_circle_outline_rounded,
                          color: SC.sub),
                    ),
                  )
                : Container(
                    width: 110,
                    height: 66,
                    color: SC.card2,
                    child: const Icon(Icons.play_circle_outline_rounded,
                        color: SC.sub),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SC.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'E${episode.episodeNumber.toString().padLeft(2, '0')}',
                        style: GoogleFonts.spaceMono(
                            color: SC.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (episode.durationStr.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        episode.durationStr,
                        style:
                            GoogleFonts.spaceMono(color: SC.sub, fontSize: 9),
                      ),
                    ],
                    const Spacer(),
                    if (episode.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: SC.gold, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            episode.rating.toStringAsFixed(1),
                            style: GoogleFonts.spaceMono(
                                color: SC.gold, fontSize: 10),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  episode.name,
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  episode.overview.isNotEmpty
                      ? episode.overview
                      : 'No description available.',
                  style: GoogleFonts.lato(color: SC.sub, fontSize: 11, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onWatch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [SC.accent, SC.wine]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'شاهد الحلقة',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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