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
//  TMDB SERVICE
// ─────────────────────────────────────────────
class TMDBService {
  static const String _apiKey = '6576f7c2be57854246647e8d7dd6bf41';
  static const String _base   = 'https://api.themoviedb.org/3';

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