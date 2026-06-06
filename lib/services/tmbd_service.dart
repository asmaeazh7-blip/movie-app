import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  TMDB MOVIE MODEL
// ─────────────────────────────────────────────
class TmdbMovie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double rating;
  final String overview;
  final List<int> genreIds;
  final String originalLanguage;

  TmdbMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.overview,
    required this.genreIds,
    this.originalLanguage = '',
  });

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originalLanguage: json['original_language'] ?? '',
    );
  }

  String get year => releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '----';
  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
  double get ratingRounded => double.parse(rating.toStringAsFixed(1));
}

// ─────────────────────────────────────────────
//  TMDB TV SERIES MODEL
// ─────────────────────────────────────────────
class TmdbSeries {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final double rating;
  final String overview;
  final List<int> genreIds;
  final String originalLanguage;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;

  TmdbSeries({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    required this.firstAirDate,
    required this.rating,
    required this.overview,
    required this.genreIds,
    this.originalLanguage = '',
    this.numberOfSeasons,
    this.numberOfEpisodes,
  });

  factory TmdbSeries.fromJson(Map<String, dynamic> json) {
    return TmdbSeries(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['original_name'] ?? 'Unknown',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      firstAirDate: json['first_air_date'] ?? '',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      overview: json['overview'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      numberOfSeasons: json['number_of_seasons'],
      numberOfEpisodes: json['number_of_episodes'],
    );
  }

  String get year => firstAirDate.isNotEmpty ? firstAirDate.substring(0, 4) : '----';
  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
  double get ratingRounded => double.parse(rating.toStringAsFixed(1));
}

// ─────────────────────────────────────────────
//  TMDB TV SERIES DETAIL MODEL
// ─────────────────────────────────────────────
class TmdbSeriesDetail {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final double rating;
  final String overview;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<String> genres;
  final List<TmdbCastMember> cast;
  final List<TmdbSeriesSeason> seasons;
  final String? trailerKey;
  final String status;

  TmdbSeriesDetail({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    required this.firstAirDate,
    required this.rating,
    required this.overview,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.genres,
    required this.cast,
    required this.seasons,
    this.trailerKey,
    required this.status,
  });

  String get year => firstAirDate.isNotEmpty ? firstAirDate.substring(0, 4) : '----';
  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
  double get ratingRounded => double.parse(rating.toStringAsFixed(1));
  String get genreStr => genres.take(2).join(' • ');
}

// ─────────────────────────────────────────────
//  TMDB TV SEASON MODEL
// ─────────────────────────────────────────────
class TmdbSeriesSeason {
  final int id;
  final int seasonNumber;
  final String name;
  final String? posterPath;
  final String? airDate;
  final int episodeCount;
  final String overview;

  TmdbSeriesSeason({
    required this.id,
    required this.seasonNumber,
    required this.name,
    this.posterPath,
    this.airDate,
    required this.episodeCount,
    required this.overview,
  });

  factory TmdbSeriesSeason.fromJson(Map<String, dynamic> json) {
    return TmdbSeriesSeason(
      id: json['id'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      name: json['name'] ?? 'Season ${json['season_number']}',
      posterPath: json['poster_path'],
      airDate: json['air_date'],
      episodeCount: json['episode_count'] ?? 0,
      overview: json['overview'] ?? '',
    );
  }

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
  String get year =>
      (airDate != null && airDate!.isNotEmpty) ? airDate!.substring(0, 4) : '----';
}

// ─────────────────────────────────────────────
//  TMDB EPISODE MODEL
// ─────────────────────────────────────────────
class TmdbEpisode {
  final int id;
  final int episodeNumber;
  final String name;
  final String? stillPath;
  final String? airDate;
  final double rating;
  final String overview;
  final int? runtime;

  TmdbEpisode({
    required this.id,
    required this.episodeNumber,
    required this.name,
    this.stillPath,
    this.airDate,
    required this.rating,
    required this.overview,
    this.runtime,
  });

  factory TmdbEpisode.fromJson(Map<String, dynamic> json) {
    return TmdbEpisode(
      id: json['id'] ?? 0,
      episodeNumber: json['episode_number'] ?? 0,
      name: json['name'] ?? 'Episode ${json['episode_number']}',
      stillPath: json['still_path'],
      airDate: json['air_date'],
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      overview: json['overview'] ?? '',
      runtime: json['runtime'],
    );
  }

  String get stillUrl => stillPath != null
      ? 'https://image.tmdb.org/t/p/w500$stillPath'
      : '';

