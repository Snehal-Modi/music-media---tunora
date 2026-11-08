import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../services/audio_handler.dart';
import '../../state/collections_state.dart';
import '../../state/library_state.dart';
import '../collection_page.dart';
import '../widgets/cards.dart';
import '../widgets/header.dart';
import 'home_widgets.dart';

/// Home in Local mode: the songs on this phone.
class LocalHome extends StatelessWidget {
  final void Function(int tab, {int? libraryTab}) goToTab;
  const LocalHome({super.key, required this.goToTab});

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryState>();
    final col = context.watch<CollectionsState>();
    final handler = context.read<TunoraAudioHandler>();
    final recent = lib.recentlyAdded;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => lib.load(force: true),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          PageHeader(title: greeting(), subtitle: '${plural(lib.songs.length, 'song')} on this phone'),
          QuickRow(tiles: [
            QuickTile(
              icon: Icons.shuffle_rounded,
              label: 'Shuffle all',
              filled: true,
              onTap: () => lib.songs.isEmpty ? null : handler.playAll(lib.songs, shuffleMode: true),
            ),
            QuickTile(
              icon: Icons.favorite_rounded,
              label: 'Liked (${col.liked.length})',
              onTap: () => openPage(context, const CollectionPage(kind: CollectionKind.liked)),
            ),
            QuickTile(
              icon: Icons.download_done_rounded,
              label: 'Downloads',
              onTap: () => openPage(context, const CollectionPage(kind: CollectionKind.downloads)),
            ),
          ]),
          if (lib.loading && lib.songs.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
          else if (lib.denied)
            EmptyNote(
              icon: Icons.lock_outline_rounded,
              title: 'Tunora needs permission to read your music',
              body: lib.permanentlyDenied
                  ? 'Permission was turned off. Open the app settings and allow "Music and audio".'
                  : 'Allow access to audio files so your downloaded songs appear here.',
              action: Wrap(spacing: 8, alignment: WrapAlignment.center, children: [
                FilledButton(onPressed: () => lib.load(force: true), child: const Text('Allow access')),
                if (lib.permanentlyDenied) TextButton(onPressed: openAppSettings, child: const Text('Open settings')),
              ]),
            )
          else if (lib.songs.isEmpty && lib.loaded)
            const EmptyNote(
              icon: Icons.library_music_outlined,
              title: 'No songs found on this phone',
              body: 'Copy MP3 / M4A / FLAC files anywhere on the phone, then pull down to refresh. Or switch to Online.',
            )
          else ...[
            const RecentRow(),
            if (recent.isNotEmpty) ...[
              SectionTitle('Recently added', action: 'Songs', onAction: () => goToTab(2, libraryTab: 0)),
              HorizontalRow(children: recent.map((t) => TrackCard(track: t, tracks: recent)).toList()),
            ],
            if (lib.albums.isNotEmpty) ...[
              SectionTitle('Albums', action: 'See all', onAction: () => goToTab(2, libraryTab: 1)),
              HorizontalRow(children: lib.albums.take(15).map((g) => GroupCard(group: g, kind: CollectionKind.album)).toList()),
            ],
            if (lib.artists.isNotEmpty) ...[
              SectionTitle('Artists', action: 'See all', onAction: () => goToTab(2, libraryTab: 2)),
              HorizontalRow(
                height: 196,
                children: lib.artists.take(15).map((g) => GroupCard(group: g, kind: CollectionKind.artist, size: 130)).toList(),
              ),
            ],
            if (lib.folders.isNotEmpty) ...[
              SectionTitle('Folders', action: 'See all', onAction: () => goToTab(2, libraryTab: 3)),
              HorizontalRow(children: lib.folders.take(15).map((g) => GroupCard(group: g, kind: CollectionKind.folder)).toList()),
            ],
          ],
        ],
      ),
    );
  }
}
