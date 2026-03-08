import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsService {
  static final LyricsService _instance = LyricsService._();
  factory LyricsService() => _instance;
  LyricsService._();

  // In-memory cache: "artist|title" -> lyrics
  final Map<String, String> _cache = {};

  /// Fetch lyrics for a given artist and title.
  /// Returns the lyrics string, or null if not found.
  Future<String?> fetchLyrics(String artist, String title) async {
    // Clean up artist/title
    final cleanArtist = _clean(artist);
    final cleanTitle = _clean(title);

    if (cleanArtist.isEmpty || cleanTitle.isEmpty) return null;

    final cacheKey = '$cleanArtist|$cleanTitle';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final uri = Uri.parse(
        'https://api.lyrics.ovh/v1/${Uri.encodeComponent(cleanArtist)}/${Uri.encodeComponent(cleanTitle)}',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lyrics = data['lyrics'] as String?;
        if (lyrics != null && lyrics.trim().isNotEmpty) {
          _cache[cacheKey] = lyrics.trim();
          return _cache[cacheKey];
        }
      }
    } catch (_) {
      // Network error or timeout — return null
    }

    return null;
  }

  String _clean(String input) {
    // Remove text in parentheses/brackets, "feat.", etc.
    return input
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'feat\.?.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'ft\.?.*', caseSensitive: false), '')
        .trim();
  }
}
