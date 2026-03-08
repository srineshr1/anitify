import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import '../services/lyrics_service.dart';

enum RepeatMode { none, all, one }

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final LyricsService _lyricsService = LyricsService();

  List<Song> _library = [];
  List<Song> _queue = [];
  List<Playlist> _playlists = [];
  Song? _currentSong;
  bool _isPlaying = false;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  String? _error;
  bool _permissionGranted = false;
  String? _currentLyrics;
  bool _isLoadingLyrics = false;

  // Getters
  List<Song> get library => _library;
  List<Song> get queue => _queue;
  List<Playlist> get playlists => _playlists;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get permissionGranted => _permissionGranted;
  String? get currentLyrics => _currentLyrics;
  bool get isLoadingLyrics => _isLoadingLyrics;
  AudioPlayer get player => _player;

  MusicProvider() {
    _initPlayer();
  }

  void _initPlayer() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();

      if (state.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
    });

    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  Future<void> requestPermissionsAndLoad() async {
    _isLoading = true;
    notifyListeners();

    final status = await Permission.audio.request();
    if (status.isGranted) {
      _permissionGranted = true;
      await loadLibrary();
    } else {
      // Fallback: try storage permission for older Android
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        _permissionGranted = true;
        await loadLibrary();
      } else {
        _error = 'Storage permission denied. Please grant permission to access music.';
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadLibrary() async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _library = songs
          .where((s) => (s.duration ?? 0) > 30000) // filter < 30s clips
          .map((s) => Song.fromSongModel(s))
          .toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load music: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? fromList}) async {
    _currentSong = song;
    if (fromList != null) {
      _queue = List.from(fromList);
    }
    notifyListeners();

    // Fetch lyrics in background
    _fetchLyrics(song.artist, song.title);

    try {
      if (song.uri != null) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
        await _player.play();
      }
    } catch (e) {
      _error = 'Could not play this file.';
      notifyListeners();
    }
  }

  Future<void> _fetchLyrics(String artist, String title) async {
    _currentLyrics = null;
    _isLoadingLyrics = true;
    notifyListeners();

    final lyrics = await _lyricsService.fetchLyrics(artist, title);
    _currentLyrics = lyrics;
    _isLoadingLyrics = false;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty || _currentSong == null) return;
    final idx = _queue.indexWhere((s) => s.id == _currentSong!.id);
    if (idx == -1 || idx >= _queue.length - 1) return;
    await playSong(_queue[idx + 1], fromList: _queue);
  }

  Future<void> skipPrev() async {
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_queue.isEmpty || _currentSong == null) return;
    final idx = _queue.indexWhere((s) => s.id == _currentSong!.id);
    if (idx <= 0) return;
    await playSong(_queue[idx - 1], fromList: _queue);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  void _onSongCompleted() {
    if (_repeatMode == RepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
    } else {
      skipNext();
    }
  }

  // Playlist management
  void createPlaylist(String name) {
    _playlists.add(Playlist.create(name: name));
    notifyListeners();
  }

  void addToPlaylist(int playlistId, Song song) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    if (!pl.songs.any((s) => s.id == song.id)) {
      pl.songs.add(song);
      notifyListeners();
    }
  }

  void removeFromPlaylist(int playlistId, int songId) {
    final pl = _playlists.firstWhere((p) => p.id == playlistId);
    pl.songs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }

  void deletePlaylist(int playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  List<Song> get recentlyAdded => _library.take(10).toList();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
