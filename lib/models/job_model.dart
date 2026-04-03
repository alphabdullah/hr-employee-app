/// Job Status enum
enum JobStatus {
  active,    // Active job for today
  assigned,  // Job assigned to user
  open,      // Open job from API
  closed,    // Closed job from API
  filled,    // Filled job from API
}

/// Model class for Job Post data
class JobModel {
  final String id;
  final String jobTitle;
  final String workType; // e.g., Plumber, Electrician, Catering, etc.
  final String jobDescription;
  final int numberOfWorkersRequired;
  final int numberOfWorkersFilled; // Number of workers already filled/assigned
  final String jobLocation; // city/area
  final DateTime jobDate; // Date when job is assigned/scheduled
  final JobStatus jobStatus; // active, assigned, pending, open, closed, filled
  final String? jobImageUrl;
  final String? jobDuration; // e.g., "10am to 6pm"
  final String? durationStartTime; // e.g., "09:00"
  final String? durationEndTime; // e.g., "21:00"
  final List<String>? requiredSkills; // Array of required skills
  final Map<String, dynamic>? createdBy; // Created by admin info
  final String? createdAt;
  final String? updatedAt;
  final double? perHourPay;
  final String? workMode; // fixed | per_hour
  // /api/me/jobs fields
  final DateTime? fromDate;
  final DateTime? endDate;
  final int? numberOfDays;
  final String? shiftType; // day | night
  final String? address;
  final String? postcode;
  final String? country;
  final String? region;
  final String? district;
  final String? city;
  final List<String>? jobDays;
  final List<DateTime>? jobDayDates;
  final List<JobDayTime>? jobDayTimes;

  JobModel({
    required this.id,
    required this.jobTitle,
    required this.workType,
    required this.jobDescription,
    required this.numberOfWorkersRequired,
    this.numberOfWorkersFilled = 0,
    required this.jobLocation,
    required this.jobDate,
    required this.jobStatus,
    this.jobImageUrl,
    this.jobDuration,
    this.durationStartTime,
    this.durationEndTime,
    this.requiredSkills,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.perHourPay,
    this.workMode,
    this.fromDate,
    this.endDate,
    this.numberOfDays,
    this.shiftType,
    this.address,
    this.postcode,
    this.country,
    this.region,
    this.district,
    this.city,
      this.jobDays,
      this.jobDayDates,
    this.jobDayTimes,
  });

