/// Attendance Model for punch in/out records
class AttendanceModel {
  final int id;
  final int jobId;
  final String jobTitle;
  final DateTime? punchInAt;
  final DateTime? punchOutAt;
  final double? punchInLat;
  final double? punchInLng;
  final double? punchOutLat;
  final double? punchOutLng;

  AttendanceModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    this.punchInAt,
    this.punchOutAt,
    this.punchInLat,
    this.punchInLng,
    this.punchOutLat,
    this.punchOutLng,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        final parsed = DateTime.parse(dateString);
        return parsed;
      } catch (_) {
        return null;
      }
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      jobId: json['job_id'] is int ? json['job_id'] : int.parse(json['job_id'].toString()),
      jobTitle: json['job_title']?.toString() ?? '',
      punchInAt: parseDateTime(json['punch_in_at']?.toString()),
      punchOutAt: parseDateTime(json['punch_out_at']?.toString()),
      punchInLat: parseDouble(json['punch_in_lat']),
      punchInLng: parseDouble(json['punch_in_lng']),
      punchOutLat: parseDouble(json['punch_out_lat']),
      punchOutLng: parseDouble(json['punch_out_lng']),
    );
  }

  /// Check if punch in date matches today
  bool get isPunchInToday {
    if (punchInAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final punchInDay = DateTime(punchInAt!.year, punchInAt!.month, punchInAt!.day);
    return punchInDay.isAtSameMomentAs(today);
  }

  /// Check if punch out date matches today
  bool get isPunchOutToday {
    if (punchOutAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final punchOutDay = DateTime(punchOutAt!.year, punchOutAt!.month, punchOutAt!.day);
    return punchOutDay.isAtSameMomentAs(today);
  }

  /// Check if job is completed today (has both punch in and punch out for today)
  bool get isCompletedToday {
    return isPunchInToday && isPunchOutToday;
  }

  /// Check if job is active today (punch in today but no punch out yet)
  bool get isActiveToday {
    return isPunchInToday && punchOutAt == null;
  }
}
