import 'dart:io';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/audio_entity.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../core/errors/failures.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final List<AudioEntity> _localMusic = [];
  final List<AudioEntity> _favorites = [];
  final List<AudioEntity> _recentlyPlayed = [];
  final List<PlaylistEntity> _playlists = [];

  @override
  Future<Either<Failure, List<AudioEntity>>> getLocalMusic() async {
    try {
      if (_localMusic.isEmpty) {
        await _scanForLocalMusic();
      }
      return Right(_localMusic);
    } catch (e) {
      return Left(FileSystemFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> scanDeviceForMusic() async {
    try {
      await _requestPermissions();
      await _scanForLocalMusic();
      return const Right(null);
    } catch (e) {
      return Left(FileSystemFailure(e.toString()));
    }
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.audio,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        throw Exception('Permission ${permission.toString()} not granted');
      }
    }
  }

  Future<void> _scanForLocalMusic() async {
    try {
      _localMusic.clear();

      // Get common music directories
      final directories = await _getMusicDirectories();

      for (final directory in directories) {
        if (await directory.exists()) {
          await _scanDirectory(directory);
        }
      }
    } catch (e) {
      throw Exception('Failed to scan for music: $e');
    }
  }

  Future<List<Directory>> _getMusicDirectories() async {
    final directories = <Directory>[];

    try {
      // External storage directories
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        directories.addAll([
          Directory('${externalDir.path}/Music'),
          Directory('${externalDir.path}/Download'),
          Directory('${externalDir.path}/Downloads'),
        ]);
      }

      // Common Android music directories
      directories.addAll([
        Directory('/storage/emulated/0/Music'),
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Downloads'),
        Directory('/sdcard/Music'),
        Directory('/sdcard/Download'),
        Directory('/sdcard/Downloads'),
      ]);
    } catch (e) {
      // Fallback directories if permissions are limited
    }

    return directories;
  }

  Future<void> _scanDirectory(Directory directory) async {
    try {
      final entities = directory.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        if (entity is File && _isAudioFile(entity.path)) {
          final audioEntity = await _createAudioEntity(entity);
          if (audioEntity != null) {
            _localMusic.add(audioEntity);
          }
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }

  bool _isAudioFile(String path) {
    final extensions = ['.mp3', '.m4a', '.wav', '.flac', '.aac', '.ogg', '.wma'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  Future<AudioEntity?> _createAudioEntity(File file) async {
    try {
      final stat = await file.stat();
      final fileName = file.path.split('/').last;
      final nameWithoutExtension = fileName.split('.').first;

      // Basic metadata extraction (you can enhance this with a metadata plugin)
      final parts = nameWithoutExtension.split(' - ');
      final artist = parts.length > 1 ? parts[0] : 'Unknown Artist';
      final title = parts.length > 1 ? parts[1] : nameWithoutExtension;

      return AudioEntity(
        id: file.path.hashCode.toString(),
        title: title,
        artist: artist,
        filePath: file.path,
        duration: Duration.zero, // Would need metadata plugin for actual duration
        type: AudioType.local,
        album: 'Unknown Album',
        genre: 'Unknown',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<AudioEntity>>> searchOnlineMusic(String query) async {
    try {
      // Simulate online search - integrate with your preferred music API
      await Future.delayed(const Duration(seconds: 1));

      final mockResults = [
        AudioEntity(
          id: 'online_1',
          title: 'Sample Song 1',
          artist: 'Sample Artist',
          filePath: 'https://example.com/song1.mp3',
          duration: const Duration(minutes: 3, seconds: 30),
          type: AudioType.online,
          albumArt: 'https://example.com/album1.jpg',
        ),
        AudioEntity(
          id: 'online_2',
          title: 'Sample Song 2',
          artist: 'Another Artist',
          filePath: 'https://example.com/song2.mp3',
          duration: const Duration(minutes: 4, seconds: 15),
          type: AudioType.online,
          albumArt: 'https://example.com/album2.jpg',
        ),
      ];

      return Right(mockResults);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AudioEntity>>> getTrendingMusic() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final trending = [
        AudioEntity(
          id: 'trending_1',
          title: 'Trending Hit 1',
          artist: 'Popular Artist',
          filePath: 'https://example.com/trending1.mp3',
          duration: const Duration(minutes: 3, seconds: 45),
          type: AudioType.online,
          albumArt: 'https://example.com/trending1.jpg',
        ),
        AudioEntity(
          id: 'trending_2',
          title: 'Viral Song 2',
          artist: 'Chart Topper',
          filePath: 'https://example.com/trending2.mp3',
          duration: const Duration(minutes: 3, seconds: 20),
          type: AudioType.online,
          albumArt: 'https://example.com/trending2.jpg',
        ),
      ];

      return Right(trending);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AudioEntity>>> getRecommendations() async {
    try {
      // Simulate AI recommendations based on listening history
      await Future.delayed(const Duration(milliseconds: 300));

      final recommendations = _recentlyPlayed.take(5).toList();
      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RadioStationEntity>>> getRadioStations() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final stations = [
        const RadioStationEntity(
          id: 'radio_1',
          name: 'Radio Mirchi',
          streamUrl: 'https://radiomirchi.com/stream',
          category: 'Bollywood',
          language: 'Hindi',
          country: 'India',
          imageUrl: 'https://example.com/mirchi.jpg',
          description: 'Bollywood hits and entertainment',
        ),
        const RadioStationEntity(
          id: 'radio_2',
          name: 'BBC Radio 1',
          streamUrl: 'https://bbc.co.uk/radio1/stream',
          category: 'Pop',
          language: 'English',
          country: 'UK',
          imageUrl: 'https://example.com/bbc.jpg',
          description: 'Latest pop and chart music',
        ),
      ];

      return Right(stations);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RadioStationEntity>>> getRadioStationsByCategory(String category) async {
    try {
      final allStations = await getRadioStations();
      return allStations.fold(
            (failure) => Left(failure),
            (stations) => Right(stations.where((s) => s.category == category).toList()),
      );
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlaylistEntity>>> getPlaylists() async {
    try {
      return Right(_playlists);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaylistEntity>> createPlaylist(String name, String? description) async {
    try {
      final playlist = PlaylistEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        songs: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _playlists.add(playlist);
      return Right(playlist);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToPlaylist(String playlistId, String audioId) async {
    try {
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        return const Left(CacheFailure('Playlist not found'));
      }

      final audio = _findAudioById(audioId);
      if (audio == null) {
        return const Left(CacheFailure('Audio not found'));
      }

      final playlist = _playlists[playlistIndex];
      final updatedSongs = List<AudioEntity>.from(playlist.songs)..add(audio);

      _playlists[playlistIndex] = playlist.copyWith(
        songs: updatedSongs,
        updatedAt: DateTime.now(),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromPlaylist(String playlistId, String audioId) async {
    try {
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex == -1) {
        return const Left(CacheFailure('Playlist not found'));
      }

      final playlist = _playlists[playlistIndex];
      final updatedSongs = playlist.songs.where((s) => s.id != audioId).toList();

      _playlists[playlistIndex] = playlist.copyWith(
        songs: updatedSongs,
        updatedAt: DateTime.now(),
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String playlistId) async {
    try {
      _playlists.removeWhere((p) => p.id == playlistId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AudioEntity>>> getFavorites() async {
    try {
      return Right(_favorites);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String audioId) async {
    try {
      final audio = _findAudioById(audioId);
      if (audio == null) {
        return const Left(CacheFailure('Audio not found'));
      }

      if (!_favorites.any((f) => f.id == audioId)) {
        _favorites.add(audio.copyWith(isFavorite: true));
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String audioId) async {
    try {
      _favorites.removeWhere((f) => f.id == audioId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AudioEntity>>> getRecentlyPlayed() async {
    try {
      return Right(_recentlyPlayed.reversed.take(20).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToRecentlyPlayed(String audioId) async {
    try {
      final audio = _findAudioById(audioId);
      if (audio == null) {
        return const Left(CacheFailure('Audio not found'));
      }

      // Remove if already exists
      _recentlyPlayed.removeWhere((r) => r.id == audioId);

      // Add to beginning
      _recentlyPlayed.insert(0, audio);

      // Keep only last 50
      if (_recentlyPlayed.length > 50) {
        _recentlyPlayed.removeRange(50, _recentlyPlayed.length);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  AudioEntity? _findAudioById(String audioId) {
    // First check online search results
    final searchResults = _localMusic.where((a) => a.id == audioId);
    if (searchResults.isNotEmpty) return searchResults.first;

    // Then check trending music
    final trendingResults = _localMusic.where((a) => a.id == audioId);
    if (trendingResults.isNotEmpty) return trendingResults.first;

    // Then check recommendations
    final recommendationResults = _localMusic.where((a) => a.id == audioId);
    if (recommendationResults.isNotEmpty) return recommendationResults.first;

    // Finally check local music
    for (final audio in _localMusic) {
      if (audio.id == audioId) return audio;
    }

    // Search in favorites
    for (final audio in _favorites) {
      if (audio.id == audioId) return audio;
    }

    // Search in recently played
    for (final audio in _recentlyPlayed) {
      if (audio.id == audioId) return audio;
    }

    return null;
  }
}
