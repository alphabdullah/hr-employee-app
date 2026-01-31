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
  });

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

    // Parse job_date and convert to local timezone
    DateTime jobDate;
    if (json['job_date'] != null) {
      try {
        final parsedDate = DateTime.parse(json['job_date']);
        // Convert to local timezone if it's in UTC
        jobDate = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
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

    // Convert time strings from UTC/server timezone to local timezone
    String? convertTimeToLocal(String? timeString) {
      if (timeString == null || timeString.isEmpty) {
        return null;
      }
      
      try {
        // Parse time string (format: "HH:mm" or "HH:mm:ss")
        final timeParts = timeString.split(':');
        if (timeParts.length < 2) {
          return timeString; // Return original if can't parse
        }
        
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        
        // Create a DateTime in UTC (assuming backend sends times in UTC)
        // Use today's date for conversion
        final now = DateTime.now();
        final utcDateTime = DateTime.utc(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        
        // Convert to local time
        final localDateTime = utcDateTime.toLocal();
        
        // Format time string in local timezone
        final localTimeString = '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
        
        // Log conversion for debugging
        if (localTimeString != timeString) {
          print('[JobModel] Time converted: $timeString (UTC) -> $localTimeString (Local, ${now.timeZoneName})');
        }
        
        return localTimeString;
      } catch (e) {
        // If parsing fails, return original time string
        print('[JobModel] Failed to convert time "$timeString": $e');
        return timeString;
      }
    }
    
    // Convert ISO 8601 datetime strings from UTC to local timezone
    String? convertDateTimeToLocal(String? dateTimeString) {
      if (dateTimeString == null || dateTimeString.isEmpty) {
        return null;
      }
      
      try {
        // Parse the datetime string (assuming ISO 8601 format)
        final parsedDateTime = DateTime.parse(dateTimeString);
        
        // Convert to local timezone if it's in UTC
        final localDateTime = parsedDateTime.isUtc ? parsedDateTime.toLocal() : parsedDateTime;
        
        // Return as ISO 8601 string in local timezone
        return localDateTime.toIso8601String();
      } catch (e) {
        // If parsing fails, return original string
        print('[JobModel] Failed to convert datetime "$dateTimeString": $e');
        return dateTimeString;
      }
    }
    
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
        if (fromDate.isUtc) fromDate = fromDate.toLocal();
      } catch (_) {}
    }
    DateTime? endDate;
    if (json['end_date'] != null) {
      try {
        endDate = DateTime.parse(json['end_date'].toString());
        if (endDate.isUtc) endDate = endDate.toLocal();
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
          final parsed = DateTime.parse(value);
          return parsed.isUtc ? parsed.toLocal() : parsed;
        } catch (_) {
          return null;
        }
      }).whereType<DateTime>().toList();
      if (jobDayDates.isEmpty) jobDayDates = null;
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
    );
  }

  /// Formatted date range (e.g. "Jan 30 - Feb 1, 2026") when job_day_dates exist
  String? get formattedDateRange {
    if (jobDayDates != null && jobDayDates!.length >= 2) {
      final sorted = List<DateTime>.from(jobDayDates!)..sort();
      final from = '${_getMonthName(sorted.first.month)} ${sorted.first.day}, ${sorted.first.year}';
      final end = '${_getMonthName(sorted.last.month)} ${sorted.last.day}, ${sorted.last.year}';
      return '$from - $end';
    }
    if (fromDate != null && endDate != null) {
      final from = '${_getMonthName(fromDate!.month)} ${fromDate!.day}, ${fromDate!.year}';
      final end = '${_getMonthName(endDate!.month)} ${endDate!.day}, ${endDate!.year}';
      return '$from - $end';
    }
    return null;
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

