import 'package:flutter/foundation.dart';

import '../models/artist.dart';
import '../services/storage.dart';

/// Artists the listener follows. Following one also teaches the taste profile.
class ArtistState extends ChangeNotifier {
  final Store _store;
  late List<Artist> followed;

  /// Called when an artist is followed (not unfollowed).
  void Function(Artist artist)? onFollowed;

  ArtistState(this._store) {
    followed = _store
        .getJsonList('followedArtists')
        .map((e) => Artist.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  bool isFollowed(Artist a) => followed.any((x) => x.id == a.id);

  void toggle(Artist a) {
    if (isFollowed(a)) {
      followed.removeWhere((x) => x.id == a.id);
    } else {
      followed.insert(0, a);
      onFollowed?.call(a);
    }
    _store.setJsonList('followedArtists', followed.map((e) => e.toJson()).toList());
    notifyListeners();
  }
}
