import 'package:flutter/material.dart';
import '../../utils/screen_unit_util.dart';

/// Step Indicator Component
/// Shows progress through multi-step forms (1-4 steps)
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  String _getStepTitle(int step) {
    switch (step) {
      case 1:
        return 'Profile';
      case 2:
        return 'Compliance';
      case 3:
        return 'Availability';
      case 4:
        return 'Bank';
      case 5:
        return 'Tax';
      case 6:
        return 'Additional';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUnitUtil.getSpacing(24),
        vertical: ScreenUnitUtil.getSpacing(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(totalSteps, (index) {
            final step = index + 1;
            final isActive = step == currentStep;
            final isCompleted = step < currentStep;
            final circleSize = ScreenUnitUtil.getFontSize(isActive ? 38 : 30);
            final stepTitle = _getStepTitle(step);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: ScreenUnitUtil.getFontSize(isActive ? 22 : 20),
                              )
                            : Text(
                                '$step',
                                style: TextStyle(
                                  color: isActive
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: ScreenUnitUtil.getFontSize(isActive ? 16 : 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    if (isActive)
                      SizedBox(
                        width: circleSize + ScreenUnitUtil.getSpacing(12),
                        child: Text(
                          stepTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(10),
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                if (index < totalSteps - 1)
                  Container(
                    width: ScreenUnitUtil.getSpacing(18),
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: ScreenUnitUtil.getSpacing(4)),
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
