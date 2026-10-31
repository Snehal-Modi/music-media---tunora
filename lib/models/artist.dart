import 'track.dart';

/// A singer or band (JioSaavn).
class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final int? followers;

  const Artist({required this.id, required this.name, this.imageUrl, this.followers});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'imageUrl': imageUrl, 'followers': followers};

  factory Artist.fromJson(Map<String, dynamic> j) => Artist(
        id: j['id'].toString(),
        name: (j['name'] ?? '') as String,
        imageUrl: j['imageUrl'] as String?,
        followers: (j['followers'] as num?)?.toInt(),
      );

  /// A stand-in track so the shared [ArtImage] widget can draw the photo.
  Track get art => Track(id: 'artist:$id', title: name, artist: name, album: '', source: TrackSource.saavn, artUrl: imageUrl);

  @override
  bool operator ==(Object other) => other is Artist && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// An album or single, without its songs (they load when it is opened).
class Album {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;

  const Album({required this.id, required this.title, this.subtitle = '', this.imageUrl});

  Track get art => Track(id: 'album:$id', title: title, artist: subtitle, album: title, source: TrackSource.saavn, artUrl: imageUrl);
}

/// Everything shown on an artist's page.
class ArtistPageData {
  final Artist artist;
  final List<Track> songs;
  final List<Album> albums;
  const ArtistPageData({required this.artist, required this.songs, required this.albums});
}
