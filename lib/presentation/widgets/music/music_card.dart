import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../domain/entities/audio_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../common/glass_container.dart';

class MusicCard extends StatelessWidget {
  final AudioEntity audio;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isPlaying;
  final double width;
  final double height;

  const MusicCard({
    super.key,
    required this.audio,
    this.onTap,
    this.onLongPress,
    this.isPlaying = false,
    this.width = 150,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedGlassContainer(
      width: width,
      height: height,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildAlbumArt(context),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildMusicInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: audio.albumArt != null
                ? CachedNetworkImage(
              imageUrl: audio.albumArt!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
                : _buildPlaceholder(),
          ),
        ),

        // Play indicator overlay
        if (isPlaying)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.3),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
                .then()
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.8, 0.8)),
          ),

        // Audio type indicator
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getTypeLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Favorite indicator
        if (audio.isFavorite)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildMusicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          audio.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          audio.artist,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (audio.album != null) ...[
          const SizedBox(height: 2),
          Text(
            audio.album!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        _buildDurationChip(),
      ],
    );
  }

  Widget _buildDurationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formatDuration(audio.duration),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (audio.type) {
      case AudioType.local:
        return AppColors.success;
      case AudioType.online:
        return AppColors.accent;
      case AudioType.radio:
        return AppColors.warning;
    }
  }

  String _getTypeLabel() {
    switch (audio.type) {
      case AudioType.local:
        return 'LOCAL';
      case AudioType.online:
        return 'ONLINE';
      case AudioType.radio:
        return 'RADIO';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class MusicListTile extends StatelessWidget {
  final AudioEntity audio;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool isPlaying;
  final int? index;

  const MusicListTile({
    super.key,
    required this.audio,
    this.onTap,
    this.onMoreTap,
    this.isPlaying = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Index or play indicator
          SizedBox(
            width: 40,
            child: isPlaying
                ? Icon(
              Icons.graphic_eq_rounded,
              color: AppColors.accent,
              size: 24,
            ).animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.8, 0.8))
                .then()
                .scale(begin: const Offset(1.2, 1.2))
                : index != null
                ? Text(
              '${index! + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                : const SizedBox(),
          ),

          const SizedBox(width: 12),

          // Album art
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: audio.albumArt != null
                  ? CachedNetworkImage(
                imageUrl: audio.albumArt!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildSmallPlaceholder(),
                errorWidget: (context, url, error) => _buildSmallPlaceholder(),
              )
                  : _buildSmallPlaceholder(),
            ),
          ),

          const SizedBox(width: 16),

          // Music info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      audio.artist,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (audio.album != null) ...[
                      Text(
                        ' • ${audio.album}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Duration and actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(audio.duration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (audio.isFavorite)
                    Icon(
                      Icons.favorite_rounded,
                      color: AppColors.error,
                      size: 14,
                    ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onMoreTap,
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return '--:--';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}