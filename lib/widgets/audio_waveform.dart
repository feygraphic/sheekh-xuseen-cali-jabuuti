import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AudioWaveformVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color activeColor;
  final Color inactiveColor;
  final int barCount;
  final double height;

  const AudioWaveformVisualizer({
    super.key,
    required this.isPlaying,
    this.activeColor = AppColors.primaryContainer,
    this.inactiveColor = AppColors.secondaryContainer,
    this.barCount = 24,
    this.height = 28,
  });

  @override
  State<AudioWaveformVisualizer> createState() => _AudioWaveformVisualizerState();
}

class _AudioWaveformVisualizerState extends State<AudioWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _randomFactors = [];
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.barCount; i++) {
      _randomFactors.add(0.3 + _random.nextDouble() * 0.7);
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AudioWaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            final factor = _randomFactors[index];
            final animValue = _controller.value;
            // Wave calculation
            final wave = (sin((index / widget.barCount) * 2 * pi + animValue * 2 * pi) + 1) / 2;
            final currentHeight = widget.isPlaying
                ? (8.0 + (widget.height - 8.0) * wave * factor).clamp(6.0, widget.height)
                : (6.0 + factor * 6.0);

            final isLeftHalf = index < (widget.barCount * 0.55);
            final barColor = isLeftHalf ? widget.activeColor : widget.inactiveColor.withOpacity(0.6);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: currentHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        );
      },
    );
  }
}
