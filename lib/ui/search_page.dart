import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/glass.dart';
import '../models/artist.dart';
import '../models/track.dart';
import '../services/audio_handler.dart';
import '../services/sources/music_source.dart';
import '../state/library_state.dart';
import '../state/settings_state.dart';
import 'podcast_page.dart';
import 'widgets/artist_widgets.dart';
import 'widgets/cards.dart';
import 'widgets/header.dart';
import 'widgets/track_tile.dart';

/// "Browse all" tile: label, the search it runs (null opens podcasts) and its colour.
class _Browse {
  final String label;
  final String? query;
  final Color color;
  const _Browse(this.label, this.query, this.color);
}

const _browseTiles = [
  _Browse('Hindi', 'hindi hit songs', Color(0xFFE8115B)),
  _Browse('English', 'english pop hits', Color(0xFF1E3264)),
  _Browse('Punjabi', 'punjabi hit songs', Color(0xFFE13300)),
  _Browse('Gujarati', 'gujarati songs', Color(0xFF8D67AB)),
  _Browse('Romantic', 'romantic songs', Color(0xFFB02897)),
  _Browse('Party', 'party songs', Color(0xFF477D95)),
  _Browse('Workout', 'workout songs', Color(0xFF148A08)),
  _Browse('Sad', 'sad songs', Color(0xFF503750)),
  _Browse('Chill', 'chill lofi songs', Color(0xFF2D46B9)),
  _Browse('Devotional', 'bhajan devotional', Color(0xFFBA5D07)),
  _Browse('Retro', 'old hindi classics', Color(0xFF7D4B32)),
  _Browse('Hip-hop', 'hindi rap hip hop', Color(0xFF608108)),
  _Browse('Tamil', 'tamil hit songs', Color(0xFF0D73EC)),
  _Browse('Telugu', 'telugu hit songs', Color(0xFFAF2896)),
  _Browse('Podcasts', null, Color(0xFF006450)),
  _Browse('Stories', null, Color(0xFF5179A1)),
];

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _filters = [TrackSource.saavn, TrackSource.youtube, TrackSource.audius, TrackSource.radio];

  final _ctrl = TextEditingController();
  Timer? _debounce;
  bool _busy = false;
  String _lastQuery = '';
  Map<TrackSource, List<Track>> _songs = {};
  List<Artist> _artists = const [];
  List<Album> _albums = const [];
  List<Track> _local = const [];
  TrackSource? _filter; // null = all

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    if (!context.read<SettingsState>().online) {
      setState(() {
        _local = context.read<LibraryState>().search(v);
        _lastQuery = v;
      });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 650), () => _runOnline(v));
  }

  void _submit(String v) {
    _debounce?.cancel();
    if (context.read<SettingsState>().online) {
      _runOnline(v);
    } else {
      _onChanged(v);
    }
  }

  Future<void> _runOnline(String q) async {
    final s = q.trim();
    if (s.isEmpty) {
      setState(() {
        _songs = {};
        _artists = const [];
        _albums = const [];
        _lastQuery = '';
      });
      return;
    }
    setState(() {
      _busy = true;
      _lastQuery = s;
    });
    // All three start together; songs, artists and albums fill in as one result.
    final songsF = Sources.searchAll(s, only: _filter == null ? null : {_filter!});
    final artistsF = Sources.saavn.searchArtists(s, limit: 8);
    final albumsF = Sources.saavn.searchAlbums(s, limit: 8);
    final songs = await songsF;
    final artists = await artistsF;
    final albums = await albumsF;
    if (!mounted || _lastQuery != s) return;
    context.read<SettingsState>().addSearch(s);
    setState(() {
      _songs = songs;
      _artists = artists;
      _albums = albums;
      _busy = false;
    });
  }

  void _setFilter(TrackSource? f) {
    setState(() => _filter = f);
    if (_lastQuery.isNotEmpty) _runOnline(_lastQuery);
  }

  void _searchFor(String text) {
    _ctrl.text = text;
    _submit(text);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    final online = settings.online;

    return Column(
      children: [
        const PageHeader(title: 'Search'),
        _searchBox(online),
        if (online) _sourceChips(),
        Expanded(
          child: _lastQuery.trim().isEmpty
              ? _browse(settings)
              : online
                  ? _onlineResults()
                  : _localResults(),
        ),
      ],
    );
  }

  Widget _searchBox(bool online) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassPanel(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: _onChanged,
                onSubmitted: _submit,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: online ? 'What do you want to listen to?' : 'Search your songs',
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_busy)
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            else if (_ctrl.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _ctrl.clear();
                  _onChanged('');
                  _runOnline('');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _sourceChips() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        children: [
          GlassChip(label: 'All', selected: _filter == null, onTap: () => _setFilter(null)),
          const SizedBox(width: 8),
          for (final f in _filters) ...[
            GlassChip(label: sourceLabel(f), icon: sourceIcon(f), selected: _filter == f, onTap: () => _setFilter(f)),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  /// Nothing typed yet: recent searches, then the colourful "Browse all" grid.
  Widget _browse(SettingsState settings) {
    if (!settings.online) {
      return const EmptyNote(icon: Icons.search_rounded, title: 'Find songs on this phone', body: 'Type a song, artist or album name.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        if (settings.searchHistory.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text('Recent searches', style: Theme.of(context).textTheme.titleMedium)),
              TextButton(onPressed: settings.clearSearchHistory, child: const Text('Clear')),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final h in settings.searchHistory) GlassChip(label: h, icon: Icons.history_rounded, onTap: () => _searchFor(h))],
          ),
          const SizedBox(height: 12),
        ],
        Padding(padding: const EdgeInsets.only(top: 8, bottom: 10), child: Text('Browse all', style: Theme.of(context).textTheme.titleLarge)),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [for (final b in _browseTiles) _browseTile(b)],
        ),
      ],
    );
  }

  Widget _browseTile(_Browse b) {
    return GestureDetector(
      onTap: () => b.query == null ? Navigator.push(context, MaterialPageRoute(builder: (_) => const PodcastBrowsePage())) : _searchFor(b.query!),
      child: Container(
        padding: const EdgeInsets.all(12),
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(color: b.color, borderRadius: BorderRadius.circular(12)),
        child: Text(b.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _localResults() {
    if (_local.isEmpty) {
      return const EmptyNote(icon: Icons.search_off_rounded, title: 'No matches on this phone', body: 'Try Online mode to stream it instead.');
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: _local.length,
      itemBuilder: (c, i) => TrackTile(track: _local[i], queueContext: _local),
    );
  }

  Widget _onlineResults() {
    final handler = context.read<TunoraAudioHandler>();
    final showPeople = _filter == null || _filter == TrackSource.saavn;
    final artists = showPeople ? _artists : const <Artist>[];
    final albums = showPeople ? _albums : const <Album>[];
    final noSongs = _songs.values.every((l) => l.isEmpty);

    if (_busy && noSongs && artists.isEmpty) return const Center(child: CircularProgressIndicator());
    if (noSongs && artists.isEmpty && albums.isEmpty) {
      return const EmptyNote(
        icon: Icons.cloud_off_rounded,
        title: 'Nothing found',
        body: 'Try another spelling, or pick a different source chip. Some sources are blocked on some networks.',
      );
    }

    final sections = <Widget>[];
    var peopleAdded = false;
    List<Widget> people() {
      peopleAdded = true;
      return [
        if (artists.isNotEmpty) ...[
          const SectionTitle('Artists'),
          HorizontalRow(height: 176, children: artists.map((a) => ArtistCard(artist: a)).toList()),
        ],
        if (albums.isNotEmpty) ...[
          const SectionTitle('Albums'),
          HorizontalRow(height: 200, children: albums.map((a) => AlbumCard(album: a)).toList()),
        ],
      ];
    }

    for (final s in _filters) {
      final list = _songs[s] ?? const <Track>[];
      if (list.isEmpty) continue;
      sections.add(SectionTitle(sourceLabel(s), action: 'Play all', onAction: () => handler.playAll(list)));
      // Tapping a song plays just that song; similar songs follow on their own.
      sections.addAll(list.map((t) => TrackTile(track: t)));
      if (s == TrackSource.saavn) sections.addAll(people());
    }
    if (!peopleAdded) sections.addAll(people());
    return ListView(padding: const EdgeInsets.only(bottom: 120), children: sections);
  }
}
