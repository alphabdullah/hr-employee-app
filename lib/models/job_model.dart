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

    // Handle job_image - can be null or a string URL
    final jobImage = json['job_image'];
    final String? jobImageUrl;
    if (jobImage == null || jobImage == 'null' || jobImage.toString().isEmpty) {
      jobImageUrl = null;
    } else {
      jobImageUrl = jobImage.toString();
    }

    // Handle created_by object
    Map<String, dynamic>? createdBy;
    if (json['created_by'] != null && json['created_by'] is Map) {
      createdBy = Map<String, dynamic>.from(json['created_by']);
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
    
    return JobModel(
      id: json['id']?.toString() ?? '',
      jobTitle: json['job_title'] ?? '',
      workType: workType,
      jobDescription: json['job_description'] ?? '',
      numberOfWorkersRequired: json['number_of_workers_required'] ?? 0,
      numberOfWorkersFilled: json['number_of_selected_workers'] ?? 
                            json['number_of_workers_filled'] ?? 
                            0,
      jobLocation: json['job_location'] ?? '',
      jobDate: jobDate,
      jobStatus: status,
      jobImageUrl: jobImageUrl,
      jobDuration: json['job_duration'],
      durationStartTime: convertTimeToLocal(json['duration_start_time']),
      durationEndTime: convertTimeToLocal(json['duration_end_time']),
      requiredSkills: requiredSkills,
      createdBy: createdBy,
      createdAt: convertDateTimeToLocal(json['created_at']),
      updatedAt: convertDateTimeToLocal(json['updated_at']),
      perHourPay: (json['per_hour_pay'] != null)
          ? double.tryParse(json['per_hour_pay'].toString())
          : null,
      workMode: json['work_mode']?.toString(),

    );
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

    );
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

