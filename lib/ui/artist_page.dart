import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/glass.dart';
import '../models/artist.dart';
import '../models/track.dart';
import '../services/audio_handler.dart';
import '../services/sources/music_source.dart';
import '../state/artist_state.dart';
import 'widgets/art.dart';
import 'widgets/artist_widgets.dart';
import 'widgets/cards.dart';
import 'widgets/header.dart';
import 'widgets/page_scaffold.dart';
import 'widgets/sheets.dart';
import 'widgets/track_tile.dart';

/// Finds an artist by name (from a song) and opens their page.
Future<void> openArtistByName(BuildContext context, String name) async {
  final found = await Sources.saavn.searchArtists(name, limit: 3);
  if (!context.mounted) return;
  if (found.isEmpty) {
    snack(context, 'Could not find $name');
    return;
  }
  final best = found.firstWhere((a) => a.name.toLowerCase() == name.toLowerCase(), orElse: () => found.first);
  Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistPage(artist: best)));
}

/// One artist: photo, follow, popular songs and albums.
class ArtistPage extends StatefulWidget {
  final Artist artist;
  const ArtistPage({super.key, required this.artist});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late Future<ArtistPageData?> _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _data = Sources.saavn.artistPage(widget.artist.id);

  @override
  Widget build(BuildContext context) {
    final handler = context.read<TunoraAudioHandler>();
    final followed = context.watch<ArtistState>();

    return PageScaffold(
      child: FutureBuilder<ArtistPageData?>(
        future: _data,
        builder: (context, snap) {
          final data = snap.data;
          final artist = data?.artist ?? widget.artist;
          final songs = data?.songs ?? const <Track>[];
          final loading = snap.connectionState != ConnectionState.done;

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: PageBackBar()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    children: [
                      ArtImage(track: artist.art, size: 170, circle: true),
                      const SizedBox(height: 14),
                      Text(artist.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall),
                      if (artist.followers != null)
                        Text('${compactCount(artist.followers!)} fans', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => followed.toggle(artist),
                            icon: Icon(followed.isFollowed(artist) ? Icons.check_rounded : Icons.add_rounded),
                            label: Text(followed.isFollowed(artist) ? 'Following' : 'Follow'),
                          ),
                          const SizedBox(width: 12),
                          GlassIconButton(
                            icon: Icons.shuffle_rounded,
                            size: 50,
                            tooltip: 'Shuffle',
                            onPressed: songs.isEmpty ? null : () => handler.playAll(songs, shuffleMode: true),
                          ),
                          const SizedBox(width: 12),
                          GlassIconButton(
                            icon: Icons.play_arrow_rounded,
                            size: 64,
                            iconSize: 34,
                            filled: true,
                            tooltip: 'Play',
                            onPressed: songs.isEmpty ? null : () => handler.playAll(songs),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (loading)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())))
              else if (data == null)
                SliverToBoxAdapter(
                  child: EmptyNote(
                    icon: Icons.person_off_rounded,
                    title: 'Could not load this artist',
                    body: 'Check your internet connection and try again.',
                    action: FilledButton(onPressed: () => setState(_load), child: const Text('Retry')),
                  ),
                )
              else ...[
                const SliverToBoxAdapter(child: SectionTitle('Popular')),
                SliverList.builder(
                  itemCount: songs.length,
                  itemBuilder: (c, i) => TrackTile(track: songs[i], queueContext: songs),
                ),
                if (data.albums.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SectionTitle('Albums')),
                  SliverToBoxAdapter(
                    child: HorizontalRow(height: 200, children: data.albums.map((a) => AlbumCard(album: a)).toList()),
                  ),
                ],
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