  String get durationStr {
    if (runtime == null || runtime == 0) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  String get airYear =>
      (airDate != null && airDate!.isNotEmpty) ? airDate!.substring(0, 4) : '';
}

// ─────────────────────────────────────────────
//  TMDB DETAIL MODEL (Movies)
// ─────────────────────────────────────────────
class TmdbMovieDetail {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double rating;
  final String overview;
  final int? runtime;
  final List<String> genres;
  final List<TmdbCastMember> cast;
  final List<TmdbImage> backdrops;
  final String? trailerKey;

  TmdbMovieDetail({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.overview,
    this.runtime,
    required this.genres,
    required this.cast,
    required this.backdrops,
    this.trailerKey,
  });

  String get year => releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : '----';
  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
  double get ratingRounded => double.parse(rating.toStringAsFixed(1));
  String get durationStr {
    if (runtime == null || runtime == 0) return '—';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
  String get genreStr => genres.take(2).join(' • ');
}

class TmdbCastMember {
  final String name;
  final String character;
  final String? profilePath;

  TmdbCastMember({
    required this.name,
    required this.character,
    this.profilePath,
  });

  String get profileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w185$profilePath'
      : '';

  factory TmdbCastMember.fromJson(Map<String, dynamic> json) {
    return TmdbCastMember(
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}

class TmdbImage {
  final String filePath;
  TmdbImage({required this.filePath});
  String get url => 'https://image.tmdb.org/t/p/w500$filePath';
  factory TmdbImage.fromJson(Map<String, dynamic> json) =>
      TmdbImage(filePath: json['file_path'] ?? '');
}

// ─────────────────────────────────────────────
//  COUNTRY CONFIG
// ─────────────────────────────────────────────
class _CountryConfig {
  final String language;
  final String region;
  const _CountryConfig({required this.language, required this.region});
}

const _countryConfigs = <String, _CountryConfig>{
  'MA': _CountryConfig(language: 'ar', region: 'MA'),
  'TR': _CountryConfig(language: 'tr', region: 'TR'),
  'IN': _CountryConfig(language: 'hi', region: 'IN'),
  'KR': _CountryConfig(language: 'ko', region: 'KR'),
  'JP': _CountryConfig(language: 'ja', region: 'JP'),
};

// ─────────────────────────────────────────────
//  TMDB SERVICE
// ─────────────────────────────────────────────
class TMDBService {
  static const String _apiKey = '6576f7c2be57854246647e8d7dd6bf41';
  static const String _base   = 'https://api.themoviedb.org/3';

  // ── Fetch movies by country using 3 strategies combined
  Future<List<TmdbMovie>> fetchByCountry(String countryCode) async {
    final config = _countryConfigs[countryCode];

    final url1 = '$_base/discover/movie?api_key=$_apiKey&language=en-US'
        '&sort_by=popularity.desc&with_origin_country=$countryCode&page=1';
    final url2 = '$_base/discover/movie?api_key=$_apiKey&language=en-US'
        '&sort_by=popularity.desc&with_production_countries=$countryCode&page=1';
    final url3 = config != null
        ? '$_base/discover/movie?api_key=$_apiKey&language=en-US'
          '&sort_by=popularity.desc&with_original_language=${config.language}&page=1'
        : null;

    final futures = [
      http.get(Uri.parse(url1)),
      http.get(Uri.parse(url2)),
      if (url3 != null) http.get(Uri.parse(url3)),
    ];

    final responses = await Future.wait(futures);
    final seen = <int>{};
    final movies = <TmdbMovie>[];

    for (final response in responses) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        for (final e in results) {
          final movie = TmdbMovie.fromJson(e);
          if (seen.add(movie.id)) movies.add(movie);
        }
      }
    }

    if (countryCode == 'MA' && movies.isNotEmpty) {
      movies.sort((a, b) {
        final aScore = (a.originalLanguage == 'ar' ? 2 : a.originalLanguage == 'fr' ? 1 : 0);
        final bScore = (b.originalLanguage == 'ar' ? 2 : b.originalLanguage == 'fr' ? 1 : 0);
        if (aScore != bScore) return bScore.compareTo(aScore);
        return b.rating.compareTo(a.rating);
      });
      return movies;
    }

    movies.sort((a, b) => b.rating.compareTo(a.rating));
    return movies;
  }

