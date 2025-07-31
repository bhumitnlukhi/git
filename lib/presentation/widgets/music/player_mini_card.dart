import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/audio_entity.dart';
import '../common/glass_container.dart';
import '../../providers/player_providers.dart';

class PlayerMiniCard extends ConsumerWidget {
  const PlayerMiniCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAudio = ref.watch(currentAudioProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final progress = ref.watch(progressProvider);
    final positionText = ref.watch(positionTextProvider);
    final durationText = ref.watch(durationTextProvider);

    if (currentAudio == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            _buildProgressBar(context, progress),

            const SizedBox(height: 16),

            // Main content
            Row(
              children: [
                // Album art
                _buildAlbumArt(currentAudio.albumArt),

                const SizedBox(width: 16),

                // Music info
                Expanded(
                  child: _buildMusicInfo(context, currentAudio),
                ),

                // Controls
                _buildControls(context, ref, isPlaying),
              ],
            ),

            const SizedBox(height: 12),

            // Time info
            _buildTimeInfo(context, positionText, durationText),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ).animate().scaleX(duration: 300.ms);
  }

  Widget _buildAlbumArt(String? albumArt) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: albumArt != null
            ? CachedNetworkImage(
          imageUrl: albumArt,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        )
            : _buildPlaceholder(),
      ),
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
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMusicInfo(BuildContext context, dynamic currentAudio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentAudio.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          currentAudio.artist,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, bool isPlaying) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _buildControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: () => ref.read(playerControllerProvider.notifier).skipToPrevious(),
        ),

        const SizedBox(width: 8),

        // Play/Pause button
        _buildControlButton(
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onTap: () => ref.read(playerControllerProvider.notifier).togglePlayPause(),
          isPrimary: true,
        ),

        const SizedBox(width: 8),

        // Next button
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          onTap: () => ref.read(playerControllerProvider.notifier).skipToNext(),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 40 : 32,
        height: isPrimary ? 40 : 32,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppGradients.primary : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 20 : 16,
        ),
      ),
    ).animate().scale(delay: 100.ms);
  }

  Widget _buildTimeInfo(BuildContext context, String position, String duration) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          position,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        Text(
          duration,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class FullPlayerSheet extends ConsumerStatefulWidget {
  const FullPlayerSheet({super.key});

  @override
  ConsumerState<FullPlayerSheet> createState() => _FullPlayerSheetState();
}

class _FullPlayerSheetState extends ConsumerState<FullPlayerSheet>
    with TickerProviderStateMixin {
  late AnimationController _albumRotationController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _albumRotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _albumRotationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = ref.watch(currentAudioProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final progress = ref.watch(progressProvider);
    final volume = ref.watch(volumeProvider);
    final isShuffle = ref.watch(shuffleProvider);
    final repeatMode = ref.watch(repeatModeProvider);

    // Control album rotation based on playing state
    if (isPlaying) {
      _albumRotationController.repeat();
      _waveController.repeat();
    } else {
      _albumRotationController.stop();
      _waveController.stop();
    }

    if (currentAudio == null) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        gradient: AppGradients.dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // Large album art with rotation
                  Expanded(
                    flex: 3,
                    child: _buildLargeAlbumArt(currentAudio.albumArt, isPlaying),
                  ),

                  const SizedBox(height: 40),

                  // Music info
                  _buildLargeMusicInfo(context, currentAudio),

                  const SizedBox(height: 30),

                  // Progress slider
                  _buildProgressSlider(context, ref, progress),

                  const SizedBox(height: 40),

                  // Main controls
                  _buildMainControls(context, ref, isPlaying, isShuffle, repeatMode),

                  const SizedBox(height: 30),

                  // Volume slider
                  _buildVolumeSlider(context, ref, volume),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeAlbumArt(String? albumArt, bool isPlaying) {
    return Center(
      child: AnimatedBuilder(
        animation: _albumRotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _albumRotationController.value * 2 * 3.14159,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: ClipOval(
                  child: albumArt != null
                      ? CachedNetworkImage(
                    imageUrl: albumArt,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildLargePlaceholder(),
                    errorWidget: (context, url, error) => _buildLargePlaceholder(),
                  )
                      : _buildLargePlaceholder(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLargePlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildLargeMusicInfo(BuildContext context, dynamic currentAudio) {
    return Column(
      children: [
        Text(
          currentAudio.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          currentAudio.artist,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        if (currentAudio.album != null) ...[
          const SizedBox(height: 4),
          Text(
            currentAudio.album!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSlider(BuildContext context, WidgetRef ref, double progress) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accent.withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: progress,
            onChanged: (value) {
              final duration = ref.read(currentPlayerStateProvider).duration;
              final position = Duration(milliseconds: (duration.inMilliseconds * value).round());
              ref.read(playerControllerProvider.notifier).seekTo(position);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ref.watch(positionTextProvider),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            Text(
              ref.watch(durationTextProvider),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainControls(
      BuildContext context,
      WidgetRef ref,
      bool isPlaying,
      bool isShuffle,
      dynamic repeatMode,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        _buildLargeControlButton(
          icon: Icons.shuffle_rounded,
          isActive: isShuffle,
          onTap: () => ref.read(playerControllerProvider.notifier).toggleShuffle(),
        ),

        // Previous
        _buildLargeControlButton(
          icon: Icons.skip_previous_rounded,
          onTap: () => ref.read(playerControllerProvider.notifier).skipToPrevious(),
        ),

        // Play/Pause
        _buildLargeControlButton(
          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onTap: () => ref.read(playerControllerProvider.notifier).togglePlayPause(),
          isPrimary: true,
        ),

        // Next
        _buildLargeControlButton(
          icon: Icons.skip_next_rounded,
          onTap: () => ref.read(playerControllerProvider.notifier).skipToNext(),
        ),

        // Repeat
        _buildLargeControlButton(
          icon: _getRepeatIcon(repeatMode),
          isActive: repeatMode != RepeatMode.none,
          onTap: () => ref.read(playerControllerProvider.notifier).toggleRepeat(),
        ),
      ],
    );
  }

  Widget _buildLargeControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 70 : 50,
        height: isPrimary ? 70 : 50,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? AppGradients.primary
              : isActive
              ? AppGradients.secondary
              : null,
          color: isPrimary || isActive ? null : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 32 : 24,
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(BuildContext context, WidgetRef ref, double volume) {
    return Row(
      children: [
        Icon(
          Icons.volume_down_rounded,
          color: Colors.white.withOpacity(0.6),
          size: 20,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: volume,
              onChanged: (value) {
                ref.read(playerControllerProvider.notifier).setVolume(value);
              },
            ),
          ),
        ),
        Icon(
          Icons.volume_up_rounded,
          color: Colors.white.withOpacity(0.6),
          size: 20,
        ),
      ],
    );
  }

  IconData _getRepeatIcon(dynamic repeatMode) {
    switch (repeatMode) {
      case RepeatMode.none:
        return Icons.repeat_rounded;
      case RepeatMode.all:
        return Icons.repeat_rounded;
      case RepeatMode.one:
        return Icons.repeat_one_rounded;
      default:
        return Icons.repeat_rounded;
    }
  }
}