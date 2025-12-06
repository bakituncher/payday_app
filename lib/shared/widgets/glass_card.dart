/// Premium glass morphism card widget with industry-grade design
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:payday_flutter/core/theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final bool enableHover;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.xl,
    this.blur = 10.0,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.enableHover = true,
    this.gradient,
    this.boxShadow,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.boxShadow ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03 * _elevationAnimation.value),
                    blurRadius: 8 * _elevationAnimation.value,
                    offset: Offset(0, 2 * _elevationAnimation.value),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06 * _elevationAnimation.value),
                    blurRadius: 24 * _elevationAnimation.value,
                    offset: Offset(0, 8 * _elevationAnimation.value),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? AppColors.cardWhite.withOpacity(0.9),
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: widget.border ?? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Premium Card - Elevated card with shadows
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.cardWhite) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Gradient Card with glow effect
class GradientGlowCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  const GradientGlowCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.pinkGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}

