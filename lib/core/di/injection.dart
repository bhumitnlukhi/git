import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:git/data/services/player_service_impl.dart';
import 'package:git/data/services/voice_service_impl.dart';
import 'package:git/data/repositories/audio_repository_impl.dart';
import 'package:git/domain/repositories/audio_repository.dart';
import 'package:git/domain/services/voice_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

void init() {
  // Register repositories
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  getIt.registerLazySingleton<PlayerRepository>(() => PlayerServiceImpl());

  // Register services
  getIt.registerLazySingleton<VoiceService>(() => VoiceServiceImpl());
}