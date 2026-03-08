import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/mini_player.dart';
import 'now_playing_screen.dart';
import 'playlists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _LibraryTab(query: _query, searchController: _searchController, onQuery: (q) => setState(() => _query = q)),
                const PlaylistsScreen(),
              ],
            ),
          ),
          const MiniPlayer(),
          _BottomNav(
            selected: _selectedTab,
            onTap: (i) => setState(() => _selectedTab = i),
          ),
        ],
      ),
    );
  }
}

// ─── Library Tab ──────────────────────────────────────────────────────────────
class _LibraryTab extends StatelessWidget {
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onQuery;

  const _LibraryTab({
    required this.query,
    required this.searchController,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, music, _) {
        if (!music.permissionGranted && !music.isLoading) {
          return _PermissionView(onGrant: music.requestPermissionsAndLoad);
        }

        if (music.isLoading) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppTheme.accent),
                const SizedBox(height: 16),
                Text('Scanning music library...',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        if (music.error != null) {
          return EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong',
            subtitle: music.error!,
          );
        }

        final filtered = query.isEmpty
            ? music.library
            : music.library.where((s) =>
                s.title.toLowerCase().contains(query.toLowerCase()) ||
                s.artist.toLowerCase().contains(query.toLowerCase())).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _GreetingHeader()),
            SliverToBoxAdapter(child: _SearchBar(controller: searchController, onChanged: onQuery)),
            if (query.isEmpty && music.recentlyAdded.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SectionHeader(title: 'Recently Added')),
              SliverToBoxAdapter(child: _RecentRow(songs: music.recentlyAdded)),
            ],
            SliverToBoxAdapter(
              child: SectionHeader(
                title: query.isEmpty ? 'All Songs' : 'Results',
                action: query.isEmpty ? '${music.library.length} tracks' : null,
              ),
            ),
            filtered.isEmpty
                ? const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No songs found',
                      subtitle: 'Try a different search term',
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _SongTile(
                        song: filtered[i],
                        index: i,
                        onTap: () {
                          context.read<MusicProvider>().playSong(filtered[i], fromList: filtered);
                          Navigator.of(ctx).push(
                            PageRouteBuilder(
                              pageBuilder: (_, a, __) => const NowPlayingScreen(),
                              transitionsBuilder: (_, a, __, child) => SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 1),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                                child: child,
                              ),
                              transitionDuration: const Duration(milliseconds: 380),
                            ),
                          );
                        },
                      ),
                      childCount: filtered.length,
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        );
      },
    );
  }
}

// ─── Greeting Header ──────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, curve: Curves.easeOut),
                const SizedBox(height: 2),
                Text(
                  'What do you want to listen to?',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
              ],
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(10),
            borderRadius: 14,
            child: const Icon(Icons.graphic_eq_rounded, color: AppTheme.accent, size: 22),
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search songs, artists...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
            border: InputBorder.none,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 120.ms, duration: 400.ms);
  }
}

// ─── Horizontal Recent Row (Large Album Cards) ───────────────────────────────
class _RecentRow extends StatelessWidget {
  final List<Song> songs;

  const _RecentRow({required this.songs});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardSize = (screenW * 0.36).clamp(120.0, 160.0);

    return SizedBox(
      height: cardSize + 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.take(8).length,
        itemBuilder: (ctx, i) {
          final song = songs[i];
          return GestureDetector(
            onTap: () {
              ctx.read<MusicProvider>().playSong(song, fromList: songs);
              Navigator.of(ctx).push(PageRouteBuilder(
                pageBuilder: (_, a, __) => const NowPlayingScreen(),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 280),
              ));
            },
            child: Container(
              width: cardSize,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large album art card
                  Container(
                    height: cardSize,
                    width: cardSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AlbumArtWidget(songId: song.id, size: cardSize, borderRadius: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(song.title,
                      style: GoogleFonts.inter(fontSize: 12.5, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(song.artist,
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05, curve: Curves.easeOut);
        },
      ),
    );
  }
}

// ─── Song Tile ────────────────────────────────────────────────────────────────
class _SongTile extends StatelessWidget {
  final Song song;
  final int index;
  final VoidCallback onTap;

  const _SongTile({required this.song, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (ctx, music, _) {
        final isPlaying = music.currentSong?.id == song.id;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: GlassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 14,
              color: isPlaying ? AppTheme.accent.withOpacity(0.08) : null,
              border: isPlaying
                  ? Border.all(color: AppTheme.accent.withOpacity(0.25), width: 1)
                  : null,
              child: Row(
                children: [
                  AlbumArtWidget(songId: song.id, size: 48, borderRadius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isPlaying ? AppTheme.accent : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artist,
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isPlaying)
                    _WaveIndicator()
                  else
                    Text(
                      song.durationFormatted,
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                  const SizedBox(width: 8),
                  Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 18),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 25).ms, duration: 300.ms).slideY(begin: 0.05, curve: Curves.easeOut);
      },
    );
  }
}

// ─── Wave Indicator (playing) ─────────────────────────────────────────────────
class _WaveIndicator extends StatefulWidget {
  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();
}

class _WaveIndicatorState extends State<_WaveIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + i * 80),
      );
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, __) => Container(
              width: 3,
              height: 6 + _controllers[i].value * 10,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Permission View ──────────────────────────────────────────────────────────
class _PermissionView extends StatelessWidget {
  final VoidCallback onGrant;

  const _PermissionView({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: AppTheme.accentGlow, blurRadius: 32, spreadRadius: -4)],
              ),
              child: const Icon(Icons.music_note_rounded, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Access Your Music',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Aura needs permission to read your local music files.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onGrant,
              child: GlowContainer(
                glowColor: AppTheme.accent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.pink],
                    ),
                  ),
                  child: Text(
                    'Grant Permission',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const items = [
      (Icons.library_music_rounded, Icons.library_music_outlined, 'Library'),
      (Icons.queue_music_rounded, Icons.queue_music_outlined, 'Playlists'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad > 0 ? bottomPad : 16),
      child: GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final (activeIcon, inactiveIcon, label) = items[i];
            final isActive = selected == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isActive ? activeIcon : inactiveIcon,
                          key: ValueKey(isActive),
                          color: isActive ? AppTheme.accent : AppTheme.textMuted,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppTheme.accent : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
