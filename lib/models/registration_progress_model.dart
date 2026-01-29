/// Model for Registration Progress from Login Response
class RegistrationProgressModel {
  final bool step1;
  final bool step2;
  final bool step3;
  final bool step4;
  final int completedSteps;
  final int totalSteps;
  final int progressPercent;
  final int? nextStep; // null if all steps complete
  final String? nextStepLabel;
  final bool allStepsComplete;

  RegistrationProgressModel({
    required this.step1,
    required this.step2,
    required this.step3,
    required this.step4,
    required this.completedSteps,
    required this.totalSteps,
    required this.progressPercent,
    this.nextStep,
    this.nextStepLabel,
    required this.allStepsComplete,
  });

  /// Create RegistrationProgressModel from JSON
  factory RegistrationProgressModel.fromJson(Map<String, dynamic> json) {
    return RegistrationProgressModel(
      step1: json['step_1'] ?? false,
      step2: json['step_2'] ?? false,
      step3: json['step_3'] ?? false,
      step4: json['step_4'] ?? false,
      completedSteps: json['completed_steps'] ?? 0,
      totalSteps: json['total_steps'] ?? 4,
      progressPercent: json['progress_percent'] ?? 0,
      nextStep: json['next_step'] as int?,
      nextStepLabel: json['next_step_label'] as String?,
      allStepsComplete: json['all_steps_complete'] ?? false,
    );
  }

  /// Create empty RegistrationProgressModel
  factory RegistrationProgressModel.empty() {
    return RegistrationProgressModel(
      step1: false,
      step2: false,
      step3: false,
      step4: false,
      completedSteps: 0,
      totalSteps: 4,
      progressPercent: 0,
      nextStep: null,
      nextStepLabel: null,
      allStepsComplete: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'step_1': step1,
      'step_2': step2,
      'step_3': step3,
      'step_4': step4,
      'completed_steps': completedSteps,
      'total_steps': totalSteps,
      'progress_percent': progressPercent,
      'next_step': nextStep,
      'next_step_label': nextStepLabel,
      'all_steps_complete': allStepsComplete,
    };
  }
}
