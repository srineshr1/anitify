import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, music, _) {
        final topPad = MediaQuery.of(context).padding.top;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Playlists', style: Theme.of(context).textTheme.displayLarge)
                              .animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                          const SizedBox(height: 2),
                          Text(
                            '${music.playlists.length} playlist${music.playlists.length != 1 ? 's' : ''}',
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                          ).animate().fadeIn(delay: 80.ms),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCreateDialog(context, music),
                      child: GlowContainer(
                        glowColor: AppTheme.accent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.pink]),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text('New', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms),
                  ],
                ),
              ),
            ),
            if (music.playlists.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(icon: Icons.queue_music_rounded, title: 'No playlists yet', subtitle: 'Tap the + button to create your first playlist'),
              )
            else ...[
              if (music.playlists.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _FeaturedPlaylist(playlist: music.playlists.first, music: music),
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
                ),
              const SliverToBoxAdapter(child: SectionHeader(title: 'All Playlists')),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _PlaylistTile(
                    playlist: music.playlists[i], index: i,
                    onTap: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => _PlaylistDetailScreen(playlistId: music.playlists[i].id))),
                    onDelete: () => music.deletePlaylist(music.playlists[i].id),
                  ),
                  childCount: music.playlists.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, MusicProvider music) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: AppTheme.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('New Playlist', style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          content: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            borderRadius: 12,
            child: TextField(
              controller: ctrl, autofocus: true,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: 'Playlist name', hintStyle: GoogleFonts.inter(color: AppTheme.textMuted), border: InputBorder.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary))),
            GestureDetector(
              onTap: () { if (ctrl.text.trim().isNotEmpty) { music.createPlaylist(ctrl.text.trim()); Navigator.pop(context); } },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.pink])),
                child: Text('Create', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedPlaylist extends StatelessWidget {
  final Playlist playlist;
  final MusicProvider music;
  const _FeaturedPlaylist({required this.playlist, required this.music});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PlaylistDetailScreen(playlistId: playlist.id))),
      child: GlassCard(
        borderRadius: 22, padding: const EdgeInsets.all(20),
        color: AppTheme.accent.withOpacity(0.06),
        border: Border.all(color: AppTheme.accent.withOpacity(0.15), width: 1),
        child: Row(children: [
          _PlaylistArt(songs: playlist.songs, size: 80),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(50)),
              child: Text('FEATURED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.accentSoft, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            Text(playlist.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(playlist.trackCount, style: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.textSecondary)),
          ])),
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.accent, AppTheme.pink])),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
          ),
        ]),
      ),
    );
  }
}

class _PlaylistArt extends StatelessWidget {
  final List<Song> songs;
  final double size;
  const _PlaylistArt({required this.songs, required this.size});
  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppTheme.accent.withOpacity(0.1), AppTheme.pink.withOpacity(0.06)])),
        child: const Icon(Icons.queue_music_rounded, color: AppTheme.accent, size: 32),
      );
    }
    if (songs.length < 4) return AlbumArtWidget(songId: songs.first.id, size: size, borderRadius: 14);
    final half = size / 2;
    return ClipRRect(borderRadius: BorderRadius.circular(14),
      child: SizedBox(width: size, height: size, child: Column(children: [
        Row(children: [AlbumArtWidget(songId: songs[0].id, size: half, borderRadius: 0), AlbumArtWidget(songId: songs[1].id, size: half, borderRadius: 0)]),
        Row(children: [AlbumArtWidget(songId: songs[2].id, size: half, borderRadius: 0), AlbumArtWidget(songId: songs[3].id, size: half, borderRadius: 0)]),
      ])),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _PlaylistTile({required this.playlist, required this.index, required this.onTap, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: GlassCard(padding: const EdgeInsets.all(12), borderRadius: 16,
          child: Row(children: [
            _PlaylistArt(songs: playlist.songs, size: 54),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(playlist.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(playlist.trackCount, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            ])),
            IconButton(onPressed: () => _confirmDelete(context), icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 20)),
          ]),
        ),
      ).animate().fadeIn(delay: (index * 60).ms, duration: 350.ms).slideX(begin: 0.05),
    );
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(playlist.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        _BottomSheetOption(icon: Icons.edit_outlined, label: 'Rename', color: AppTheme.textPrimary, onTap: () => Navigator.pop(context)),
        _BottomSheetOption(icon: Icons.delete_outline_rounded, label: 'Delete Playlist', color: Colors.redAccent, onTap: () { Navigator.pop(context); onDelete(); }),
      ])),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BottomSheetOption({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.surface),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _PlaylistDetailScreen extends StatelessWidget {
  final int playlistId;
  const _PlaylistDetailScreen({required this.playlistId});
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (ctx, music, _) {
        final pl = music.playlists.firstWhere((p) => p.id == playlistId);
        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 240, backgroundColor: AppTheme.bg,
              leading: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary)),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(fit: StackFit.expand, children: [
                  Container(decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [AppTheme.accent.withOpacity(0.08), AppTheme.pink.withOpacity(0.05)]))),
                  Center(child: _PlaylistArt(songs: pl.songs, size: 130)),
                ]),
                title: Text(pl.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(children: [
                Text(pl.trackCount, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                const Spacer(),
                if (pl.songs.isNotEmpty)
                  GestureDetector(
                    onTap: () => music.playSong(pl.songs.first, fromList: pl.songs),
                    child: GlowContainer(glowColor: AppTheme.accent, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.pink])),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text('Play All', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ]),
                    )),
                  ),
              ])),
            ),
            pl.songs.isEmpty
                ? const SliverFillRemaining(child: EmptyState(icon: Icons.music_off_rounded, title: 'Playlist is empty', subtitle: 'Add songs from your library'))
                : SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
                    final song = pl.songs[i];
                    return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 6), child: GlassCard(padding: const EdgeInsets.all(10), borderRadius: 14,
                      child: Row(children: [
                        AlbumArtWidget(songId: song.id, size: 46, borderRadius: 10),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(song.title, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(song.artist, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),
                        IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20), onPressed: () => music.removeFromPlaylist(playlistId, song.id)),
                      ]),
                    )).animate().fadeIn(delay: (i * 40).ms);
                  }, childCount: pl.songs.length)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ]),
        );
      },
    );
  }
}
