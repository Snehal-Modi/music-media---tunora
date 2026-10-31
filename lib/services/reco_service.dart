import '../models/track.dart';
import 'sources/music_source.dart';

/// A personalised mix shown on Home, e.g. "Arijit Singh mix".
class Mix {
  final String title;
  final String subtitle;
  final List<Track> tracks;
  const Mix({required this.title, required this.subtitle, required this.tracks});
}

/// "More like this": the engine behind Home mixes and the auto-filled queue.
class RecoService {
  RecoService._();

  /// Songs to play after [seed]: its artist's radio, the listener's other
  /// favourite voices, and what is trending in the language, blended so the
  /// queue changes singer often. Never repeats a song in [exclude].
  static Future<List<Track>> similarTo(
    Track seed, {
    Iterable<Track> exclude = const [],
    String? language,
    List<String> favourites = const [],
  }) async {
    final seen = <String>{seed.songKey, ...exclude.map((t) => t.songKey)};
    final lang = seed.lang ?? language ?? 'hindi';
    final artist = await _realArtist(seed);
    if (artist == null) return const [];

    final others = favourites.where((a) => a.toLowerCase() != artist.toLowerCase()).take(2);
    final lanes = await Future.wait([
      Sources.saavn.artistRadio(artist, language: lang, count: 25),
      for (final a in others) Sources.saavn.artistRadio(a, language: lang, count: 15),
      Sources.saavn.trendingIn(lang),
    ]);
    return blend(lanes, seen);
  }

  /// A mix built around one artist.
  static Future<Mix?> artistMix(String artist, {String language = 'hindi'}) async {
    final songs = await Sources.saavn.artistRadio(artist, language: language, count: 25);
    final unique = blend([songs], <String>{}, limit: 25, perArtist: 25);
    if (unique.length < 4) return null;
    return Mix(title: '$artist mix', subtitle: 'Made for you', tracks: unique);
  }

  /// Takes songs from each lane in turn, at most [perArtist] per singer and
  /// never one whose song key is already in [seen].
  static List<Track> blend(List<List<Track>> lanes, Set<String> seen, {int limit = 30, int perArtist = 2}) {
    final out = <Track>[];
    final perSinger = <String, int>{};
    final next = List.filled(lanes.length, 0);
    var progressed = true;
    while (out.length < limit && progressed) {
      progressed = false;
      for (var lane = 0; lane < lanes.length && out.length < limit; lane++) {
        while (next[lane] < lanes[lane].length) {
          final t = lanes[lane][next[lane]++];
          final singer = t.primaryArtist.toLowerCase();
          if ((perSinger[singer] ?? 0) >= perArtist || !seen.add(t.songKey)) continue;
          perSinger[singer] = (perSinger[singer] ?? 0) + 1;
          out.add(t);
          progressed = true;
          break;
        }
      }
    }
    return out;
  }

  /// YouTube / Audius songs carry a channel name, not a singer. Find the song on
  /// Saavn first and use its artist.
  static Future<String?> _realArtist(Track seed) async {
    final own = seed.primaryArtist;
    final fromSaavn = seed.source == TrackSource.saavn || seed.source == TrackSource.download;
    if (fromSaavn) return own.isEmpty ? null : own;
    try {
      final hits = await Sources.saavn.search(seed.title, limit: 3).timeout(const Duration(seconds: 12));
      if (hits.isNotEmpty) return hits.first.primaryArtist;
    } catch (_) {}
    return own.isEmpty ? null : own;
  }
}
