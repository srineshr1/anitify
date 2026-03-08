import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── Glassmorphism Card ───────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.blur = 12,
    this.color,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: AppTheme.border.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─── Neon Glow Container ─────────────────────────────────────────────────────
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double borderRadius;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppTheme.accent,
    this.glowRadius = 24,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: glowRadius,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Apple Liquid Glass Button ────────────────────────────────────────────────
/// A translucent, frosted button inspired by Apple's liquid glass design.
/// Adapted for light theme: uses subtle dark tints on light backgrounds.
class LiquidGlassButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool active;
  final Color? activeColor;
  final double iconSize;

  const LiquidGlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.active = false,
    this.activeColor,
    this.iconSize = 24,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.activeColor ?? AppTheme.accent;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.active
                      ? [
                          accentColor.withOpacity(0.18),
                          accentColor.withOpacity(0.08),
                        ]
                      : [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.02),
                        ],
                ),
                border: Border.all(
                  color: widget.active
                      ? accentColor.withOpacity(0.4)
                      : Colors.black.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  if (widget.active)
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.active
                      ? accentColor
                      : AppTheme.textPrimary.withOpacity(0.7),
                ),       // Icon
              ),         // Center
            ),           // Container
          ),             // ScaleTransition
        ),               // ScaleTransition child
      ),                 // GestureDetector
    );
  }
}

// ─── Liquid Glass Play Button (Large) ─────────────────────────────────────────
class LiquidGlassPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;

  const LiquidGlassPlayButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
    this.size = 72,
  });

  @override
  State<LiquidGlassPlayButton> createState() => _LiquidGlassPlayButtonState();
}

class _LiquidGlassPlayButtonState extends State<LiquidGlassPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            ),
            border: Border.all(
              color: Colors.black.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                key: ValueKey(widget.isPlaying),
                color: Colors.white,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Album Art Widget ─────────────────────────────────────────────────────────
class AlbumArtWidget extends StatelessWidget {
  final int? songId;
  final double size;
  final double borderRadius;
  final bool showGlow;

  const AlbumArtWidget({
    super.key,
    required this.songId,
    this.size = 60,
    this.borderRadius = 12,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final art = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: QueryArtworkWidget(
        id: songId ?? 0,
        type: ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkFit: BoxFit.cover,
        quality: 100,
        size: 800,
        artworkQuality: FilterQuality.high,
        nullArtworkWidget: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accent.withOpacity(0.12),
                AppTheme.pink.withOpacity(0.08),
              ],
            ),
          ),
          child: Icon(Icons.music_note_rounded,
              color: AppTheme.accent.withOpacity(0.5), size: size * 0.38),
        ),
        keepOldArtwork: true,
      ),
    );

    if (!showGlow) return art;

    return GlowContainer(
      glowColor: AppTheme.accent,
      glowRadius: 30,
      borderRadius: borderRadius,
      child: art,
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accentSoft,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Old Glass Icon Button (kept for backward compat) ─────────────────────────
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;
  final bool active;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.color,
    this.active = false,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: GlassCard(
          padding: EdgeInsets.all((widget.size - 24) / 2),
          borderRadius: widget.size / 2,
          color: widget.active ? AppTheme.accent.withOpacity(0.12) : null,
          border: widget.active
              ? Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1)
              : null,
          child: Icon(
            widget.icon,
            size: 24,
            color: widget.color ?? (widget.active ? AppTheme.accent : AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(icon, size: 36, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
