import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:git/presentation/pages/splash/splash_page.dart';
import 'package:git/presentation/widgets/providers/player_providers.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/music/music_card.dart';
import '../../widgets/music/player_mini_card.dart';
import '../../widgets/voice/voice_assistant_button.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
     final recentMusic = ref.watch(recentMusicProvider);
     final trendingMusic = ref.watch(trendingMusicProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildWelcomeSection(),
                      const SizedBox(height: 30),
                      _buildQuickActions(),
                      const SizedBox(height: 30),
                      _buildRecentlyPlayed(recentMusic),
                      const SizedBox(height: 30),
                      _buildTrending(trendingMusic),
                      const SizedBox(height: 100), // Space for mini player
                    ],
                  ),
                ),
              ),
              if (playerState.currentAudio != null)
                const PlayerMiniCard()
                    .animate()
                    .slideY(begin: 1, duration: 300.ms)
                    .fadeIn(),
            ],
          ),
        ),
      ),
      floatingActionButton: const VoiceAssistantButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 24,
            ),
          ).animate().fadeIn().slideX(begin: -0.3),
          Text(
            'NexGen Music',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().scale(),
          GlassContainer(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 24,
            ),
          ).animate().fadeIn().slideX(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ).animate().fadeIn().slideY(begin: 0.3),
        const SizedBox(height: 8),
        Text(
          'What would you like to listen to?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().slideY(begin: 0.3, delay: 100.ms),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.music_note_rounded, 'label': 'My Music', 'color': AppColors.accent},
      {'icon': Icons.radio_rounded, 'label': 'Radio', 'color': AppColors.secondaryStart},
      {'icon': Icons.favorite_rounded, 'label': 'Favorites', 'color': AppColors.error},
      {'icon': Icons.playlist_play_rounded, 'label': 'Playlists', 'color': AppColors.success},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;

            return GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(delay: (index * 100).ms);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayed(AsyncValue<List<dynamic>> recentMusic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recentMusic.when(
          data: (music) => SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: music.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 16,
                    right: index == music.length - 1 ? 20 : 0,
                  ),
                  child: MusicCard(
                    audio: music[index],
                    onTap: () => _playMusic(music[index]),
                  ).animate().fadeIn().slideX(
                    begin: 0.3,
                    delay: (index * 100).ms,
                  ),
                );
              },
            ),
          ),
          loading: () => _buildMusicLoadingSkeleton(),
          error: (error, stack) => _buildErrorWidget(error.toString()),
        ),
      ],
    );
  }

  Widget _buildTrending(AsyncValue<List<dynamic>> trendingMusic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trending Now',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        trendingMusic.when(
          data: (music) => SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: music.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 16,
                    right: index == music.length - 1 ? 20 : 0,
                  ),
                  child: MusicCard(
                    audio: music[index],
                    onTap: () => _playMusic(music[index]),
                  ).animate().fadeIn().slideX(
                    begin: 0.3,
                    delay: (index * 100).ms,
                  ),
                );
              },
            ),
          ),
          loading: () => _buildMusicLoadingSkeleton(),
          error: (error, stack) => _buildErrorWidget(error.toString()),
        ),
      ],
    );
  }

  Widget _buildMusicLoadingSkeleton() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: GlassContainer(
              child: Column(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _playMusic(dynamic audio) {
    // TODO: Implement play music logic
    ref.read(playerControllerProvider.notifier).playAudio(audio);
  }
}