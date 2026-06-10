import 'package:flutter/material.dart';

/// A reusable completed/verified badge with a starburst border and inner white core.
class CompletedBadge extends StatelessWidget {
  const CompletedBadge({
    super.key,
    this.width = 28.0,
    this.height = 27.0,
    this.coreSize = 13.0,
    this.iconColor = const Color(0xFFF56064),
    this.coreColor = Colors.white,
  });

  final double width;
  final double height;
  final double coreSize;
  final Color iconColor;
  final Color coreColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Small core circle that fills the transparent checkmark cutout from behind
          Container(
            width: coreSize,
            height: coreSize,
            decoration: BoxDecoration(
              color: coreColor,
              shape: BoxShape.circle,
            ),
          ),
          // Verified icon overlay
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.fill,
              child: Icon(
                Icons.verified,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
