/// Custom Payday branded button - Premium Industry-Grade Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payday/core/theme/app_theme.dart';

enum PaydayButtonStyle { primary, secondary, outlined, ghost }
enum PaydayButtonSize { small, medium, large }

class PaydayButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PaydayButtonStyle style;
  final PaydayButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final Gradient? gradient;
  final bool enableHaptics;

  const PaydayButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = PaydayButtonStyle.primary,
    this.size = PaydayButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.gradient,
    this.enableHaptics = true,
  });

  // Legacy constructor for backward compatibility
  const PaydayButton.legacy({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    bool isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    double height = 56.0,
    double borderRadius = 20.0,
    this.gradient,
    this.enableHaptics = true,
  }) : style = isOutlined ? PaydayButtonStyle.outlined : PaydayButtonStyle.primary,
       size = PaydayButtonSize.medium,
       trailingIcon = null;

  @override
  State<PaydayButton> createState() => _PaydayButtonState();
}

class _PaydayButtonState extends State<PaydayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case PaydayButtonSize.small:
        return 40.0;
      case PaydayButtonSize.medium:
        return 52.0;
      case PaydayButtonSize.large:
        return 60.0;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case PaydayButtonSize.small:
        return 13.0;
      case PaydayButtonSize.medium:
        return 15.0;
      case PaydayButtonSize.large:
        return 17.0;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case PaydayButtonSize.small:
        return 16.0;
      case PaydayButtonSize.medium:
        return 20.0;
      case PaydayButtonSize.large:
        return 22.0;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case PaydayButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case PaydayButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case PaydayButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    switch (widget.style) {
      case PaydayButtonStyle.primary:
      case PaydayButtonStyle.secondary:
        return AppColors.primaryPink;
      case PaydayButtonStyle.outlined:
      case PaydayButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    if (widget.textColor != null) return widget.textColor!;
    switch (widget.style) {
      case PaydayButtonStyle.primary:
      case PaydayButtonStyle.secondary:
        return Colors.white;
      case PaydayButtonStyle.outlined:
      case PaydayButtonStyle.ghost:
        return AppColors.primaryPink;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = widget.style == PaydayButtonStyle.primary;
    final bool useGradient = isPrimary && widget.gradient == null;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: _height,
              decoration: BoxDecoration(
                color: useGradient ? null : _backgroundColor,
                gradient: widget.gradient ?? (useGradient ? AppColors.pinkGradient : null),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: widget.style == PaydayButtonStyle.outlined
                    ? Border.all(color: AppColors.primaryPink, width: 2)
                    : null,
                boxShadow: isPrimary && !widget.isLoading && widget.onPressed != null
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPink.withOpacity(_isPressed ? 0.2 : 0.35),
                          blurRadius: _isPressed ? 8 : 16,
                          offset: Offset(0, _isPressed ? 2 : 6),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: _padding,
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
          ),
        ),
      );
    }

    final List<Widget> children = [];

    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: _iconSize, color: _foregroundColor));
      children.add(const SizedBox(width: AppSpacing.sm));
    }

    children.add(
      Text(
        widget.text,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: _foregroundColor,
          letterSpacing: 0.3,
        ),
      ),
    );

    if (widget.trailingIcon != null) {
      children.add(const SizedBox(width: AppSpacing.sm));
      children.add(Icon(widget.trailingIcon, size: _iconSize, color: _foregroundColor));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Icon-only button with premium styling
class PaydayIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool hasShadow;

  const PaydayIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.hasShadow = false,
  });

  @override
  State<PaydayIconButton> createState() => _PaydayIconButtonState();
}

class _PaydayIconButtonState extends State<PaydayIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (widget.onPressed != null) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.subtleGray,
          borderRadius: BorderRadius.circular(widget.size / 3),
          boxShadow: widget.hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        transform: _isPressed ? Matrix4.diagonal3Values(0.95, 0.95, 1) : Matrix4.identity(),
        child: Center(
          child: Icon(
            widget.icon,
            color: widget.iconColor ?? AppColors.darkCharcoal,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}

