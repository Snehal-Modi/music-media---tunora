import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/glass.dart';
import '../../models/track.dart';
import '../../services/audio_handler.dart';
import '../../services/download_service.dart';
import '../../state/collections_state.dart';
import '../../state/library_state.dart';
import '../../state/net_state.dart';
import '../collection_page.dart';
import '../widgets/cards.dart';
import '../widgets/header.dart';
import 'home_widgets.dart';

/// Home when there is no internet: everything saved on the phone, front and centre.
class OfflineHome extends StatelessWidget {
  final void Function(int tab, {int? libraryTab}) goToTab;
  const OfflineHome({super.key, required this.goToTab});

  @override
  Widget build(BuildContext context) {
    final dl = context.watch<DownloadService>();
    final col = context.watch<CollectionsState>();
    final lib = context.watch<LibraryState>();
    final handler = context.read<TunoraAudioHandler>();

    bool playable(Track t) => t.isLocal || dl.isDownloaded(t);
    final downloads = dl.downloads;
    final recent = col.recent.where(playable).take(12).toList();
    final liked = col.liked.where(playable).toList();
    final phone = lib.recentlyAdded;
    final nothing = downloads.isEmpty && liked.isEmpty && phone.isEmpty;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        PageHeader(title: greeting(), subtitle: 'You are offline'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassPanel(
            radius: 18,
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
            child: Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('No internet. Playing what is saved on this phone.', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13.5)),
                ),
                TextButton(onPressed: context.read<NetState>().check, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        QuickRow(tiles: [
          QuickTile(
            icon: Icons.shuffle_rounded,
            label: 'Shuffle offline',
            filled: true,
            onTap: () {
              final all = <Track>[...downloads, ...lib.songs];
              if (all.isNotEmpty) handler.playAll(all, shuffleMode: true);
            },
          ),
          QuickTile(
            icon: Icons.favorite_rounded,
            label: 'Liked (${liked.length})',
            onTap: () => openPage(context, const CollectionPage(kind: CollectionKind.liked)),
          ),
          QuickTile(
            icon: Icons.download_done_rounded,
            label: 'Downloads',
            onTap: () => openPage(context, const CollectionPage(kind: CollectionKind.downloads)),
          ),
        ]),
        if (nothing)
          const EmptyNote(
            icon: Icons.download_for_offline_outlined,
            title: 'Nothing saved for offline yet',
            body: 'When you are online, long-press any song and choose Download for offline. It will show up here automatically.',
          )
        else ...[
          TrackShelf('Downloaded', downloads.take(20).toList()),
          if (recent.isNotEmpty) ...[
            const SectionTitle('Jump back in'),
            HorizontalRow(children: recent.map((t) => TrackCard(track: t, tracks: recent)).toList()),
          ],
          TrackShelf('Liked and saved', liked.take(20).toList()),
          if (phone.isNotEmpty) ...[
            SectionTitle('On this phone', action: 'Songs', onAction: () => goToTab(2, libraryTab: 0)),
            HorizontalRow(children: phone.map((t) => TrackCard(track: t, tracks: phone)).toList()),
          ],
        ],
      ],
    );
  }
}
