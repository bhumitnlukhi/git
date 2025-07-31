import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../common/glass_container.dart';
import '../../providers/voice_providers.dart';

class VoiceAssistantButton extends ConsumerStatefulWidget {
  const VoiceAssistantButton({super.key});

  @override
  ConsumerState<VoiceAssistantButton> createState() => _VoiceAssistantButtonState();
}

class _VoiceAssistantButtonState extends ConsumerState<VoiceAssistantButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _startListening() {
    ref.read(voiceControllerProvider.notifier).startListening();
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
  }

  void _stopListening() {
    ref.read(voiceControllerProvider.notifier).stopListening();
    _pulseController.stop();
    _rippleController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceControllerProvider);

    ref.listen<AsyncValue<bool>>(voiceControllerProvider.select((state) =>
        AsyncValue.data(state.maybeWhen(data: (data) => data.isListening, orElse: () => false))),
          (previous, next) {
        next.whenData((isListening) {
          if (isListening) {
            _pulseController.repeat(reverse: true);
            _rippleController.repeat();
          } else {
            _pulseController.stop();
            _rippleController.reset();
          }
        });
      },
    );

    return voiceState.when(
      data: (state) => _buildVoiceButton(state.isListening, state.lastCommand),
      loading: () => _buildLoadingButton(),
      error: (error, stack) => _buildErrorButton(),
    );
  }

  Widget _buildVoiceButton(bool isListening, String? lastCommand) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ripple effect when listening
        if (isListening)
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                width: 80 + (_rippleAnimation.value * 40),
                height: 80 + (_rippleAnimation.value * 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3 - (_rippleAnimation.value * 0.3)),
                    width: 2,
                  ),
                ),
              );
            },
          ),

        // Main button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isListening ? _pulseAnimation.value : 1.0,
              child: GestureDetector(
                onTap: isListening ? _stopListening : _startListening,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isListening
                        ? LinearGradient(
                      colors: [AppColors.error, AppColors.warning],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : AppGradients.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? AppColors.error : AppColors.accent).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ).animate().scale(delay: 500.ms);
  }

  Widget _buildLoadingButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorButton() {
    return GestureDetector(
      onTap: () => ref.read(voiceControllerProvider.notifier).initialize(),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.refresh_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class VoiceCommandDisplay extends ConsumerWidget {
  const VoiceCommandDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceControllerProvider);

    return voiceState.when(
      data: (state) {
        if (state.lastCommand != null && state.lastCommand!.isNotEmpty) {
          return Positioned(
            bottom: 140,
            right: 20,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.record_voice_over_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.lastCommand!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.5),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class VoiceWaveAnimation extends StatefulWidget {
  final bool isActive;
  final Color color;
  final double height;

  const VoiceWaveAnimation({
    super.key,
    required this.isActive,
    this.color = Colors.white,
    this.height = 40,
  });

  @override
  State<VoiceWaveAnimation> createState() => _VoiceWaveAnimationState();
}

class _VoiceWaveAnimationState extends State<VoiceWaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
          (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(VoiceWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        for (var controller in _controllers) {
          controller.repeat(reverse: true);
        }
      } else {
        for (var controller in _controllers) {
          controller.stop();
          controller.reset();
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _animations.asMap().entries.map((entry) {
        final index = entry.key;
        final animation = entry.value;

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 3,
              height: widget.height * animation.value,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}