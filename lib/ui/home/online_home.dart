import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../services/audio_handler.dart';
import '../../state/collections_state.dart';
import '../../state/online_state.dart';
import '../../state/podcast_state.dart';
import '../../state/settings_state.dart';
import '../collection_page.dart';
import '../widgets/cards.dart';
import '../widgets/header.dart';
import 'home_widgets.dart';

/// Home in Online mode, laid out like Spotify: filter chips, a grid of quick
/// picks, then shelves made from the listener's taste and languages.
class OnlineHome extends StatefulWidget {
  final void Function(int tab, {int? libraryTab}) goToTab;
  const OnlineHome({super.key, required this.goToTab});

  @override
  State<OnlineHome> createState() => _OnlineHomeState();
}

class _OnlineHomeState extends State<OnlineHome> {
  HomeFilter _filter = HomeFilter.all;
  late String _langKey;

  @override
  void initState() {
    super.initState();
    _langKey = context.read<SettingsState>().languages.join(',');
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<OnlineState>().load());
  }

  /// Six shortcuts: liked songs, downloads, then the latest different songs played.
  List<QuickPick> _picks(CollectionsState col) {
    final handler = context.read<TunoraAudioHandler>();
    final picks = <QuickPick>[
      QuickPick(title: 'Liked songs', icon: Icons.favorite_rounded, onTap: () => openPage(context, const CollectionPage(kind: CollectionKind.liked))),
      QuickPick(title: 'Downloads', icon: Icons.download_done_rounded, onTap: () => openPage(context, const CollectionPage(kind: CollectionKind.downloads))),
    ];
    final seen = <String>{};
    for (final t in col.recent) {
      if (picks.length >= 6) break;
      if (t.isLive || !seen.add(t.songKey)) continue;
      // One song: the rest of the queue is filled with similar songs.
      picks.add(QuickPick(title: t.title, art: t, onTap: () => handler.playAll([t])));
    }
    return picks;
  }

  @override
  Widget build(BuildContext context) {
    final on = context.watch<OnlineState>();
    final settings = context.watch<SettingsState>();
    final col = context.watch<CollectionsState>();
    final followedShows = context.watch<PodcastState>().followed;

    // Languages changed in Settings or on the first-run card: refresh the rows.
    final key = settings.languages.join(',');
    if (key != _langKey) {
      _langKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<OnlineState>().load();
      });
    }

    final music = _filter != HomeFilter.podcasts;
    final shows = _filter != HomeFilter.music;
    final langs = settings.languages.take(4).toList();

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => on.load(force: true),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          PageHeader(
            title: greeting(),
            subtitle: settings.languages.map(langLabel).take(3).join(', '),
            actions: [IconButton(icon: const Icon(Icons.search_rounded), tooltip: 'Search', onPressed: () => widget.goToTab(1))],
          ),
          HomeFilterBar(value: _filter, onChanged: (f) => setState(() => _filter = f)),
          if (!settings.languagesChosen)
            const LanguagePrompt()
          else if (!settings.artistsChosen)
            const ArtistPrompt(),
          if (music) ...[QuickPicks(picks: _picks(col)), const RecentRow()],
          if (on.loading && on.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
          else if (on.isEmpty && on.loaded)
            EmptyNote(
              icon: Icons.cloud_off_rounded,
              title: 'Could not reach any music source',
              body: 'Pull down to retry. Search still works when a source is up.',
              action: FilledButton(onPressed: () => on.load(force: true), child: const Text('Retry')),
            )
          else ...[
            if (music) ...[
              if (on.mixes.isNotEmpty) ...[
                const SectionTitle('Made for you'),
                HorizontalRow(children: on.mixes.map((m) => MixCard(mix: m)).toList()),
              ],
              TrackShelf('Because you listened to ${on.becauseArtist}', on.becauseTracks),
              for (final l in langs) ...[
                TrackShelf('Trending in ${langLabel(l)}', on.languageRows[l] ?? const []),
                TrackShelf('Top 50 ${langLabel(l)}', on.languageCharts[l] ?? const []),
              ],
              TrackShelf('Fresh on YouTube', on.youtubeNew),
              TrackShelf('Trending on Audius', on.audiusTrending),
              TrackShelf('Radio stations', on.radioTop),
            ],
            if (shows) ...[
              ShowShelf('Your podcasts', followedShows, browse: false),
              ShowShelf('Podcasts for you', on.topPodcasts),
              ShowShelf('Stories and kahani', on.storyShows),
            ],
          ],
        ],
      ),
    );
  }
}
