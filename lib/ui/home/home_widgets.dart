import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/glass.dart';
import '../../models/podcast.dart';
import '../../models/track.dart';
import '../../services/audio_handler.dart';
import '../../services/reco_service.dart';
import '../../state/collections_state.dart';
import '../../state/settings_state.dart';
import '../artist_picker_page.dart';
import '../collection_page.dart';
import '../podcast_page.dart';
import '../widgets/art.dart';
import '../widgets/cards.dart';
import '../widgets/header.dart';

void openPage(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

/// Big square shortcut used in the quick row of the Local and Offline homes.
class QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const QuickTile({super.key, required this.icon, required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final fg = filled ? onAccent(accent) : Colors.white;
    return Expanded(
      child: GlassPanel(
        radius: 18,
        onTap: onTap,
        tint: filled ? accent : null,
        opacity: filled ? 0.8 : null,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: fg),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}

/// The three-tile row: shuffle / liked / downloads style shortcuts.
class QuickRow extends StatelessWidget {
  final List<QuickTile> tiles;
  const QuickRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[if (i > 0) const SizedBox(width: 10), tiles[i]],
        ],
      ),
    );
  }
}

/// One entry of the two-column "quick picks" grid at the top of Online Home.
class QuickPick {
  final String title;
  final Track? art;
  final IconData icon;
  final VoidCallback onTap;
  const QuickPick({required this.title, required this.onTap, this.art, this.icon = Icons.music_note_rounded});
}

/// Spotify-style grid of compact shortcuts: cover on the left, title on the right.
class QuickPicks extends StatelessWidget {
  final List<QuickPick> picks;
  const QuickPicks({super.key, required this.picks});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    Widget cell(QuickPick p) => GlassPanel(
          radius: 12,
          frosted: false,
          onTap: p.onTap,
          height: 56,
          child: Row(
            children: [
              if (p.art != null)
                ArtImage(track: p.art, size: 56, radius: 0)
              else
                Container(width: 56, height: 56, color: accent.withOpacity(0.35), child: Icon(p.icon)),
              const SizedBox(width: 10),
              Expanded(child: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
              const SizedBox(width: 8),
            ],
          ),
        );

    final rows = <Widget>[];
    for (var i = 0; i < picks.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: cell(picks[i])),
            const SizedBox(width: 8),
            Expanded(child: i + 1 < picks.length ? cell(picks[i + 1]) : const SizedBox.shrink()),
          ],
        ),
      ));
    }
    return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Column(children: rows));
  }
}

enum HomeFilter { all, music, podcasts }

/// "All / Music / Podcasts" chips under the greeting.
class HomeFilterBar extends StatelessWidget {
  final HomeFilter value;
  final ValueChanged<HomeFilter> onChanged;
  const HomeFilterBar({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = {HomeFilter.all: 'All', HomeFilter.music: 'Music', HomeFilter.podcasts: 'Podcasts and stories'};
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in HomeFilter.values) ...[
              GlassChip(label: labels[f]!, selected: value == f, onTap: () => onChanged(f)),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Jump back in": the last songs played.
class RecentRow extends StatelessWidget {
  const RecentRow({super.key});

  @override
  Widget build(BuildContext context) {
    final recent = context.watch<CollectionsState>().recent;
    if (recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Jump back in', action: 'See all', onAction: () => openPage(context, const CollectionPage(kind: CollectionKind.recent))),
        HorizontalRow(children: recent.take(12).map((t) => TrackCard(track: t, tracks: recent)).toList()),
      ],
    );
  }
}

/// A titled row of songs with a "Play all" action. Empty list shows nothing.
class TrackShelf extends StatelessWidget {
  final String title;
  final List<Track> tracks;
  const TrackShelf(this.title, this.tracks, {super.key});

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title, action: 'Play all', onAction: () => context.read<TunoraAudioHandler>().playAll(tracks)),
        HorizontalRow(children: tracks.map((t) => TrackCard(track: t, tracks: tracks)).toList()),
      ],
    );
  }
}

/// A titled row of podcast shows.
class ShowShelf extends StatelessWidget {
  final String title;
  final List<Podcast> shows;
  final bool browse;
  const ShowShelf(this.title, this.shows, {super.key, this.browse = true});

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title, action: browse ? 'Browse' : null, onAction: browse ? () => openPage(context, const PodcastBrowsePage()) : null),
        HorizontalRow(children: shows.map((p) => PodcastCard(podcast: p)).toList()),
      ],
    );
  }
}

/// A personal mix: tap to play it.
class MixCard extends StatelessWidget {
  final Mix mix;
  final double size;
  const MixCard({super.key, required this.mix, this.size = 148});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.read<TunoraAudioHandler>().playAll(mix.tracks),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Stack(
                children: [
                  ArtImage(track: mix.tracks.first, size: size, radius: 18),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                      child: Icon(Icons.play_arrow_rounded, color: onAccent(accent)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(mix.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            Text(mix.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// First-run card: which languages does the listener want music in?
class LanguagePrompt extends StatefulWidget {
  const LanguagePrompt({super.key});

  @override
  State<LanguagePrompt> createState() => _LanguagePromptState();
}

class _LanguagePromptState extends State<LanguagePrompt> {
  late final List<String> _picked = List.of(context.read<SettingsState>().languages);

  void _toggle(String l) => setState(() {
        if (!_picked.remove(l)) _picked.add(l);
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GlassPanel(
        radius: 22,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What do you listen to?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Pick your languages. Home and the suggestions follow them. The first one you pick comes first.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final l in kLanguages) GlassChip(label: langLabel(l), selected: _picked.contains(l), onTap: () => _toggle(l))],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _picked.isEmpty ? null : () => context.read<SettingsState>().setLanguages(_picked),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card that opens the "choose artists you like" screen until it has been done once.
class ArtistPrompt extends StatelessWidget {
  const ArtistPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GlassPanel(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            const Icon(Icons.mic_external_on_rounded, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose artists you like', style: Theme.of(context).textTheme.titleMedium),
                  Text('Takes ten seconds and sets up your mixes.', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            FilledButton(onPressed: () => openPage(context, const ArtistPickerPage()), child: const Text('Choose')),
          ],
        ),
      ),
    );
  }
}
