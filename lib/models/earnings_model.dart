/// Earnings Model for per-job and overall earnings data
class EarningsModel {
  final List<PerJobEarning> perJob;
  final OverallEarning overall;

  EarningsModel({
    required this.perJob,
    required this.overall,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      perJob: (json['per_job'] as List<dynamic>?)
              ?.map((item) => PerJobEarning.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
      overall: OverallEarning.fromJson(json['overall'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'per_job': perJob.map((item) => item.toJson()).toList(),
      'overall': overall.toJson(),
    };
  }
}

/// Per Job Earning Model
class PerJobEarning {
  final int jobId;
  final String jobTitle;
  final String fromDate;
  final String endDate;
  final double totalHours;
  final double totalEarning;

  PerJobEarning({
    required this.jobId,
    required this.jobTitle,
    required this.fromDate,
    required this.endDate,
    required this.totalHours,
    required this.totalEarning,
  });

  factory PerJobEarning.fromJson(Map<String, dynamic> json) {
    return PerJobEarning(
      jobId: json['job_id'] is int ? json['job_id'] : int.parse(json['job_id'].toString()),
      jobTitle: json['job_title']?.toString() ?? '',
      fromDate: json['from_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalHours: json['total_hours'] is double 
          ? json['total_hours'] 
          : (json['total_hours'] is int 
              ? (json['total_hours'] as int).toDouble() 
              : double.tryParse(json['total_hours'].toString()) ?? 0.0),
      totalEarning: json['total_earning'] is double 
          ? json['total_earning'] 
          : (json['total_earning'] is int 
              ? (json['total_earning'] as int).toDouble() 
              : double.tryParse(json['total_earning'].toString()) ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'job_title': jobTitle,
      'from_date': fromDate,
      'end_date': endDate,
      'total_hours': totalHours,
      'total_earning': totalEarning,
    };
  }

  /// Format date range string
  String get formattedDateRange {
    try {
      final from = DateTime.parse(fromDate);
      final end = DateTime.parse(endDate);
      
      if (from.year == end.year && from.month == end.month && from.day == end.day) {
        // Same day
        return '${from.day} ${_getMonthName(from.month)} ${from.year}';
      } else {
        // Date range
        return '${from.day} ${_getMonthName(from.month)} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
      }
    } catch (e) {
      return '$fromDate - $endDate';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

/// Overall Earning Model
class OverallEarning {
  final double totalHours;
  final double totalEarning;

  OverallEarning({
    required this.totalHours,
    required this.totalEarning,
  });

  factory OverallEarning.fromJson(Map<String, dynamic> json) {
    return OverallEarning(
      totalHours: json['total_hours'] is double 
          ? json['total_hours'] 
          : (json['total_hours'] is int 
              ? (json['total_hours'] as int).toDouble() 
              : double.tryParse(json['total_hours'].toString()) ?? 0.0),
      totalEarning: json['total_earning'] is double 
          ? json['total_earning'] 
          : (json['total_earning'] is int 
              ? (json['total_earning'] as int).toDouble() 
              : double.tryParse(json['total_earning'].toString()) ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_hours': totalHours,
      'total_earning': totalEarning,
    };
  }
}
