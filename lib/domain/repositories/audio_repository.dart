import 'package:dartz/dartz.dart';
import '../entities/audio_entity.dart';
import '../../core/errors/failures.dart';

abstract class AudioRepository {
  // Local Music Operations
  Future<Either<Failure, List<AudioEntity>>> getLocalMusic();
  Future<Either<Failure, void>> scanDeviceForMusic();

  // Online Music Operations
  Future<Either<Failure, List<AudioEntity>>> searchOnlineMusic(String query);
  Future<Either<Failure, List<AudioEntity>>> getTrendingMusic();
  Future<Either<Failure, List<AudioEntity>>> getRecommendations();

  // Radio Operations
  Future<Either<Failure, List<RadioStationEntity>>> getRadioStations();
  Future<Either<Failure, List<RadioStationEntity>>> getRadioStationsByCategory(String category);

  // Playlist Operations
  Future<Either<Failure, List<PlaylistEntity>>> getPlaylists();
  Future<Either<Failure, PlaylistEntity>> createPlaylist(String name, String? description);
  Future<Either<Failure, void>> addToPlaylist(String playlistId, String audioId);
  Future<Either<Failure, void>> removeFromPlaylist(String playlistId, String audioId);
  Future<Either<Failure, void>> deletePlaylist(String playlistId);

  // Favorites
  Future<Either<Failure, List<AudioEntity>>> getFavorites();
  Future<Either<Failure, void>> addToFavorites(String audioId);
  Future<Either<Failure, void>> removeFromFavorites(String audioId);

  // Recently Played
  Future<Either<Failure, List<AudioEntity>>> getRecentlyPlayed();
  Future<Either<Failure, void>> addToRecentlyPlayed(String audioId);
}

abstract class PlayerRepository {
  // Player Control
  Future<Either<Failure, void>> play();
  Future<Either<Failure, void>> pause();
  Future<Either<Failure, void>> stop();
  Future<Either<Failure, void>> seekTo(Duration position);
  Future<Either<Failure, void>> setVolume(double volume);

  // Queue Management
  Future<Either<Failure, void>> setQueue(List<AudioEntity> queue);
  Future<Either<Failure, void>> addToQueue(AudioEntity audio);
  Future<Either<Failure, void>> removeFromQueue(int index);
  Future<Either<Failure, void>> skipToNext();
  Future<Either<Failure, void>> skipToPrevious();
  Future<Either<Failure, void>> skipToIndex(int index);

  // Player Settings
  Future<Either<Failure, void>> setShuffle(bool enabled);
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode);

  // Player State
  Stream<PlayerStateEntity> get playerStateStream;
  PlayerStateEntity get currentState;
}