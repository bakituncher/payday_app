/// Animated countdown timer widget - Premium Industry-Grade Design
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:payday/core/theme/app_theme.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final bool showSeconds;
  final TextStyle? textStyle;
  final Color? accentColor;
  final bool showLabels;
  final bool useCards;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    this.showSeconds = true,
    this.textStyle,
    this.accentColor,
    this.showLabels = true,
    this.useCards = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with TickerProviderStateMixin {
  late Timer _timer;
  late Duration _remaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_updateRemaining);
      }
    });

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateRemaining() {
    final now = DateTime.now();
    _remaining = widget.targetDate.difference(now);

    // Ensure we don't show negative time
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final textStyle = widget.textStyle ??
        theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        );

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: Colors.white.withOpacity(0.8),
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      fontSize: 10,
    );

    if (_remaining == Duration.zero) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: const Text(
                    '🎉',
                    style: TextStyle(fontSize: 56),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'It\'s Payday!',
                  style: textStyle?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Time to celebrate!',
                  style: labelStyle?.copyWith(
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (widget.useCards) {
      return _buildCardStyle(days, hours, minutes, seconds, textStyle, labelStyle);
    }

    return _buildInlineStyle(days, hours, minutes, seconds, textStyle, labelStyle);
  }

  Widget _buildInlineStyle(int days, int hours, int minutes, int seconds,
      TextStyle? textStyle, TextStyle? labelStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (days > 0) ...[
          _buildTimeUnit(
            value: days.toString().padLeft(2, '0'),
            label: 'DAYS',
            textStyle: textStyle,
            labelStyle: labelStyle,
          ),
          _buildDivider(textStyle),
        ],
        _buildTimeUnit(
          value: hours.toString().padLeft(2, '0'),
          label: 'HRS',
          textStyle: textStyle,
          labelStyle: labelStyle,
        ),
        _buildDivider(textStyle),
        _buildTimeUnit(
          value: minutes.toString().padLeft(2, '0'),
          label: 'MIN',
          textStyle: textStyle,
          labelStyle: labelStyle,
        ),
        if (widget.showSeconds) ...[
          _buildDivider(textStyle),
          _buildAnimatedSeconds(
            seconds.toString().padLeft(2, '0'),
            textStyle,
            labelStyle,
          ),
        ],
      ],
    );
  }

  Widget _buildCardStyle(int days, int hours, int minutes, int seconds,
      TextStyle? textStyle, TextStyle? labelStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (days > 0) ...[
          _buildTimeCard(days.toString().padLeft(2, '0'), 'DAYS', textStyle, labelStyle),
          const SizedBox(width: AppSpacing.sm),
        ],
        _buildTimeCard(hours.toString().padLeft(2, '0'), 'HRS', textStyle, labelStyle),
        const SizedBox(width: AppSpacing.sm),
        _buildTimeCard(minutes.toString().padLeft(2, '0'), 'MIN', textStyle, labelStyle),
        if (widget.showSeconds) ...[
          const SizedBox(width: AppSpacing.sm),
          _buildTimeCard(seconds.toString().padLeft(2, '0'), 'SEC', textStyle, labelStyle),
        ],
      ],
    );
  }

  Widget _buildTimeCard(String value, String label, TextStyle? textStyle, TextStyle? labelStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: textStyle?.copyWith(fontSize: 32),
          ),
          if (widget.showLabels) ...[
            const SizedBox(height: 2),
            Text(label, style: labelStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeUnit({
    required String value,
    required String label,
    TextStyle? textStyle,
    TextStyle? labelStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: textStyle),
        if (widget.showLabels) ...[
          const SizedBox(height: 4),
          Text(label, style: labelStyle),
        ],
      ],
    );
  }

  Widget _buildAnimatedSeconds(String value, TextStyle? textStyle, TextStyle? labelStyle) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Column(
        key: ValueKey<String>(value),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: textStyle),
          if (widget.showLabels) ...[
            const SizedBox(height: 4),
            Text('SEC', style: labelStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider(TextStyle? textStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        ':',
        style: textStyle?.copyWith(
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

/// Circular countdown progress indicator
class CircularCountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final double size;
  final Color? progressColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final Widget? child;

  const CircularCountdownTimer({
    super.key,
    required this.targetDate,
    this.size = 200,
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  State<CircularCountdownTimer> createState() => _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<CircularCountdownTimer>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _controller;
  double _progress = 0;
  final DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _updateProgress();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateProgress();
    });
  }

  void _updateProgress() {
    final totalDuration = widget.targetDate.difference(_startDate);
    final elapsed = DateTime.now().difference(_startDate);
    final newProgress = (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);

    setState(() {
      _progress = newProgress;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CircleProgressPainter(
              progress: 1.0,
              color: widget.backgroundColor ?? Colors.white.withOpacity(0.2),
              strokeWidth: widget.strokeWidth,
            ),
          ),
          // Progress circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: 1 - value,
                  color: widget.progressColor ?? AppColors.primaryPink,
                  strokeWidth: widget.strokeWidth,
                  hasGlow: true,
                ),
              );
            },
          ),
          // Child content
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasGlow;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (hasGlow) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

