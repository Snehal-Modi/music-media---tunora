import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/glass.dart';
import '../models/artist.dart';
import '../models/track.dart';
import '../services/audio_handler.dart';
import '../services/sources/music_source.dart';
import 'widgets/art.dart';
import 'widgets/header.dart';
import 'widgets/page_scaffold.dart';
import 'widgets/track_tile.dart';

/// One album or single with its songs.
class AlbumPage extends StatefulWidget {
  final Album album;
  const AlbumPage({super.key, required this.album});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  late Future<List<Track>> _tracks;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _tracks = Sources.saavn.albumTracks(widget.album.id);

  @override
  Widget build(BuildContext context) {
    final handler = context.read<TunoraAudioHandler>();
    final album = widget.album;

    return PageScaffold(
      child: FutureBuilder<List<Track>>(
        future: _tracks,
        builder: (context, snap) {
          final songs = snap.data ?? const <Track>[];
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: PageBackBar()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    children: [
                      ArtImage(track: album.art, size: 190, radius: 26),
                      const SizedBox(height: 16),
                      Text(album.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(album.subtitle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                      if (songs.isNotEmpty) Text(plural(songs.length, 'song'), style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassIconButton(
                            icon: Icons.shuffle_rounded,
                            size: 50,
                            tooltip: 'Shuffle',
                            onPressed: songs.isEmpty ? null : () => handler.playAll(songs, shuffleMode: true),
                          ),
                          const SizedBox(width: 14),
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
              if (snap.connectionState != ConnectionState.done)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())))
              else if (songs.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyNote(
                    icon: Icons.album_rounded,
                    title: 'Could not load this album',
                    body: 'Check your internet connection and try again.',
                    action: FilledButton(onPressed: () => setState(_load), child: const Text('Retry')),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: songs.length,
                  itemBuilder: (c, i) => TrackTile(track: songs[i], queueContext: songs),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
