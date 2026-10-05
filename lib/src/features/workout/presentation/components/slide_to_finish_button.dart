import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:customer_mobile_app/core/themes/app_colors.dart';

/// An interactive slide-to-confirm button for finishing a workout session or saving.
class SlideToFinishButton extends StatefulWidget {
  const SlideToFinishButton({
    required this.onSlideComplete,
    super.key,
    this.text = 'Slide to finish',
    this.isLoading = false,
    this.height = 54.0,
    this.buttonColor,
    this.trackColor,
    this.textColor,
    this.icon,
  });

  /// Callback fired when the slider reaches the completion threshold.
  final FutureOr<void> Function() onSlideComplete;

  /// The label displayed in the center of the track.
  final String text;

  /// Whether the action is currently processing.
  final bool isLoading;

  /// Height of the slider bar.
  final double height;

  /// Color of the draggable thumb button. Defaults to [AppColors.primary].
  final Color? buttonColor;

  /// Background color of the slider track. Defaults to a subtle light gray.
  final Color? trackColor;

  /// Color of the center label text. Defaults to dark gray.
  final Color? textColor;

  /// Custom icon inside the draggable thumb button. Defaults to double chevron.
  final Widget? icon;

  @override
  State<SlideToFinishButton> createState() => _SlideToFinishButtonState();
}

class _SlideToFinishButtonState extends State<SlideToFinishButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _resetAnimation;

  double _dragProgress = 0; // 0 to 1
  bool _isTriggering = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_resetAnimation != null) {
          setState(() {
            _dragProgress = _resetAnimation!.value;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant SlideToFinishButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading && _dragProgress > 0) {
      _snapBack();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _snapBack() {
    _resetAnimation = Tween<double>(begin: _dragProgress, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    unawaited(
      _animController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _dragProgress = 0;
            _isTriggering = false;
          });
        }
      }),
    );
  }

  Future<void> _handleComplete() async {
    if (_isTriggering) return;
    _isTriggering = true;
    await HapticFeedback.mediumImpact();

    // Snap to full completion first
    _resetAnimation = Tween<double>(begin: _dragProgress, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    await _animController.forward(from: 0);

    try {
      await widget.onSlideComplete();
    } finally {
      if (mounted) {
        _snapBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveButtonColor = widget.buttonColor ?? AppColors.primary;
    final effectiveTrackColor =
        widget.trackColor ?? const Color(0xFFF5F5F7);
    final effectiveTextColor =
        widget.textColor ?? const Color(0xFF424242);

    final trackHeight = widget.height;
    const padding = 4.0;
    final thumbSize = trackHeight - (padding * 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxDragDistance = trackWidth - thumbSize - (padding * 2);

        final thumbLeft = padding + (_dragProgress * maxDragDistance);
        final fillWidth = thumbLeft + (thumbSize / 2);
        final textOpacity = (1.0 - (_dragProgress * 2.2)).clamp(0, 1).toDouble();

        return Container(
          width: trackWidth,
          height: trackHeight,
          decoration: BoxDecoration(
            color: effectiveTrackColor,
            borderRadius: BorderRadius.circular(trackHeight / 2),
            border: Border.all(
              color: effectiveButtonColor.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Filled progress track behind thumb
              if (fillWidth > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: fillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: effectiveButtonColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(trackHeight / 2),
                        right: Radius.circular(
                          _dragProgress >= 0.95 ? trackHeight / 2 : 0,
                        ),
                      ),
                    ),
                  ),
                ),

              // Center label text with fading chevrons
              Positioned.fill(
                child: Opacity(
                  opacity: textOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: effectiveTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        size: 20,
                        color: effectiveButtonColor.withValues(alpha: 0.65),
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable thumb button
              Positioned(
                left: thumbLeft,
                top: padding,
                bottom: padding,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    if (widget.isLoading || _isTriggering) return;
                    _animController.stop();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (widget.isLoading || _isTriggering) return;
                    if (maxDragDistance <= 0) return;

                    final deltaProgress = details.delta.dx / maxDragDistance;
                    setState(() {
                      _dragProgress =
                          (_dragProgress + deltaProgress).clamp(0, 1).toDouble();
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (widget.isLoading || _isTriggering) return;

                    if (_dragProgress >= 0.80) {
                      _handleComplete();
                    } else {
                      HapticFeedback.selectionClick();
                      _snapBack();
                    }
                  },
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: effectiveButtonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: effectiveButtonColor.withValues(alpha: 0.38),
                          blurRadius: 8,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : widget.icon ??
                              const Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
