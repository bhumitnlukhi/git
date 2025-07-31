// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:git/data/repositories/audio_repository_impl.dart' as _i127;
import 'package:git/data/services/player_service_impl.dart' as _i112;
import 'package:git/data/services/voice_service_impl.dart' as _i113;
import 'package:git/domain/repositories/audio_repository.dart' as _i1014;
import 'package:git/domain/services/voice_service.dart' as _i304;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i304.VoiceService>(() => _i113.VoiceServiceImpl());
    gh.lazySingleton<_i1014.AudioRepository>(() => _i127.AudioRepositoryImpl());
    gh.lazySingleton<_i1014.PlayerRepository>(() => _i112.PlayerServiceImpl());
    return this;
  }
}
