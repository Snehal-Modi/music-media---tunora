import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/artist_state.dart';
import '../state/podcast_state.dart';
import 'artist_picker_page.dart';
import 'podcast_page.dart';
import 'widgets/artist_widgets.dart';
import 'widgets/header.dart';

/// Library tab: the artists and podcasts the listener follows.
class FollowingTab extends StatelessWidget {
  const FollowingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final artists = context.watch<ArtistState>().followed;
    final shows = context.watch<PodcastState>().followed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        Row(
          children: [
            const Expanded(child: Text('Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtistPickerPage())),
              child: const Text('Add'),
            ),
          ],
        ),
        if (artists.isEmpty)
          const EmptyNote(icon: Icons.person_add_alt_rounded, title: 'No artists yet', body: 'Follow artists and your mixes will be built around them.')
        else
          Wrap(spacing: 14, runSpacing: 16, children: [for (final a in artists) ArtistCard(artist: a, size: 100)]),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Text('Podcasts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PodcastBrowsePage())),
              child: const Text('Browse'),
            ),
          ],
        ),
        if (shows.isEmpty)
          const EmptyNote(icon: Icons.podcasts_rounded, title: 'No podcasts yet', body: 'Follow a show and it appears here.')
        else
          Wrap(spacing: 14, runSpacing: 16, children: [for (final p in shows) PodcastCard(podcast: p, size: 110)]),
      ],
    );
  }
}