  // ── Fetch by country + genre
  Future<List<TmdbMovie>> fetchByCountryAndGenre(String countryCode, int genreId) async {
    final config = _countryConfigs[countryCode];

    final url1 = '$_base/discover/movie?api_key=$_apiKey&language=en-US'
        '&sort_by=popularity.desc&with_origin_country=$countryCode&with_genres=$genreId&page=1';
    final url2 = config != null
        ? '$_base/discover/movie?api_key=$_apiKey&language=en-US'
          '&sort_by=popularity.desc&with_original_language=${config.language}&with_genres=$genreId&page=1'
        : null;

    final futures = [
      http.get(Uri.parse(url1)),
      if (url2 != null) http.get(Uri.parse(url2)),
    ];

    final responses = await Future.wait(futures);
    final seen = <int>{};
    final movies = <TmdbMovie>[];

    for (final response in responses) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        for (final e in results) {
          final movie = TmdbMovie.fromJson(e);
          if (seen.add(movie.id)) movies.add(movie);
        }
      }
    }

    movies.sort((a, b) => b.rating.compareTo(a.rating));
    return movies;
  }

  // ── Fetch by genre only
  Future<List<TmdbMovie>> fetchByGenre(int genreId) async {
    final url = '$_base/discover/movie?api_key=$_apiKey&language=en-US'
        '&sort_by=popularity.desc&with_genres=$genreId&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<List<TmdbMovie>> fetchPopular()    => _fetchMovies('movie/popular');
  Future<List<TmdbMovie>> fetchTopRated()   => _fetchMovies('movie/top_rated');
  Future<List<TmdbMovie>> fetchNowPlaying() => _fetchMovies('movie/now_playing');
  Future<List<TmdbMovie>> fetchTrending()   => _fetchMovies('trending/movie/week');

  Future<List<TmdbMovie>> searchMovies(String query) async {
    final url = '$_base/search/movie?api_key=$_apiKey&language=en-US'
        '&query=${Uri.encodeComponent(query)}&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<TmdbMovieDetail> fetchMovieDetail(int movieId) async {
    final detailUrl = '$_base/movie/$movieId?api_key=$_apiKey&language=en-US'
        '&append_to_response=credits,images,videos';
    final response = await http.get(Uri.parse(detailUrl));
    if (response.statusCode != 200) {
      throw Exception('TMDB detail error: ${response.statusCode}');
    }
    final data = json.decode(response.body);

    final genres = (data['genres'] as List? ?? [])
        .map((g) => g['name'] as String)
        .toList();

    final castList = (data['credits']?['cast'] as List? ?? [])
        .take(10)
        .map((c) => TmdbCastMember.fromJson(c))
        .toList();

    final backdrops = ((data['images']?['backdrops'] as List?) ?? [])
        .take(5)
        .map((b) => TmdbImage.fromJson(b))
        .toList();

    String? trailerKey;
    final videos = (data['videos']?['results'] as List? ?? []);
    final trailer = videos.firstWhere(
      (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
      orElse: () => null,
    );
    trailerKey = trailer?['key'];

    return TmdbMovieDetail(
      id: data['id'] ?? movieId,
      title: data['title'] ?? '',
      posterPath: data['poster_path'],
      backdropPath: data['backdrop_path'],
      releaseDate: data['release_date'] ?? '',
      rating: (data['vote_average'] ?? 0.0).toDouble(),
      overview: data['overview'] ?? '',
      runtime: data['runtime'],
      genres: genres,
      cast: castList,
      backdrops: backdrops,
      trailerKey: trailerKey,
    );
  }

  // ─────────────────────────────────────────────
  //  TV SERIES METHODS
  // ─────────────────────────────────────────────

  Future<List<TmdbSeries>> fetchPopularSeries()    => _fetchSeries('tv/popular');
  Future<List<TmdbSeries>> fetchTopRatedSeries()   => _fetchSeries('tv/top_rated');
  Future<List<TmdbSeries>> fetchAiringToday()      => _fetchSeries('tv/airing_today');
  Future<List<TmdbSeries>> fetchTrendingSeries()   => _fetchSeries('trending/tv/week');

  Future<List<TmdbSeries>> fetchSeriesByCountry(String countryCode) async {
    final config = _countryConfigs[countryCode];

    final url1 = '$_base/discover/tv?api_key=$_apiKey&language=en-US'
        '&sort_by=popularity.desc&with_origin_country=$countryCode&page=1';
    final url2 = config != null
        ? '$_base/discover/tv?api_key=$_apiKey&language=en-US'
          '&sort_by=popularity.desc&with_original_language=${config.language}&page=1'
        : null;

    final futures = [
      http.get(Uri.parse(url1)),
      if (url2 != null) http.get(Uri.parse(url2)),
    ];

    final responses = await Future.wait(futures);
    final seen = <int>{};
    final series = <TmdbSeries>[];

    for (final response in responses) {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        for (final e in results) {
          final s = TmdbSeries.fromJson(e);
          if (seen.add(s.id)) series.add(s);
        }
      }
    }

    series.sort((a, b) => b.rating.compareTo(a.rating));
    return series;
  }

  Future<List<TmdbSeries>> fetchSeriesByGenre(int genreId) async {
    final url = '$_base/discover/tv?api_key=$_apiKey&language=en-US'
        '&sort_by=popularity.desc&with_genres=$genreId&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbSeries.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<List<TmdbSeries>> searchSeries(String query) async {
    final url = '$_base/search/tv?api_key=$_apiKey&language=en-US'
        '&query=${Uri.encodeComponent(query)}&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbSeries.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<TmdbSeriesDetail> fetchSeriesDetail(int seriesId) async {
    final detailUrl = '$_base/tv/$seriesId?api_key=$_apiKey&language=en-US'
        '&append_to_response=credits,videos';
    final response = await http.get(Uri.parse(detailUrl));
    if (response.statusCode != 200) {
      throw Exception('TMDB series detail error: ${response.statusCode}');
    }
    final data = json.decode(response.body);

    final genres = (data['genres'] as List? ?? [])
        .map((g) => g['name'] as String)
        .toList();

    final castList = (data['credits']?['cast'] as List? ?? [])
        .take(10)
        .map((c) => TmdbCastMember.fromJson(c))
        .toList();

    // Filter out season 0 (Specials) unless it's the only one
    final rawSeasons = (data['seasons'] as List? ?? []);
    final seasons = rawSeasons
        .map((s) => TmdbSeriesSeason.fromJson(s))
        .where((s) => s.seasonNumber > 0)
        .toList();

    String? trailerKey;
    final videos = (data['videos']?['results'] as List? ?? []);
    final trailer = videos.firstWhere(
      (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
      orElse: () => null,
    );
    trailerKey = trailer?['key'];

    return TmdbSeriesDetail(
      id: data['id'] ?? seriesId,
      name: data['name'] ?? '',
      posterPath: data['poster_path'],
      backdropPath: data['backdrop_path'],
      firstAirDate: data['first_air_date'] ?? '',
      rating: (data['vote_average'] ?? 0.0).toDouble(),
      overview: data['overview'] ?? '',
      numberOfSeasons: data['number_of_seasons'] ?? 0,
      numberOfEpisodes: data['number_of_episodes'] ?? 0,
      genres: genres,
      cast: castList,
      seasons: seasons,
      trailerKey: trailerKey,
      status: data['status'] ?? '',
    );
  }

  Future<List<TmdbEpisode>> fetchSeasonEpisodes(int seriesId, int seasonNumber) async {
    final url = '$_base/tv/$seriesId/season/$seasonNumber'
        '?api_key=$_apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('TMDB season error: ${response.statusCode}');
    }
    final data = json.decode(response.body);
    final List episodes = data['episodes'] ?? [];
    return episodes.map((e) => TmdbEpisode.fromJson(e)).toList();
  }

  // ─────────────────────────────────────────────
  //  PRIVATE HELPERS
  // ─────────────────────────────────────────────

  Future<List<TmdbMovie>> _fetchMovies(String endpoint) async {
    final url = '$_base/$endpoint?api_key=$_apiKey&language=en-US&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data    = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<List<TmdbSeries>> _fetchSeries(String endpoint) async {
    final url = '$_base/$endpoint?api_key=$_apiKey&language=en-US&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data    = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbSeries.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }
}

// ─────────────────────────────────────────────
//  TMDB GENRE IDs (Movies)
// ─────────────────────────────────────────────
const tmdbGenreIds = {
  'Action':    28,
  'Comedy':    35,
  'Drama':     18,
  'Romance':   10749,
  'Sci-Fi':    878,
  'Horror':    27,
  'Fantasy':   14,
  'Adventure': 12,
};

// ─────────────────────────────────────────────
//  TMDB GENRE IDs (TV)
// ─────────────────────────────────────────────
const tmdbTvGenreIds = {
  'Action':    10759, // Action & Adventure
  'Comedy':    35,
  'Drama':     18,
  'Romance':   10749,
  'Sci-Fi':    10765, // Sci-Fi & Fantasy
  'Mystery':   9648,
  'Crime':     80,
  'Animation': 16,
};
