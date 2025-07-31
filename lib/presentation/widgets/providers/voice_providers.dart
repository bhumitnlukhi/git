import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git/core/di/injection.dart';
import 'package:git/domain/services/voice_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/services/voice_service.dart';
import '../../core/di/injection.dart';
import 'player_providers.dart';
import 'music_providers.dart';

part 'voice_providers.g.dart';

// Voice Service Provider
final voiceServiceProvider = Provider<VoiceService>((ref) {
  return getIt<VoiceService>();
});

// Voice State Class
class VoiceState {
  final bool isListening;
  final bool isInitialized;
  final String? lastCommand;
  final String? lastResponse;
  final bool hasPermissions;

  const VoiceState({
    this.isListening = false,
    this.isInitialized = false,
    this.lastCommand,
    this.lastResponse,
    this.hasPermissions = false,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isInitialized,
    String? lastCommand,
    String? lastResponse,
    bool? hasPermissions,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      lastCommand: lastCommand ?? this.lastCommand,
      lastResponse: lastResponse ?? this.lastResponse,
      hasPermissions: hasPermissions ?? this.hasPermissions,
    );
  }
}

// Voice Controller
@riverpod
class VoiceController extends _$VoiceController {
  VoiceService get _service => ref.read(voiceServiceProvider);

  @override
  Future<VoiceState> build() async {
    await _initialize();
    _listenToSpeech();
    return const VoiceState();
  }

