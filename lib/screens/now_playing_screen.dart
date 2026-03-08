import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});
  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _showLyrics = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Selector<MusicProvider, int?>(
            selector: (_, m) => m.currentSong?.id,
            builder: (context, songId, _) {
              if (songId == null) return Container(color: AppTheme.bg);
              return _GlassBackground(songId: songId);
            },
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(showLyrics: _showLyrics, onToggleLyrics: () => setState(() => _showLyrics = !_showLyrics)),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _showLyrics
                        ? _LyricsPanel(key: const ValueKey('lyrics'))
                        : _PlayerPanel(key: const ValueKey('player'), showLyrics: _showLyrics),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackground extends StatelessWidget {
  final int songId;
  const _GlassBackground({required this.songId});
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppTheme.bg),
          Positioned.fill(
            child: QueryArtworkWidget(
              id: songId, type: ArtworkType.AUDIO, artworkFit: BoxFit.cover,
              quality: 100, size: 800, artworkQuality: FilterQuality.high,
              nullArtworkWidget: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppTheme.accent.withOpacity(0.08), AppTheme.pink.withOpacity(0.05)]),
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppTheme.bg.withOpacity(0.60), AppTheme.bg.withOpacity(0.75), AppTheme.bg.withOpacity(0.92)]),
              ),
            ),
          ),
          Positioned(top: -80, left: -60, child: Container(width: 300, height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppTheme.accent.withOpacity(0.08), Colors.transparent])))),
          Positioned(bottom: 60, right: -80, child: Container(width: 260, height: 260,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppTheme.pink.withOpacity(0.06), Colors.transparent])))),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showLyrics;
  final VoidCallback onToggleLyrics;
  const _TopBar({required this.showLyrics, required this.onToggleLyrics});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          LiquidGlassButton(icon: Icons.keyboard_arrow_down_rounded, onTap: () => Navigator.of(context).pop(), size: 44, iconSize: 26),
          Expanded(child: Column(children: [
            Text('NOW PLAYING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 2)),
          ])),
          LiquidGlassButton(icon: Icons.lyrics_rounded, onTap: onToggleLyrics, size: 44, iconSize: 22, active: showLyrics),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
  }
}

class _PlayerPanel extends StatelessWidget {
  final bool showLyrics;
  const _PlayerPanel({super.key, required this.showLyrics});
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hp = (sw * 0.07).clamp(20.0, 40.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Selector<MusicProvider, int?>(selector: (_, m) => m.currentSong?.id, builder: (_, songId, __) => _LargeAlbumArt(songId: songId ?? 0)),
          const SizedBox(height: 32),
          Selector<MusicProvider, ({String title, String artist})>(
            selector: (_, m) => (title: m.currentSong?.title ?? '', artist: m.currentSong?.artist ?? ''),
            builder: (_, info, __) => _SongInfo(title: info.title, artist: info.artist)),
          const SizedBox(height: 24),
          const _SeekBarSelector(),
          const SizedBox(height: 24),
          const _ControlsRow(),
          const Spacer(),
        ],
      ),
    );
  }
}

class _LargeAlbumArt extends StatelessWidget {
  final int songId;
  const _LargeAlbumArt({required this.songId});
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hp = (sw * 0.07).clamp(20.0, 40.0);
    final artSize = sw - (hp * 2);
    return Container(
      width: artSize, height: artSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 40, spreadRadius: -8, offset: const Offset(0, 12)),
          BoxShadow(color: AppTheme.accent.withOpacity(0.08), blurRadius: 50, spreadRadius: -12),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: QueryArtworkWidget(
          id: songId, type: ArtworkType.AUDIO,
          artworkWidth: artSize, artworkHeight: artSize, artworkFit: BoxFit.cover,
          quality: 100, size: 1200, artworkQuality: FilterQuality.high, keepOldArtwork: true,
          nullArtworkWidget: Container(
            width: artSize, height: artSize,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppTheme.accent.withOpacity(0.1), AppTheme.pink.withOpacity(0.06)])),
            child: const Icon(Icons.music_note_rounded, color: AppTheme.accent, size: 80),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms)
        .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.0, 1.0), curve: Curves.easeOutBack);
  }
}

class _SongInfo extends StatelessWidget {
  final String title;
  final String artist;
  const _SongInfo({required this.title, required this.artist});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(artist, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        LiquidGlassButton(icon: Icons.favorite_border_rounded, onTap: () {}, size: 44, iconSize: 22),
      ],
    ).animate().fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}

