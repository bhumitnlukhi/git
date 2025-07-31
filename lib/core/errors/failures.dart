import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class PlayerFailure extends Failure {
  const PlayerFailure(super.message);
}

class VoiceFailure extends Failure {
  const VoiceFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message);
}

class AudioFormatFailure extends Failure {
  const AudioFormatFailure(super.message);
}