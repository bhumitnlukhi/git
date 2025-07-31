import 'dart:async';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:audio_service/audio_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/audio_entity.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../core/errors/failures.dart';

@LazySingleton(as: PlayerRepository)
class PlayerServiceImpl implements PlayerRepository {
  final AudioPlayer _audioPlayer;
  final StreamController<PlayerStateEntity> _stateController;
  PlayerStateEntity _currentState;

  PlayerServiceImpl()
      : _audioPlayer = AudioPlayer(),
        _stateController = StreamController<PlayerStateEntity>.broadcast(),
        _currentState = const PlayerStateEntity(
          state: PlayerState.idle,
          position: Duration.zero,
          duration: Duration.zero,
          volume: 1.0,
          isShuffle: false,
          repeatMode: RepeatMode.none,
          queue: [],
          currentIndex: -1,
        ) {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final state = _mapPlayerState(playerState);
      _updateState(state: state);
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _updateState(position: position);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _updateState(duration: duration);
      }
    });

    // Listen to current index changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index != _currentState.currentIndex) {
        final currentAudio = index < _currentState.queue.length
            ? _currentState.queue[index]
            : null;
        _updateState(currentIndex: index, currentAudio: currentAudio);
      }
    });

    // Listen to sequence state changes (for shuffle/repeat)
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        _updateState(
          isShuffle: _audioPlayer.shuffleModeEnabled,
          repeatMode: _mapLoopMode(_audioPlayer.loopMode),
        );
      }
    });
  }

  PlayerState _mapPlayerState(just_audio.PlayerState playerState) {
    if (playerState.playing) {
      return PlayerState.playing;
    } else if (playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering) {
      return PlayerState.loading;
    } else if (playerState.processingState == ProcessingState.ready) {
      return PlayerState.paused;
    } else if (playerState.processingState == ProcessingState.completed) {
      return PlayerState.stopped;
    } else {
      return PlayerState.idle;
    }
  }

  RepeatMode _mapLoopMode(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return RepeatMode.none;
      case LoopMode.one:
        return RepeatMode.one;
      case LoopMode.all:
        return RepeatMode.all;
    }
  }

  LoopMode _mapRepeatMode(RepeatMode repeatMode) {
    switch (repeatMode) {
      case RepeatMode.none:
        return LoopMode.off;
      case RepeatMode.one:
        return LoopMode.one;
      case RepeatMode.all:
        return LoopMode.all;
    }
  }

  void _updateState({
    PlayerState? state,
    AudioEntity? currentAudio,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffle,
    RepeatMode? repeatMode,
    List<AudioEntity>? queue,
    int? currentIndex,
  }) {
    _currentState = _currentState.copyWith(
      state: state,
      currentAudio: currentAudio,
      position: position,
      duration: duration,
      volume: volume,
      isShuffle: isShuffle,
      repeatMode: repeatMode,
      queue: queue,
      currentIndex: currentIndex,
    );
    _stateController.add(_currentState);
  }

  @override
  Future<Either<Failure, void>> play() async {
    try {
      await _audioPlayer.play();
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pause() async {
    try {
      await _audioPlayer.pause();
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await _audioPlayer.stop();
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      _updateState(volume: volume);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setQueue(List<AudioEntity> queue) async {
    try {
      final audioSources = queue.map((audio) {
        if (audio.type == AudioType.local) {
          return AudioSource.file(audio.filePath);
        } else {
          return AudioSource.uri(Uri.parse(audio.filePath));
        }
      }).toList();

      final playlist = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.setAudioSource(playlist);

      _updateState(queue: queue, currentIndex: 0);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToQueue(AudioEntity audio) async {
    try {
      final audioSource = audio.type == AudioType.local
          ? AudioSource.file(audio.filePath)
          : AudioSource.uri(Uri.parse(audio.filePath));

      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final playlist = _audioPlayer.audioSource as ConcatenatingAudioSource;
        await playlist.add(audioSource);

        final newQueue = List<AudioEntity>.from(_currentState.queue)..add(audio);
        _updateState(queue: newQueue);
      }

      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromQueue(int index) async {
    try {
      if (_audioPlayer.audioSource is ConcatenatingAudioSource) {
        final playlist = _audioPlayer.audioSource as ConcatenatingAudioSource;
        await playlist.removeAt(index);

        final newQueue = List<AudioEntity>.from(_currentState.queue)..removeAt(index);
        _updateState(queue: newQueue);
      }

      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> skipToNext() async {
    try {
      if (_audioPlayer.hasNext) {
        await _audioPlayer.seekToNext();
      }
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> skipToPrevious() async {
    try {
      if (_audioPlayer.hasPrevious) {
        await _audioPlayer.seekToPrevious();
      }
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> skipToIndex(int index) async {
    try {
      await _audioPlayer.seek(Duration.zero, index: index);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setShuffle(bool enabled) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(enabled);
      _updateState(isShuffle: enabled);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode) async {
    try {
      await _audioPlayer.setLoopMode(_mapRepeatMode(mode));
      _updateState(repeatMode: mode);
      return const Right(null);
    } catch (e) {
      return Left(PlayerFailure(e.toString()));
    }
  }

  @override
  Stream<PlayerStateEntity> get playerStateStream => _stateController.stream;

  @override
  PlayerStateEntity get currentState => _currentState;

  void dispose() {
    _audioPlayer.dispose();
    _stateController.close();
  }
}