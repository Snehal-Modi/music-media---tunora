import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/glass.dart';
import '../../state/mood_state.dart';
import '../mini_player.dart';

/// Frame for pages opened on top of the main tabs (artist, album, podcast):
/// the glass backdrop, a safe area and the mini player at the bottom.
class PageScaffold extends StatelessWidget {
  final Widget child;
  const PageScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mood = context.watch<MoodState>();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GlassBackdrop(accent: accent, mood: mood.color)),
          SafeArea(
            bottom: false,
            child: Column(children: [Expanded(child: child), const MiniPlayer()]),
          ),
        ],
      ),
    );
  }
}

/// Round back button row shown at the top of those pages.
class PageBackBar extends StatelessWidget {
  final String? title;
  const PageBackBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.maybePop(context)),
          if (title != null) ...[const SizedBox(width: 12), Text(title!, style: Theme.of(context).textTheme.titleLarge)],
        ],
      ),
    );
  }
}
