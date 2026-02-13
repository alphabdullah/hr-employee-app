import 'package:intl/intl.dart';

/// Weekly earnings payload returned by `/api/me/weekly-earnings`
class WeeklyEarningsModel {
  final DateTime weekStart;
  final DateTime weekEnd;
  final String weekLabel;
  final double totalHours;
  final double totalEarning;
  final double perHourRate;
  final double effectivePerHour;
  final int jobsCount;
  final List<String> jobTitles;

  WeeklyEarningsModel({
    required this.weekStart,
    required this.weekEnd,
    required this.weekLabel,
    required this.totalHours,
    required this.totalEarning,
    required this.perHourRate,
    required this.effectivePerHour,
    required this.jobsCount,
    required this.jobTitles,
  });

  factory WeeklyEarningsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyEarningsModel(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      weekLabel: json['week_label']?.toString() ?? '',
      totalHours: _toDouble(json['total_hours']),
      totalEarning: _toDouble(json['total_earning']),
      perHourRate: _toDouble(json['per_hour_rate']),
      effectivePerHour: _toDouble(json['effective_per_hour']),
      jobsCount: json['jobs_count'] is int
          ? json['jobs_count'] as int
          : int.tryParse(json['jobs_count'].toString()) ?? 0,
      jobTitles: (json['job_titles'] as List<dynamic>?)
              ?.map((title) => title?.toString() ?? '')
              .where((title) => title.isNotEmpty)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week_start': DateFormat('yyyy-MM-dd').format(weekStart),
      'week_end': DateFormat('yyyy-MM-dd').format(weekEnd),
      'week_label': weekLabel,
      'total_hours': totalHours,
      'total_earning': totalEarning,
      'per_hour_rate': perHourRate,
      'effective_per_hour': effectivePerHour,
      'jobs_count': jobsCount,
      'job_titles': jobTitles,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