class _SeekBarSelector extends StatelessWidget {
  const _SeekBarSelector();
  @override
  Widget build(BuildContext context) {
    return Selector<MusicProvider, ({Duration position, Duration duration})>(
      selector: (_, m) => (position: m.position, duration: m.duration),
      builder: (_, data, __) {
        final progress = data.duration.inMilliseconds > 0 ? data.position.inMilliseconds / data.duration.inMilliseconds : 0.0;
        return _SeekBar(progress: progress.clamp(0.0, 1.0), position: data.position, duration: data.duration, onSeek: context.read<MusicProvider>().seek);
      },
    );
  }
}

class _SeekBar extends StatefulWidget {
  final double progress;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  const _SeekBar({required this.progress, required this.position, required this.duration, required this.onSeek});
  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _draggingValue;
  String _fmt(Duration d) { final m = d.inMinutes; final s = d.inSeconds % 60; return '$m:${s.toString().padLeft(2, '0')}'; }
  @override
  Widget build(BuildContext context) {
    final val = _draggingValue ?? widget.progress;
    return Column(children: [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(trackHeight: 3.5, activeTrackColor: AppTheme.accent, inactiveTrackColor: AppTheme.border, thumbColor: AppTheme.accent,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7), overlayShape: const RoundSliderOverlayShape(overlayRadius: 16), overlayColor: AppTheme.accentGlow),
        child: Slider(value: val.clamp(0.0, 1.0), onChangeStart: (_) {}, onChanged: (v) => setState(() => _draggingValue = v),
          onChangeEnd: (v) { widget.onSeek(Duration(milliseconds: (v * widget.duration.inMilliseconds).round())); setState(() => _draggingValue = null); }),
      ),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_fmt(widget.position), style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textSecondary)),
        Text(_fmt(widget.duration), style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textSecondary)),
      ])),
    ]);
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow();
  @override
  Widget build(BuildContext context) {
    return Selector<MusicProvider, ({bool isPlaying, bool isShuffle, RepeatMode repeatMode})>(
      selector: (_, m) => (isPlaying: m.isPlaying, isShuffle: m.isShuffle, repeatMode: m.repeatMode),
      builder: (_, data, __) {
        final music = context.read<MusicProvider>();
        final repeatIcon = data.repeatMode == RepeatMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded;
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
          LiquidGlassButton(icon: Icons.shuffle_rounded, onTap: music.toggleShuffle, size: 44, iconSize: 20, active: data.isShuffle),
          LiquidGlassButton(icon: Icons.skip_previous_rounded, onTap: music.skipPrev, size: 52, iconSize: 26),
          LiquidGlassPlayButton(isPlaying: data.isPlaying, onTap: music.togglePlayPause, size: 72),
          LiquidGlassButton(icon: Icons.skip_next_rounded, onTap: music.skipNext, size: 52, iconSize: 26),
          LiquidGlassButton(icon: repeatIcon, onTap: music.toggleRepeat, size: 44, iconSize: 20, active: data.repeatMode != RepeatMode.none),
        ]).animate().fadeIn(delay: 260.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut);
      },
    );
  }
}

class _LyricsPanel extends StatelessWidget {
  const _LyricsPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (_, music, __) {
        final song = music.currentSong;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 16),
            Text(song?.title ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text('LYRICS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 2)),
            const SizedBox(height: 16),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border.withOpacity(0.4), width: 1)),
                child: _buildLyricsContent(music)),
            ))),
            const SizedBox(height: 16),
          ]),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
      },
    );
  }

  Widget _buildLyricsContent(MusicProvider music) {
    if (music.isLoadingLyrics) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
        const SizedBox(height: 16),
        Text('Searching for lyrics...', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
      ]));
    }
    if (music.currentLyrics == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lyrics_outlined, color: AppTheme.textMuted, size: 48),
        const SizedBox(height: 16),
        Text('No lyrics found', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Text('Lyrics are not available for this song', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
      ]));
    }
    return SingleChildScrollView(physics: const BouncingScrollPhysics(),
      child: Text(music.currentLyrics!, style: GoogleFonts.inter(fontSize: 16, height: 2.0, color: AppTheme.textPrimary, fontWeight: FontWeight.w400), textAlign: TextAlign.center));
  }
}
