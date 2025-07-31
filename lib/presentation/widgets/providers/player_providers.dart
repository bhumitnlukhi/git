import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git/domain/entities/audio_entity.dart';
import 'package:git/domain/repositories/audio_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'music_providers.dart';


// Player State Stream Provider
final playerStateProvider = StreamProvider<PlayerStateEntity>((ref) {
  final playerRepository = ref.read(playerRepositoryProvider);
  return playerRepository.playerStateStream;
});

// Current Player State Provider
final currentPlayerStateProvider = Provider<PlayerStateEntity>((ref) {
  final playerRepository = ref.read(playerRepositoryProvider);
  return playerRepository.currentState;
});

// Player Controller
@riverpod
class PlayerController extends _$PlayerController {
  PlayerRepository get _repository => ref.read(playerRepositoryProvider);

  @override
  PlayerStateEntity build() {
    return _repository.currentState;
  }

  // Playback Control
  Future<void> play() async {
    final result = await _repository.play();
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> pause() async {
    final result = await _repository.pause();
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> stop() async {
    final result = await _repository.stop();
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> seekTo(Duration position) async {
    final result = await _repository.seekTo(position);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  // Queue Management
  Future<void> playAudio(AudioEntity audio) async {
    final result = await _repository.setQueue([audio]);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => play(),
    );

    // Add to recent
    ref.read(recentMusicProvider.notifier).addToRecent(audio.id);
  }

  Future<void> playQueue(List<AudioEntity> queue, {int startIndex = 0}) async {
    final result = await _repository.setQueue(queue);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) async {
        if (startIndex > 0) {
          await skipToIndex(startIndex);
        }
        await play();
      },
    );
  }

  Future<void> addToQueue(AudioEntity audio) async {
    final result = await _repository.addToQueue(audio);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> removeFromQueue(int index) async {
    final result = await _repository.removeFromQueue(index);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  // Navigation
  Future<void> skipToNext() async {
    final result = await _repository.skipToNext();
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> skipToPrevious() async {
    final result = await _repository.skipToPrevious();
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> skipToIndex(int index) async {
    final result = await _repository.skipToIndex(index);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  // Settings
  Future<void> setVolume(double volume) async {
    final result = await _repository.setVolume(volume);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> toggleShuffle() async {
    final currentState = _repository.currentState;
    final result = await _repository.setShuffle(!currentState.isShuffle);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> toggleRepeat() async {
    final currentState = _repository.currentState;
    RepeatMode nextMode;

    switch (currentState.repeatMode) {
      case RepeatMode.none:
        nextMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        nextMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        nextMode = RepeatMode.none;
        break;
    }

    final result = await _repository.setRepeatMode(nextMode);
    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => {},
    );
  }

  Future<void> togglePlayPause() async {
    final currentState = _repository.currentState;
    if (currentState.state == PlayerState.playing) {
      await pause();
    } else {
      await play();
    }
  }

  // Favorites
  Future<void> toggleFavorite() async {
    final currentAudio = _repository.currentState.currentAudio;
    if (currentAudio == null) return;

    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    if (currentAudio.isFavorite) {
      await favoritesNotifier.removeFromFavorites(currentAudio.id);
    } else {
      await favoritesNotifier.addToFavorites(currentAudio.id);
    }
  }
}

// Progress Provider (for UI updates)
final progressProvider = Provider<double>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  if (playerState == null) return 0.0;

  final position = playerState.position.inMilliseconds.toDouble();
  final duration = playerState.duration.inMilliseconds.toDouble();

  if (duration == 0) return 0.0;
  return (position / duration).clamp(0.0, 1.0);
});

// Position Text Provider
final positionTextProvider = Provider<String>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  if (playerState == null) return '0:00';

  final position = playerState.position;
  final minutes = position.inMinutes;
  final seconds = position.inSeconds % 60;

  return '$minutes:${seconds.toString().padLeft(2, '0')}';
});

// Duration Text Provider
final durationTextProvider = Provider<String>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  if (playerState == null) return '0:00';

  final duration = playerState.duration;
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;

  return '$minutes:${seconds.toString().padLeft(2, '0')}';
});

// Is Playing Provider
final isPlayingProvider = Provider<bool>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.state == PlayerState.playing;
});

// Current Audio Provider
final currentAudioProvider = Provider<AudioEntity?>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.currentAudio;
});

// Volume Provider
final volumeProvider = Provider<double>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.volume ?? 1.0;
});

// Shuffle Provider
final shuffleProvider = Provider<bool>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.isShuffle ?? false;
});

// Repeat Mode Provider
final repeatModeProvider = Provider<RepeatMode>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.repeatMode ?? RepeatMode.none;
});

// Queue Provider
final queueProvider = Provider<List<AudioEntity>>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.queue ?? [];
});

// Current Index Provider
final currentIndexProvider = Provider<int>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  return playerState?.currentIndex ?? -1;
});

// Has Next Provider
final hasNextProvider = Provider<bool>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  if (playerState == null) return false;

  return playerState.currentIndex < (playerState.queue.length - 1);
});

// Has Previous Provider
final hasPreviousProvider = Provider<bool>((ref) {
  final playerState = ref.watch(playerStateProvider).asData?.value;
  if (playerState == null) return false;

  return playerState.currentIndex > 0;
});