  JobDayTime? getJobDayTimeFor(DateTime date) {
    if (jobDayTimes == null || jobDayTimes!.isEmpty) return null;
    final target = DateTime(date.year, date.month, date.day);
    for (final t in jobDayTimes!) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d.isAtSameMomentAs(target)) return t;
    }
    return null;
  }

  /// Create JobModel from API JSON response
  /// Expected format: { "id": 1, "job_title": "...", ... }
  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Map API status to JobStatus enum
    JobStatus status;
    final apiStatus = json['status']?.toString().toLowerCase() ?? '';
    switch (apiStatus) {
      case 'open':
        status = JobStatus.open;
        break;
      case 'closed':
        status = JobStatus.closed;
        break;
      case 'filled':
        status = JobStatus.filled;
        break;
      case 'assigned':
        status = JobStatus.assigned;
        break;
      default:
        // Default to 'open' if status is unknown (shouldn't happen with valid API responses)
        status = JobStatus.open;
    }

    // Parse job_date as provided by backend
    DateTime jobDate;
    if (json['job_date'] != null) {
      try {
        jobDate = DateTime.parse(json['job_date'].toString());
      } catch (e) {
        jobDate = DateTime.now();
      }
    } else {
      jobDate = DateTime.now();
    }

    // Handle job_image / image_url (e.g. /api/me/jobs returns image_url)
    final jobImage = json['job_image'] ?? json['image_url'];
    final String? jobImageUrl;
    if (jobImage == null || jobImage == 'null' || jobImage.toString().isEmpty) {
      jobImageUrl = null;
    } else {
      jobImageUrl = jobImage.toString();
    }

    // Handle created_by / client object (e.g. /api/me/jobs returns client)
    Map<String, dynamic>? createdBy;
    if (json['created_by'] != null && json['created_by'] is Map) {
      createdBy = Map<String, dynamic>.from(json['created_by']);
    } else if (json['client'] != null && json['client'] is Map) {
      createdBy = Map<String, dynamic>.from(json['client']);
    }

    // Handle required_skills array
    List<String>? requiredSkills;
    if (json['required_skills'] != null && json['required_skills'] is List) {
      requiredSkills = (json['required_skills'] as List)
          .map((skill) => skill.toString())
          .toList();
    }

    // Extract work type from job_title if work_type is not provided
    // Try to derive from job title (e.g., "Senior Flutter Developer" -> "Developer")
    String workType = json['work_type'] ?? '';
    
    if (workType.isEmpty) {
      final jobTitle = json['job_title']?.toString().toLowerCase() ?? '';
      if (jobTitle.contains('developer')) {
        workType = 'Developer';
      } else if (jobTitle.contains('designer')) {
        workType = 'Designer';
      } else if (jobTitle.contains('manager')) {
        workType = 'Manager';
      } else if (jobTitle.contains('engineer')) {
        workType = 'Engineer';
      } else {
        workType = 'General';
      }
    }

    // Keep time/date parsing as-is (no UTC/local conversion)
    String? convertTimeToLocal(String? timeString) => timeString;
    String? convertDateTimeToLocal(String? dateTimeString) => dateTimeString;
    
    // job_location / address (e.g. /api/me/jobs returns address, region, district)
    final rawLocation = json['job_location'] ?? json['address'];
    String jobLocation = rawLocation?.toString() ?? '';
    if (jobLocation.isEmpty && (json['region'] != null || json['district'] != null)) {
      final parts = <String>[];
      if (json['region'] != null && json['region'].toString().isNotEmpty) parts.add(json['region'].toString());
      if (json['district'] != null && json['district'].toString().isNotEmpty) parts.add(json['district'].toString());
      if (parts.isNotEmpty) jobLocation = parts.join(', ');
    }
    if (jobLocation.isEmpty && json['postcode'] != null && json['postcode'].toString().isNotEmpty) {
      jobLocation = json['postcode'].toString();
    }

    // number_of_workers_required / required_employees (e.g. /api/me/jobs)
    final rawRequired = json['number_of_workers_required'] ?? json['required_employees'];
    final numberOfWorkersRequired = _parseInt(rawRequired, 0);
    final numberOfWorkersFilled = _parseInt(
      json['number_of_selected_workers'] ?? json['number_of_workers_filled'],
      0,
    );

    // from_date / end_date / number_of_days / shift_type (e.g. /api/me/jobs)
    DateTime? fromDate;
    if (json['from_date'] != null) {
      try {
        fromDate = DateTime.parse(json['from_date'].toString());
      } catch (_) {}
    }
    DateTime? endDate;
    if (json['end_date'] != null) {
      try {
        endDate = DateTime.parse(json['end_date'].toString());
      } catch (_) {}
    }
    final numberOfDays = json['number_of_days'] != null ? _parseInt(json['number_of_days'], 0) : null;
    final shiftType = json['shift_type']?.toString();
    final address = json['address']?.toString();
    final postcode = json['postcode']?.toString();
    final country = json['country']?.toString();
    final region = json['region']?.toString();
    final district = json['district']?.toString();
    final city = json['city']?.toString();
    List<String>? jobDays;
    if (json['job_days'] != null && json['job_days'] is List) {
      jobDays = (json['job_days'] as List).map((e) => e.toString()).toList();
    }
    List<DateTime>? jobDayDates;
    if (json['job_day_dates'] != null && json['job_day_dates'] is List) {
      jobDayDates = (json['job_day_dates'] as List).map((e) {
        final value = e?.toString();
        if (value == null) return null;
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }).whereType<DateTime>().toList();
      if (jobDayDates.isEmpty) jobDayDates = null;
    }

    List<JobDayTime>? jobDayTimes;
    final rawJobDayTimes = json['job_day_times'];
    if (rawJobDayTimes is List) {
      final parsed = <JobDayTime>[];
      for (final item in rawJobDayTimes) {
        if (item is! Map) continue;
        try {
          parsed.add(
            JobDayTime.fromJson(
              Map<String, dynamic>.from(item),
              fallbackDate: jobDate,
            ),
          );
        } catch (_) {}
      }
      if (parsed.isNotEmpty) {
        parsed.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
        jobDayTimes = parsed;
      }
    }

    return JobModel(
      id: json['id']?.toString() ?? '',
      jobTitle: json['job_title'] ?? '',
      workType: workType,
      jobDescription: json['job_description']?.toString() ?? '',
      numberOfWorkersRequired: numberOfWorkersRequired,
      numberOfWorkersFilled: numberOfWorkersFilled,
      jobLocation: jobLocation,
      jobDate: jobDate,
      jobStatus: status,
      jobImageUrl: jobImageUrl,
      jobDuration: json['job_duration']?.toString(),
      durationStartTime: convertTimeToLocal(json['duration_start_time']?.toString()),
      durationEndTime: convertTimeToLocal(json['duration_end_time']?.toString()),
      requiredSkills: requiredSkills,
      createdBy: createdBy,
      createdAt: convertDateTimeToLocal(json['created_at']?.toString()),
      updatedAt: convertDateTimeToLocal(json['updated_at']?.toString()),
      perHourPay: (json['per_hour_pay'] != null)
          ? double.tryParse(json['per_hour_pay'].toString())
          : null,
      workMode: json['work_mode']?.toString(),
      fromDate: fromDate,
      endDate: endDate,
      numberOfDays: numberOfDays,
      shiftType: shiftType,
      address: address,
      postcode: postcode,
      country: country,
      region: region,
      district: district,
      city: city,
      jobDays: jobDays,
      jobDayDates: jobDayDates,
      jobDayTimes: jobDayTimes,
    );
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'workType': workType,
      'jobDescription': jobDescription,
      'numberOfWorkersRequired': numberOfWorkersRequired,
      'numberOfWorkersFilled': numberOfWorkersFilled,
      'jobLocation': jobLocation,
      'jobDate': jobDate.toIso8601String(),
      'jobStatus': jobStatus.toString(),
      'jobImageUrl': jobImageUrl,
      'jobDuration': jobDuration,
      'durationStartTime': durationStartTime,
      'durationEndTime': durationEndTime,
      'requiredSkills': requiredSkills,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'perHourPay': perHourPay,
      'work_mode': workMode,
      'fromDate': fromDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'numberOfDays': numberOfDays,
      'shiftType': shiftType,
      'address': address,
      'postcode': postcode,
      'country': country,
      'region': region,
      'district': district,
      'city': city,
      'jobDays': jobDays,
      'jobDayDates': jobDayDates?.map((d) => d.toIso8601String()).toList(),
      'jobDayTimes': jobDayTimes?.map((t) => t.toJson()).toList(),
    };
  }

  JobModel copyWith({
    String? id,
    String? jobTitle,
    String? workType,
    String? jobDescription,
    int? numberOfWorkersRequired,
    int? numberOfWorkersFilled,
    String? jobLocation,
    DateTime? jobDate,
    JobStatus? jobStatus,
    String? jobImageUrl,
    String? jobDuration,
    String? durationStartTime,
    String? durationEndTime,
    List<String>? requiredSkills,
    Map<String, dynamic>? createdBy,
    String? createdAt,
    String? updatedAt,
    double? perHourPay,
    String? workMode,
    DateTime? fromDate,
    DateTime? endDate,
    int? numberOfDays,
    String? shiftType,
    String? address,
    String? postcode,
    String? country,
    String? region,
    String? district,
    String? city,
    List<String>? jobDays,
    List<DateTime>? jobDayDates,
    List<JobDayTime>? jobDayTimes,
  }) {
    return JobModel(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      workType: workType ?? this.workType,
      jobDescription: jobDescription ?? this.jobDescription,
      numberOfWorkersRequired: numberOfWorkersRequired ?? this.numberOfWorkersRequired,
      numberOfWorkersFilled: numberOfWorkersFilled ?? this.numberOfWorkersFilled,
      jobLocation: jobLocation ?? this.jobLocation,
      jobDate: jobDate ?? this.jobDate,
      jobStatus: jobStatus ?? this.jobStatus,
      jobImageUrl: jobImageUrl ?? this.jobImageUrl,
      jobDuration: jobDuration ?? this.jobDuration,
      durationStartTime: durationStartTime ?? this.durationStartTime,
      durationEndTime: durationEndTime ?? this.durationEndTime,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      perHourPay: perHourPay ?? this.perHourPay,
      workMode: workMode ?? this.workMode,
      fromDate: fromDate ?? this.fromDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      shiftType: shiftType ?? this.shiftType,
      address: address ?? this.address,
      postcode: postcode ?? this.postcode,
      country: country ?? this.country,
      region: region ?? this.region,
      district: district ?? this.district,
      city: city ?? this.city,
      jobDays: jobDays ?? this.jobDays,
      jobDayDates: jobDayDates ?? this.jobDayDates,
      jobDayTimes: jobDayTimes ?? this.jobDayTimes,
    );
  }

  /// All scheduled days from API `job_day_dates`, comma-separated (e.g. "12 Jun 2026, 13 Jun 2026, 17 Jun 2026").
  /// Falls back to [formattedDate] when `job_day_dates` is missing.
  String get formattedJobDayDatesLine {
    if (jobDayDates != null && jobDayDates!.isNotEmpty) {
      final sorted = List<DateTime>.from(jobDayDates!)..sort();
      return sorted
          .map((d) => '${_getMonthName(d.month)} ${d.day}, ${d.year}')
          .join(', ');
    }
    return formattedDate;
  }

  /// Get formatted date string (e.g., "Today", "Tomorrow", "Dec 15, 2024")
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDay = DateTime(jobDate.year, jobDate.month, jobDate.day);
    
    if (jobDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (jobDay.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return '${_getMonthName(jobDate.month)} ${jobDate.day}, ${jobDate.year}';
    }
  }

  /// Get number of workers remaining (required - filled)
  int get numberOfWorkersRemaining {
    return numberOfWorkersRequired - numberOfWorkersFilled;
  }

  /// Check if job is fully filled
  bool get isFullyFilled {
    return numberOfWorkersFilled >= numberOfWorkersRequired;
  }

  /// True if the given date (year/month/day) is one of the job's scheduled days.
  /// Uses [jobDayDates] when present; otherwise compares to [jobDate].
  bool isDateScheduledFor(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    if (jobDayDates != null && jobDayDates!.isNotEmpty) {
      return jobDayDates!.any((d) {
        final compare = DateTime(d.year, d.month, d.day);
        return compare.isAtSameMomentAs(day);
      });
    }
    final jobDay = DateTime(jobDate.year, jobDate.month, jobDate.day);
    return jobDay.isAtSameMomentAs(day);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class JobDayTime {
  final DateTime date; // yyyy-MM-dd (local date only)
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm
  final String? startTimeInTimezone; // HH:mm
  final String? endTimeInTimezone; // HH:mm
  final String? startTimeUtc; // ISO string
  final String? endTimeUtc; // ISO string

  JobDayTime({
    required this.date,
    this.startTime,
    this.endTime,
    this.startTimeInTimezone,
    this.endTimeInTimezone,
    this.startTimeUtc,
    this.endTimeUtc,
  });

  /// True when API provided a non-empty start time (used for check-in window).
  bool get hasScheduledStartTime =>
      startTime != null && startTime!.trim().isNotEmpty;

  static String? _optionalTime(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s == 'null') return null;
    return s;
  }

  factory JobDayTime.fromJson(
    Map<String, dynamic> json, {
    DateTime? fallbackDate,
  }) {
    final dateStr = json['date']?.toString() ?? '';
    final startTime = _optionalTime(json['start_time']);
    final endTime = _optionalTime(json['end_time']);
    DateTime parsedDate;
    if (dateStr.isEmpty) {
      if (fallbackDate == null) {
        throw Exception('JobDayTime missing date');
      }
      parsedDate = fallbackDate;
    } else {
      parsedDate = DateTime.parse(dateStr);
    }
    return JobDayTime(
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      startTime: startTime,
      endTime: endTime,
      startTimeInTimezone: _optionalTime(json['start_time_in_timezone']),
      endTimeInTimezone: _optionalTime(json['end_time_in_timezone']),
      startTimeUtc: json['start_time_utc']?.toString(),
      endTimeUtc: json['end_time_utc']?.toString(),
    );
  }

  DateTime get startDateTime {
    if (!hasScheduledStartTime) {
      return DateTime(date.year, date.month, date.day);
    }
    final parts = startTime!.split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }

  DateTime get endDateTime {
    if (endTime == null || endTime!.trim().isEmpty) {
      return DateTime(date.year, date.month, date.day, 23, 59);
    }
    final parts = endTime!.split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }

  Map<String, dynamic> toJson() {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return {
      'date': '$yyyy-$mm-$dd',
      'start_time': startTime,
      'end_time': endTime,
      'start_time_in_timezone': startTimeInTimezone,
      'end_time_in_timezone': endTimeInTimezone,
      'start_time_utc': startTimeUtc,
      'end_time_utc': endTimeUtc,
    };
  }
}

