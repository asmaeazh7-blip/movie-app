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

  TmdbMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.overview,
    required this.genreIds,
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
//  TMDB DETAIL MODEL
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
//  TMDB SERVICE
// ─────────────────────────────────────────────
class TMDBService {
  static const String _apiKey = '6576f7c2be57854246647e8d7dd6bf41';
  static const String _base   = 'https://api.themoviedb.org/3';

  Future<List<TmdbMovie>> fetchByCountryAndGenre(String countryCode, int genreId) async {
    final url =
        '$_base/discover/movie?api_key=$_apiKey&language=en-US&sort_by=popularity.desc'
        '&with_origin_country=$countryCode&with_genres=$genreId&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<List<TmdbMovie>> fetchByCountry(String countryCode) async {
    final url =
        '$_base/discover/movie?api_key=$_apiKey&language=en-US&sort_by=popularity.desc&with_origin_country=$countryCode&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<List<TmdbMovie>> fetchByGenre(int genreId) async {
    final url =
        '$_base/discover/movie?api_key=$_apiKey&language=en-US&sort_by=popularity.desc&with_genres=$genreId&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  Future<List<TmdbMovie>> fetchPopular()    => _fetch('movie/popular');
  Future<List<TmdbMovie>> fetchTopRated()   => _fetch('movie/top_rated');
  Future<List<TmdbMovie>> fetchNowPlaying() => _fetch('movie/now_playing');
  Future<List<TmdbMovie>> fetchTrending()   => _fetch('trending/movie/week');

  Future<List<TmdbMovie>> searchMovies(String query) async {
    final url = '$_base/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => TmdbMovie.fromJson(e)).toList();
    } else {
      throw Exception('TMDB error: ${response.statusCode}');
    }
  }

  /// Fetch full movie detail: runtime, genres, cast, backdrops, trailer
  Future<TmdbMovieDetail> fetchMovieDetail(int movieId) async {
    final detailUrl =
        '$_base/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=credits,images,videos';
    final response = await http.get(Uri.parse(detailUrl));
    if (response.statusCode != 200) {
      throw Exception('TMDB detail error: ${response.statusCode}');
    }
    final data = json.decode(response.body);

    // Genres
    final genres = (data['genres'] as List? ?? [])
        .map((g) => g['name'] as String)
        .toList();

    // Cast (top 10)
    final castList = (data['credits']?['cast'] as List? ?? [])
        .take(10)
        .map((c) => TmdbCastMember.fromJson(c))
        .toList();

    // Backdrops (top 5, no language filter)
    final backdrops = ((data['images']?['backdrops'] as List?) ?? [])
        .take(5)
        .map((b) => TmdbImage.fromJson(b))
        .toList();

    // Trailer
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

  Future<List<TmdbMovie>> _fetch(String endpoint) async {
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
}

// ─────────────────────────────────────────────
//  TMDB GENRE IDs
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