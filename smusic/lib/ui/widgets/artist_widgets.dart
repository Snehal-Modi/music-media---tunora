import 'package:flutter/material.dart';

import '../../models/artist.dart';
import '../album_page.dart';
import '../artist_page.dart';
import 'art.dart';

/// Round artist photo with the name underneath. Opens the artist page.
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final double size;
  const ArtistCard({super.key, required this.artist, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistPage(artist: artist))),
        child: Column(
          children: [
            ArtImage(track: artist.art, size: size, circle: true),
            const SizedBox(height: 8),
            Text(artist.name,
                maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('Artist', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Square album cover with title and year. Opens the album page.
class AlbumCard extends StatelessWidget {
  final Album album;
  final double size;
  const AlbumCard({super.key, required this.album, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumPage(album: album))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArtImage(track: album.art, size: size, radius: 16),
            const SizedBox(height: 8),
            Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            Text(album.subtitle,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
