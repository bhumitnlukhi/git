import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:injectable/injectable.dart';

import '../../domain/services/voice_service.dart';
import '../../core/errors/failures.dart';

@LazySingleton(as: VoiceService)
class VoiceServiceImpl implements VoiceService {
  final SpeechToText _speechToText;
  final FlutterTts _flutterTts;
  final StreamController<String> _speechController;

  bool _isListening = false;
  bool _isInitialized = false;

  VoiceServiceImpl()
      : _speechToText = SpeechToText(),
        _flutterTts = FlutterTts(),
        _speechController = StreamController<String>.broadcast() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize Speech to Text
      final available = await _speechToText.initialize(
        onError: (error) {
          _speechController.addError(error.errorMsg);
        },
        onStatus: (status) {
          _isListening = status == 'listening';
        },
      );

      if (!available) {
        throw Exception('Speech recognition not available');
      }

      // Initialize Text to Speech
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(0.8);

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  @override
  Future<Either<Failure, void>> startListening() async {
    try {
      if (!_isInitialized) {
        await _initializeServices();
      }

      if (!_speechToText.isAvailable) {
        return Left(VoiceFailure('Speech recognition not available'));
      }

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _speechController.add(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: 'en_US',
        cancelOnError: true,
      );

      _isListening = true;
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> get isListening async {
    return Right(_isListening);
  }

  @override
  Stream<String> get speechStream => _speechController.stream;

  @override
  Future<Either<Failure, void>> speak(String text) async {
    try {
      await _flutterTts.speak(text);
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      await _flutterTts.stop();
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  VoiceCommandEntity processVoiceInput(String input) {
    final lowerInput = input.toLowerCase().trim();

    // Play commands
    if (lowerInput.contains('play')) {
      if (lowerInput.contains('radio')) {
        final radioMatch = RegExp(r'play (?:radio )?(.+)').firstMatch(lowerInput);
        return VoiceCommandEntity(
          command: VoiceCommand.playRadio,
          parameter: radioMatch?.group(1)?.trim(),
        );
      } else if (lowerInput.contains('artist')) {
        final artistMatch = RegExp(r'play artist (.+)').firstMatch(lowerInput);
        return VoiceCommandEntity(
          command: VoiceCommand.playArtist,
          parameter: artistMatch?.group(1)?.trim(),
        );
      } else if (lowerInput.contains('album')) {
        final albumMatch = RegExp(r'play album (.+)').firstMatch(lowerInput);
        return VoiceCommandEntity(
          command: VoiceCommand.playAlbum,
          parameter: albumMatch?.group(1)?.trim(),
        );
      } else if (lowerInput.contains('playlist')) {
        final playlistMatch = RegExp(r'play playlist (.+)').firstMatch(lowerInput);
        return VoiceCommandEntity(
          command: VoiceCommand.playPlaylist,
          parameter: playlistMatch?.group(1)?.trim(),
        );
      } else {
        // Extract song name after "play"
        final songMatch = RegExp(r'play (.+)').firstMatch(lowerInput);
        return VoiceCommandEntity(
          command: VoiceCommand.playSong,
          parameter: songMatch?.group(1)?.trim(),
        );
      }
    }

    // Control commands
    if (lowerInput.contains('pause')) {
      return const VoiceCommandEntity(command: VoiceCommand.pause);
    }

    if (lowerInput.contains('stop')) {
      return const VoiceCommandEntity(command: VoiceCommand.stop);
    }

    if (lowerInput.contains('next') || lowerInput.contains('skip')) {
      return const VoiceCommandEntity(command: VoiceCommand.next);
    }

    if (lowerInput.contains('previous') || lowerInput.contains('back')) {
      return const VoiceCommandEntity(command: VoiceCommand.previous);
    }

    // Volume commands
    if (lowerInput.contains('volume up') || lowerInput.contains('increase volume')) {
      return const VoiceCommandEntity(command: VoiceCommand.volumeUp);
    }

    if (lowerInput.contains('volume down') || lowerInput.contains('decrease volume')) {
      return const VoiceCommandEntity(command: VoiceCommand.volumeDown);
    }

    // Mode commands
    if (lowerInput.contains('shuffle')) {
      return const VoiceCommandEntity(command: VoiceCommand.shuffle);
    }

    if (lowerInput.contains('repeat')) {
      return const VoiceCommandEntity(command: VoiceCommand.repeat);
    }

    // Favorites commands
    if (lowerInput.contains('add to favorites') || lowerInput.contains('like this song')) {
      return const VoiceCommandEntity(command: VoiceCommand.addToFavorites);
    }

    if (lowerInput.contains('remove from favorites') || lowerInput.contains('unlike this song')) {
      return const VoiceCommandEntity(command: VoiceCommand.removeFromFavorites);
    }

    return const VoiceCommandEntity(command: VoiceCommand.unknown);
  }

  @override
  Future<Either<Failure, void>> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 1.0));
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
      return const Right(null);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await _initializeServices();
      }
      return Right(_speechToText.isAvailable);
    } catch (e) {
      return Left(VoiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> get hasPermissions async {
    return Right(_speechToText.isAvailable);
  }

  void dispose() {
    _speechController.close();
    _flutterTts.stop();
  }
}