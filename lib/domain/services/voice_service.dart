import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

enum VoiceCommand {
  play,
  pause,
  stop,
  next,
  previous,
  volumeUp,
  volumeDown,
  shuffle,
  repeat,
  playArtist,
  playAlbum,
  playSong,
  playPlaylist,
  playRadio,
  addToFavorites,
  removeFromFavorites,
  unknown,
}

class VoiceCommandEntity {
  final VoiceCommand command;
  final String? parameter;
  final Map<String, dynamic>? additionalData;

  const VoiceCommandEntity({
    required this.command,
    this.parameter,
    this.additionalData,
  });
}

abstract class VoiceService {
  // Speech Recognition
  Future<Either<Failure, void>> startListening();
  Future<Either<Failure, void>> stopListening();
  Future<Either<Failure, bool>> get isListening;
  Stream<String> get speechStream;

  // Text to Speech
  Future<Either<Failure, void>> speak(String text);
  Future<Either<Failure, void>> stop();

  // Voice Command Processing
  VoiceCommandEntity processVoiceInput(String input);

  // Voice Settings
  Future<Either<Failure, void>> setLanguage(String languageCode);
  Future<Either<Failure, void>> setSpeechRate(double rate);
  Future<Either<Failure, void>> setPitch(double pitch);

  // Permissions
  Future<Either<Failure, bool>> requestPermissions();
  Future<Either<Failure, bool>> get hasPermissions;
}