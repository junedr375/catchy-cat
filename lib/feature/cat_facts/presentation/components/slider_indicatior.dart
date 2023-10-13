import 'package:flutter/material.dart';

enum SlideIndicatorActiveShape { circle, capsule }

class SlideIndicator extends StatelessWidget {
  const SlideIndicator({
    required this.totalCount,
    required this.selectedIndexColor,
    super.key,
    this.selectedIndex = 0,
    this.selectedIndexZoomed = false,
    this.inActiveColor,
    this.activeShape = SlideIndicatorActiveShape.capsule,
    this.activeSize = 8,
    this.inActiveSize = 5,
  });

  final int totalCount;
  final int selectedIndex;
  final bool selectedIndexZoomed;
  final Color selectedIndexColor;
  final Color? inActiveColor;
  final SlideIndicatorActiveShape activeShape;
  final double activeSize;
  final double inActiveSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<AnimatedContainer>.generate(
        totalCount,
        (index) {
          final isSelected = index == selectedIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: selectedIndexZoomed
                ? (isSelected ? activeSize : inActiveSize)
                : 8,
            width: getWidth(isSelected: isSelected),
            decoration: BoxDecoration(
              borderRadius: isSelected
                  ? BorderRadius.circular(8)
                  : BorderRadius.circular(10),
              color: isSelected
                  ? selectedIndexColor
                  : (inActiveColor ?? Colors.grey.shade300),
            ),
          );
        },
      ).toList(),
    );
  }

  double getWidth({required bool isSelected}) {
    if (isSelected) {
      switch (activeShape) {
        case SlideIndicatorActiveShape.circle:
          return activeSize;
        case SlideIndicatorActiveShape.capsule:
          return 24;
      }
    } else {
      if (selectedIndexZoomed) return inActiveSize;
      return 8;
    }
  }
}
