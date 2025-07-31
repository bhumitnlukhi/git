import 'package:equatable/equatable.dart';

class AudioEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArt;
  final String filePath;
  final Duration duration;
  final AudioType type;
  final String? genre;
  final int? year;
  final bool isFavorite;

  const AudioEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArt,
    required this.filePath,
    required this.duration,
    required this.type,
    this.genre,
    this.year,
    this.isFavorite = false,
  });

  AudioEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    String? filePath,
    Duration? duration,
    AudioType? type,
    String? genre,
    int? year,
    bool? isFavorite,
  }) {
    return AudioEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    artist,
    album,
    albumArt,
    filePath,
    duration,
    type,
    genre,
    year,
    isFavorite,
  ];
}

enum AudioType {
  local,
  online,
  radio,
}

class RadioStationEntity extends Equatable {
  final String id;
  final String name;
  final String streamUrl;
  final String? imageUrl;
  final String category;
  final String language;
  final String country;
  final String? description;
  final bool isLive;

  const RadioStationEntity({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.imageUrl,
    required this.category,
    required this.language,
    required this.country,
    this.description,
    this.isLive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    streamUrl,
    imageUrl,
    category,
    language,
    country,
    description,
    isLive,
  ];
}

class PlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<AudioEntity> songs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.songs,
    required this.createdAt,
    required this.updatedAt,
  });

  PlaylistEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<AudioEntity>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    songs,
    createdAt,
    updatedAt,
  ];
}

enum PlayerState {
  idle,
  loading,
  ready,
  playing,
  paused,
  stopped,
  error,
}

enum RepeatMode {
  none,
  one,
  all,
}

class PlayerStateEntity extends Equatable {
  final PlayerState state;
  final AudioEntity? currentAudio;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final List<AudioEntity> queue;
  final int currentIndex;

  const PlayerStateEntity({
    required this.state,
    this.currentAudio,
    required this.position,
    required this.duration,
    required this.volume,
    required this.isShuffle,
    required this.repeatMode,
    required this.queue,
    required this.currentIndex,
  });

  PlayerStateEntity copyWith({
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
    return PlayerStateEntity(
      state: state ?? this.state,
      currentAudio: currentAudio ?? this.currentAudio,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [
    state,
    currentAudio,
    position,
    duration,
    volume,
    isShuffle,
    repeatMode,
    queue,
    currentIndex,
  ];
}