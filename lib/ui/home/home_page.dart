import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/net_state.dart';
import '../../state/settings_state.dart';
import 'local_home.dart';
import 'offline_home.dart';
import 'online_home.dart';

/// The Home tab. Local mode shows the phone's songs; Online mode shows streaming
/// shelves, or the offline view when there is no internet.
class HomePage extends StatelessWidget {
  final void Function(int tab, {int? libraryTab}) goToTab;
  const HomePage({super.key, required this.goToTab});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<SettingsState>().online;
    final connected = context.watch<NetState>().online;
    if (!online) return LocalHome(goToTab: goToTab);
    return connected ? OnlineHome(goToTab: goToTab) : OfflineHome(goToTab: goToTab);
  }
}