  Future<void> _initialize() async {
    final hasPermissions = await _service.hasPermissions;
    hasPermissions.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (permissions) {
        if (!permissions) {
          _requestPermissions();
        } else {
          state = AsyncValue.data(
            const VoiceState(isInitialized: true, hasPermissions: true),
          );
        }
      },
    );
  }

  Future<void> _requestPermissions() async {
    final result = await _service.requestPermissions();
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (granted) {
        state = AsyncValue.data(
          VoiceState(isInitialized: true, hasPermissions: granted),
        );
      },
    );
  }

  void _listenToSpeech() {
    _service.speechStream.listen(
          (command) {
        _processVoiceCommand(command);
      },
      onError: (error) {
        state = AsyncValue.error(error.toString(), StackTrace.current);
      },
    );
  }

  Future<void> startListening() async {
    final currentState = state.asData?.value;
    if (currentState?.hasPermissions != true) {
      await _requestPermissions();
      return;
    }

    final result = await _service.startListening();
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) {
        final newState = currentState?.copyWith(isListening: true) ??
            const VoiceState(isListening: true);
        state = AsyncValue.data(newState);
      },
    );
  }

  Future<void> stopListening() async {
    final result = await _service.stopListening();
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) {
        final currentState = state.asData?.value;
        final newState = currentState?.copyWith(isListening: false) ??
            const VoiceState(isListening: false);
        state = AsyncValue.data(newState);
      },
    );
  }

  Future<void> _processVoiceCommand(String input) async {
    final command = _service.processVoiceInput(input);
    final currentState = state.asData?.value;

    // Update state with the command
    state = AsyncValue.data(
      currentState?.copyWith(lastCommand: input) ??
          VoiceState(lastCommand: input),
    );

    // Execute the command
    await _executeCommand(command);
  }

  Future<void> _executeCommand(VoiceCommandEntity command) async {
    final playerController = ref.read(playerControllerProvider.notifier);
    String response = '';

    try {
      switch (command.command) {
        case VoiceCommand.play:
          await playerController.play();
          response = 'Playing music';
          break;

        case VoiceCommand.pause:
          await playerController.pause();
          response = 'Music paused';
          break;

        case VoiceCommand.stop:
          await playerController.stop();
          response = 'Music stopped';
          break;

        case VoiceCommand.next:
          await playerController.skipToNext();
          response = 'Playing next song';
          break;

        case VoiceCommand.previous:
          await playerController.skipToPrevious();
          response = 'Playing previous song';
          break;

        case VoiceCommand.volumeUp:
          final currentVolume = ref.read(volumeProvider);
          await playerController.setVolume((currentVolume + 0.1).clamp(0.0, 1.0));
          response = 'Volume increased';
          break;

        case VoiceCommand.volumeDown:
          final currentVolume = ref.read(volumeProvider);
          await playerController.setVolume((currentVolume - 0.1).clamp(0.0, 1.0));
          response = 'Volume decreased';
          break;

        case VoiceCommand.shuffle:
          await playerController.toggleShuffle();
          final isShuffleOn = ref.read(shuffleProvider);
          response = isShuffleOn ? 'Shuffle enabled' : 'Shuffle disabled';
          break;

        case VoiceCommand.repeat:
          await playerController.toggleRepeat();
          final repeatMode = ref.read(repeatModeProvider);
          response = 'Repeat mode: ${repeatMode.name}';
          break;

        case VoiceCommand.playSong:
          if (command.parameter != null) {
            await _playSearchedSong(command.parameter!);
            response = 'Playing ${command.parameter}';
          }
          break;

        case VoiceCommand.playArtist:
          if (command.parameter != null) {
            await _playArtistSongs(command.parameter!);
            response = 'Playing songs by ${command.parameter}';
          }
          break;

        case VoiceCommand.playAlbum:
          if (command.parameter != null) {
            await _playAlbumSongs(command.parameter!);
            response = 'Playing album ${command.parameter}';
          }
          break;

        case VoiceCommand.playPlaylist:
          if (command.parameter != null) {
            await _playPlaylist(command.parameter!);
            response = 'Playing playlist ${command.parameter}';
          }
          break;

        case VoiceCommand.playRadio:
          if (command.parameter != null) {
            await _playRadioStation(command.parameter!);
            response = 'Playing ${command.parameter} radio';
          }
          break;

        case VoiceCommand.addToFavorites:
          await playerController.toggleFavorite();
          response = 'Added to favorites';
          break;

        case VoiceCommand.removeFromFavorites:
          await playerController.toggleFavorite();
          response = 'Removed from favorites';
          break;

        case VoiceCommand.unknown:
          response = 'Sorry, I didn\'t understand that command';
          break;
      }

      // Speak the response
      await _service.speak(response);

      // Update state with response
      final currentState = state.asData?.value;
      state = AsyncValue.data(
        currentState?.copyWith(lastResponse: response) ??
            VoiceState(lastResponse: response),
      );

    } catch (e) {
      response = 'Sorry, something went wrong';
      await _service.speak(response);

      final currentState = state.asData?.value;
      state = AsyncValue.data(
        currentState?.copyWith(lastResponse: response) ??
            VoiceState(lastResponse: response),
      );
    }
  }

  Future<void> _playSearchedSong(String songName) async {
    final searchResults = await ref.read(searchResultsProvider(songName).future);
    if (searchResults.isNotEmpty) {
      final playerController = ref.read(playerControllerProvider.notifier);
      await playerController.playAudio(searchResults.first);
    }
  }

  Future<void> _playArtistSongs(String artistName) async {
    final localMusic = await ref.read(localMusicProvider.future);
    final artistSongs = localMusic.where((audio) =>
        audio.artist.toLowerCase().contains(artistName.toLowerCase())
    ).toList();

    if (artistSongs.isNotEmpty) {
      final playerController = ref.read(playerControllerProvider.notifier);
      await playerController.playQueue(artistSongs);
    }
  }

  Future<void> _playAlbumSongs(String albumName) async {
    final localMusic = await ref.read(localMusicProvider.future);
    final albumSongs = localMusic.where((audio) =>
    audio.album?.toLowerCase().contains(albumName.toLowerCase()) == true
    ).toList();

    if (albumSongs.isNotEmpty) {
      final playerController = ref.read(playerControllerProvider.notifier);
      await playerController.playQueue(albumSongs);
    }
  }

  Future<void> _playPlaylist(String playlistName) async {
    final playlists = await ref.read(playlistsProvider.future);
    final playlist = playlists.firstWhere(
          (p) => p.name.toLowerCase().contains(playlistName.toLowerCase()),
      orElse: () => throw Exception('Playlist not found'),
    );

    if (playlist.songs.isNotEmpty) {
      final playerController = ref.read(playerControllerProvider.notifier);
      await playerController.playQueue(playlist.songs);
    }
  }

  Future<void> _playRadioStation(String stationName) async {
    final radioStations = await ref.read(radioStationsProvider.future);
    final station = radioStations.firstWhere(
          (s) => s.name.toLowerCase().contains(stationName.toLowerCase()),
      orElse: () => throw Exception('Radio station not found'),
    );

    // Convert radio station to audio entity and play
    final radioAudio = AudioEntity(
      id: station.id,
      title: station.name,
      artist: 'Radio',
      filePath: station.streamUrl,
      duration: Duration.zero,
      type: AudioType.radio,
    );

    final playerController = ref.read(playerControllerProvider.notifier);
    await playerController.playAudio(radioAudio);
  }

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    await _initialize();
  }

  Future<void> setLanguage(String languageCode) async {
    await _service.setLanguage(languageCode);
  }

  Future<void> setSpeechRate(double rate) async {
    await _service.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _service.setPitch(pitch);
  }
}

// Voice Settings Provider
final voiceSettingsProvider = StateProvider<VoiceSettings>((ref) {
  return const VoiceSettings();
});

class VoiceSettings {
  final String language;
  final double speechRate;
  final double pitch;
  final bool autoListen;

  const VoiceSettings({
    this.language = 'en-US',
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.autoListen = false,
  });

  VoiceSettings copyWith({
    String? language,
    double? speechRate,
    double? pitch,
    bool? autoListen,
  }) {
    return VoiceSettings(
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      autoListen: autoListen ?? this.autoListen,
    );
  }
}