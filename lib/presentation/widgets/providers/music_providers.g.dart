// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredMusicHash() => r'60431a75b1668f73ff5a1eda6637a6b754527314';

/// See also [filteredMusic].
@ProviderFor(filteredMusic)
final filteredMusicProvider =
    AutoDisposeFutureProvider<List<AudioEntity>>.internal(
  filteredMusic,
  name: r'filteredMusicProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredMusicHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredMusicRef = AutoDisposeFutureProviderRef<List<AudioEntity>>;
String _$localMusicHash() => r'0a6f9dcd262e5e98fe19ee5791691c7f7b4864af';

/// See also [LocalMusic].
@ProviderFor(LocalMusic)
final localMusicProvider =
    AutoDisposeAsyncNotifierProvider<LocalMusic, List<AudioEntity>>.internal(
  LocalMusic.new,
  name: r'localMusicProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$localMusicHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocalMusic = AutoDisposeAsyncNotifier<List<AudioEntity>>;
String _$recentMusicHash() => r'216acb9723a26dbc74a59bf5f57f33f26d05c1f5';

/// See also [RecentMusic].
@ProviderFor(RecentMusic)
final recentMusicProvider =
    AutoDisposeAsyncNotifierProvider<RecentMusic, List<AudioEntity>>.internal(
  RecentMusic.new,
  name: r'recentMusicProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recentMusicHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecentMusic = AutoDisposeAsyncNotifier<List<AudioEntity>>;
String _$trendingMusicHash() => r'1fc2ede1358c9a760d866132b49e89a8288ff18f';

/// See also [TrendingMusic].
@ProviderFor(TrendingMusic)
final trendingMusicProvider =
    AutoDisposeAsyncNotifierProvider<TrendingMusic, List<AudioEntity>>.internal(
  TrendingMusic.new,
  name: r'trendingMusicProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendingMusicHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrendingMusic = AutoDisposeAsyncNotifier<List<AudioEntity>>;
String _$favoritesHash() => r'd4704654037d6ff3e90bd8ed64a80fe811fcb91f';

/// See also [Favorites].
@ProviderFor(Favorites)
final favoritesProvider =
    AutoDisposeAsyncNotifierProvider<Favorites, List<AudioEntity>>.internal(
  Favorites.new,
  name: r'favoritesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$favoritesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Favorites = AutoDisposeAsyncNotifier<List<AudioEntity>>;
String _$playlistsHash() => r'203fc70ad8b3f15107232bb865c0e806221d58c0';

/// See also [Playlists].
@ProviderFor(Playlists)
final playlistsProvider =
    AutoDisposeAsyncNotifierProvider<Playlists, List<PlaylistEntity>>.internal(
  Playlists.new,
  name: r'playlistsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$playlistsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Playlists = AutoDisposeAsyncNotifier<List<PlaylistEntity>>;
String _$radioStationsHash() => r'e6f199d61407ff6c1691a1ccf760d9a7428e418c';

/// See also [RadioStations].
@ProviderFor(RadioStations)
final radioStationsProvider = AutoDisposeAsyncNotifierProvider<RadioStations,
    List<RadioStationEntity>>.internal(
  RadioStations.new,
  name: r'radioStationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$radioStationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RadioStations = AutoDisposeAsyncNotifier<List<RadioStationEntity>>;
String _$searchResultsHash() => r'7682a957c21dcfdb2dcfff074639dde0ca1d5c65';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SearchResults
    extends BuildlessAutoDisposeAsyncNotifier<List<AudioEntity>> {
  late final String query;

  FutureOr<List<AudioEntity>> build(
    String query,
  );
}

/// See also [SearchResults].
@ProviderFor(SearchResults)
const searchResultsProvider = SearchResultsFamily();

/// See also [SearchResults].
class SearchResultsFamily extends Family<AsyncValue<List<AudioEntity>>> {
  /// See also [SearchResults].
  const SearchResultsFamily();

  /// See also [SearchResults].
  SearchResultsProvider call(
    String query,
  ) {
    return SearchResultsProvider(
      query,
    );
  }

  @override
  SearchResultsProvider getProviderOverride(
    covariant SearchResultsProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchResultsProvider';
}

/// See also [SearchResults].
class SearchResultsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    SearchResults, List<AudioEntity>> {
  /// See also [SearchResults].
  SearchResultsProvider(
    String query,
  ) : this._internal(
          () => SearchResults()..query = query,
          from: searchResultsProvider,
          name: r'searchResultsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchResultsHash,
          dependencies: SearchResultsFamily._dependencies,
          allTransitiveDependencies:
              SearchResultsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<AudioEntity>> runNotifierBuild(
    covariant SearchResults notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(SearchResults Function() create) {
    return ProviderOverride(
      origin: this,
      override: SearchResultsProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SearchResults, List<AudioEntity>>
      createElement() {
    return _SearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchResultsRef
    on AutoDisposeAsyncNotifierProviderRef<List<AudioEntity>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchResultsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SearchResults,
        List<AudioEntity>> with SearchResultsRef {
  _SearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as SearchResultsProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
