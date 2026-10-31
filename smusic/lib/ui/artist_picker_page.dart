import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/glass.dart';
import '../core/popular_artists.dart';
import '../models/artist.dart';
import '../services/sources/music_source.dart';
import '../state/artist_state.dart';
import '../state/settings_state.dart';
import 'widgets/art.dart';
import 'widgets/page_scaffold.dart';

/// "Choose artists you like": the first thing that teaches Home your taste.
/// Picked artists are followed, and their songs shape the mixes straight away.
class ArtistPickerPage extends StatefulWidget {
  const ArtistPickerPage({super.key});

  @override
  State<ArtistPickerPage> createState() => _ArtistPickerPageState();
}

class _ArtistPickerPageState extends State<ArtistPickerPage> {
  static const _minimum = 3;

  final _ctrl = TextEditingController();
  Timer? _debounce;

  /// Curated name -> artist found on JioSaavn (null = not found, absent = loading).
  final Map<String, Artist?> _curated = {};
  List<Artist> _results = const [];
  final Map<String, Artist> _picked = {};

  @override
  void initState() {
    super.initState();
    for (final name in popularArtistsFor(context.read<SettingsState>().languages)) {
      Sources.saavn.searchArtists(name, limit: 1).then((r) {
        if (mounted) setState(() => _curated[name] = r.isEmpty ? null : r.first);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final found = await Sources.saavn.searchArtists(text.trim(), limit: 15);
      if (mounted && _ctrl.text.trim() == text.trim()) setState(() => _results = found);
    });
  }

  void _toggle(Artist a) => setState(() => _picked.containsKey(a.id) ? _picked.remove(a.id) : _picked[a.id] = a);

  void _finish({required bool save}) {
    if (save) {
      final following = context.read<ArtistState>();
      for (final a in _picked.values) {
        if (!following.isFollowed(a)) following.toggle(a);
      }
    }
    context.read<SettingsState>().setArtistsChosen();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final searching = _ctrl.text.trim().isNotEmpty;
    final names = popularArtistsFor(context.watch<SettingsState>().languages);
    // Curated artists that exist, in order; unfinished lookups show as grey circles.
    final cells = searching
        ? _results.map<Artist?>((a) => a).toList()
        : [for (final n in names) if (!_curated.containsKey(n) || _curated[n] != null) _curated[n]];
    final ready = _picked.length >= _minimum;

    return PageScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(child: Text('Choose artists you like', style: Theme.of(context).textTheme.headlineSmall)),
                TextButton(onPressed: () => _finish(save: false), child: const Text('Skip')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pick at least $_minimum. Your mixes and suggestions start from them.', style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassPanel(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onChanged: _onSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search for an artist',
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemCount: cells.length,
              itemBuilder: (c, i) {
                final a = cells[i];
                return a == null ? const _PlaceholderCell() : _ArtistCell(artist: a, picked: _picked.containsKey(a.id), onTap: () => _toggle(a));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: ready ? () => _finish(save: true) : null,
                child: Text(ready ? 'Done  (${_picked.length} picked)' : 'Pick ${_minimum - _picked.length} more'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistCell extends StatelessWidget {
  final Artist artist;
  final bool picked;
  final VoidCallback onTap;
  const _ArtistCell({required this.artist, required this.picked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(builder: (context, box) {
      final size = box.maxWidth;
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: picked ? accent : Colors.transparent, width: 3)),
                  child: ArtImage(track: artist.art, size: size - 12, circle: true),
                ),
                if (picked)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded, size: 18, color: onAccent(accent)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(artist.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    });
  }
}

class _PlaceholderCell extends StatelessWidget {
  const _PlaceholderCell();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: AspectRatio(aspectRatio: 1, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08))))),
        const SizedBox(height: 22),
      ],
    );
  }
}
