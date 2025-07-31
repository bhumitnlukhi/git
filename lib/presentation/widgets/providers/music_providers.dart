import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/audio_entity.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../core/di/injection.dart';

part 'music_providers.g.dart';

// Audio Repository Provider
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return getIt<AudioRepository>();
});

// Player Repository Provider
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return getIt<PlayerRepository>();
});

// Local Music Provider
@riverpod
class LocalMusic extends _$LocalMusic {
  @override
  Future<List<AudioEntity>> build() async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getLocalMusic();

    return result.fold(
          (failure) => throw Exception(failure.message),
          (music) => music,
    );
  }

  Future<void> scanDevice() async {
    state = const AsyncValue.loading();
    final repository = ref.read(audioRepositoryProvider);

    final result = await repository.scanDeviceForMusic();
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) => ref.invalidateSelf(),
    );
  }
}

// Recent Music Provider
@riverpod
class RecentMusic extends _$RecentMusic {
  @override
  Future<List<AudioEntity>> build() async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getRecentlyPlayed();

    return result.fold(
          (failure) => throw Exception(failure.message),
          (music) => music,
    );
  }

  Future<void> addToRecent(String audioId) async {
    final repository = ref.read(audioRepositoryProvider);
    await repository.addToRecentlyPlayed(audioId);
    ref.invalidateSelf();
  }
}

// Trending Music Provider
@riverpod
class TrendingMusic extends _$TrendingMusic {
  @override
  Future<List<AudioEntity>> build() async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getTrendingMusic();

    return result.fold(
          (failure) => throw Exception(failure.message),
          (music) => music,
    );
  }
}

// Favorites Provider
@riverpod
class Favorites extends _$Favorites {
  @override
  Future<List<AudioEntity>> build() async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getFavorites();

    return result.fold(
          (failure) => throw Exception(failure.message),
          (favorites) => favorites,
    );
  }

  Future<void> addToFavorites(String audioId) async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.addToFavorites(audioId);

    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => ref.invalidateSelf(),
    );
  }

  Future<void> removeFromFavorites(String audioId) async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.removeFromFavorites(audioId);

    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => ref.invalidateSelf(),
    );
  }
}

// Playlists Provider
@riverpod
class Playlists extends _$Playlists {
  @override
  Future<List<PlaylistEntity>> build() async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getPlaylists();

    return result.fold(
          (failure) => throw Exception(failure.message),
          (playlists) => playlists,
    );
  }

  Future<void> createPlaylist(String name, String? description) async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.createPlaylist(name, description);

    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => ref.invalidateSelf(),
    );
  }

  Future<void> deletePlaylist(String playlistId) async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.deletePlaylist(playlistId);

    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => ref.invalidateSelf(),
    );
  }

  Future<void> addToPlaylist(String playlistId, String audioId) async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.addToPlaylist(playlistId, audioId);

    result.fold(
          (failure) => throw Exception(failure.message),
          (_) => ref.invalidateSelf(),
    );
  }
}

// Radio Stations Provider
@riverpod
class RadioStations extends _$RadioStations {
  @override
  Future<List<RadioStationEntity>> build() async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getRadioStations();

    return result.fold(
          (failure) => throw Exception(failure.message),
          (stations) => stations,
    );
  }

  Future<List<RadioStationEntity>> getByCategory(String category) async {
    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.getRadioStationsByCategory(category);

    return result.fold(
          (failure) => throw Exception(failure.message),
          (stations) => stations,
    );
  }
}

// Search Provider
@riverpod
class SearchResults extends _$SearchResults {
  @override
  Future<List<AudioEntity>> build(String query) async {
    if (query.isEmpty) return [];

    final repository = ref.read(audioRepositoryProvider);
    final result = await repository.searchOnlineMusic(query);

    return result.fold(
          (failure) => throw Exception(failure.message),
          (results) => results,
    );
  }
}

// Music Categories Provider
final musicCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'All',
    'Pop',
    'Rock',
    'Hip Hop',
    'Jazz',
    'Classical',
    'Electronic',
    'Country',
    'R&B',
    'Reggae',
  ];
});

// Current Category Provider
final currentCategoryProvider = StateProvider<String>((ref) => 'All');

// Filtered Music Provider
@riverpod
Future<List<AudioEntity>> filteredMusic(FilteredMusicRef ref) async {
  final category = ref.watch(currentCategoryProvider);
  final localMusic = await ref.watch(localMusicProvider.future);

  if (category == 'All') {
    return localMusic;
  }

  return localMusic.where((audio) =>
  audio.genre?.toLowerCase() == category.toLowerCase()
  ).toList();
}
