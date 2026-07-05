import 'package:flutter/material.dart';

/// A reusable completed/verified badge with a starburst border and inner white core.
class CompletedBadge extends StatelessWidget {
  const CompletedBadge({
    super.key,
    this.width = 28.0,
    this.height = 27.0,
    this.coreSize = 13.0,
    this.iconColor = const Color(0xFF019C37),
    this.coreColor = Colors.white,
    this.isVerified = false,
  });

  final double width;
  final double height;
  final double coreSize;
  final Color iconColor;
  final Color coreColor;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = (isVerified && iconColor == const Color(0xFF019C37))
        ? const Color(0xFF1D9BF0)
        : iconColor;

    if (isVerified) {
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: coreSize,
              height: coreSize,
              decoration: BoxDecoration(
                color: coreColor,
                shape: BoxShape.circle,
              ),
            ),
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.fill,
                child: Icon(
                  Icons.verified,
                  color: effectiveColor,
                ),
              ),
            ),
            Positioned(
              child: Icon(
                Icons.done_all,
                color: Colors.white,
                size: coreSize - 1,
              ),
            ),
          ],
        ),
      );
    }
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
