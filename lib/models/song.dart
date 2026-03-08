import 'package:on_audio_query/on_audio_query.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String? uri;
  final int duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.uri,
    required this.duration,
  });

  String get durationFormatted {
    final durationDuration = Duration(milliseconds: duration);
    final minutes = durationDuration.inMinutes;
    final seconds = durationDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory Song.fromSongModel(SongModel model) {
    return Song(
      id: model.id,
      title: model.title,
      artist: model.artist ?? 'Unknown Artist',
      uri: model.uri,
      duration: model.duration ?? 0,
    );
  }
}

class Playlist {
  static int _idCounter = 0;
  final int id;
  final String name;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.songs,
  });

  String get trackCount => '${songs.length} tracks';

  factory Playlist.create({required String name}) {
    _idCounter++;
    return Playlist(
      id: _idCounter,
      name: name,
      songs: [],
    );
  }
}
