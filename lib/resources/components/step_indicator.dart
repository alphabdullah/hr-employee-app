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
        vertical: ScreenUnitUtil.getSpacing(16),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final step = index + 1;
              final isActive = step == currentStep;
              final isCompleted = step < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: ScreenUnitUtil.getFontSize(32),
                            height: ScreenUnitUtil.getFontSize(32),
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
                                      size: ScreenUnitUtil.getFontSize(20),
                                    )
                                  : Text(
                                      '$step',
                                      style: TextStyle(
                                        color: isActive
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontSize: ScreenUnitUtil.getFontSize(14),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                          Text(
                            _getStepTitle(step),
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(10),
                              color: isActive || isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (index < totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenUnitUtil.getSpacing(4),
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
          Text(
            'Step $currentStep of $totalSteps',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(12),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
