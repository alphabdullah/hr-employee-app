import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/job_model.dart';
import '../models/attendance_model.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';

/// Application data structure
class ApplicationData {
  final JobModel job;
  final String status;
  final String applicationId;

  ApplicationData({
    required this.job,
    required this.status,
    required this.applicationId,
  });
}

/// ViewModel for Job Posts screen
class JobViewModel extends ChangeNotifier {
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCheckedIn = false; // Track check-in status for active job
  Map<String, String> _applicationStatuses = {}; // jobId -> application status
  List<ApplicationData> _myApplications = []; // Full application data with job details
  bool _isLoadingApplications = false;
  bool _hasLoadedApplications = false; // Track if applications have been loaded at least once
  bool _isCheckingIn = false; // Track check-in operation in progress
  bool _isCheckingOut = false; // Track check-out operation in progress
  List<AttendanceModel> _attendanceRecords = []; // Attendance records from API
  bool _isLoadingAttendance = false;

  List<JobModel> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCheckedIn => _isCheckedIn;
  bool get isLoadingApplications => _isLoadingApplications;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  bool get isLoadingAttendance => _isLoadingAttendance;
  List<ApplicationData> get myApplications => _myApplications;
  
  /// Get applications with "Applied" status (for pending tab)
  List<ApplicationData> get appliedApplications {
    return _myApplications.where((app) => app.status == 'Applied').toList();
  }
  
  /// Get all applications (for Job History)
  List<ApplicationData> get allApplications => _myApplications;

  /// Clears all in-memory job/applications state for current runtime session.
  /// Use this on logout or before switching to another account.
  void clearSessionState({bool notify = true}) {
    _jobs = [];
    _errorMessage = null;
    _isCheckedIn = false;
    _applicationStatuses.clear();
    _myApplications = [];
    _isLoading = false;
    _isLoadingApplications = false;
    _hasLoadedApplications = false;
    _isCheckingIn = false;
    _isCheckingOut = false;
    _attendanceRecords = [];
    _isLoadingAttendance = false;
    if (notify) {
      notifyListeners();
    }
  }
  
  /// Check if user has applied to a specific job
  bool hasAppliedToJob(String jobId) {
    return _applicationStatuses.containsKey(jobId);
  }
  
  /// Get application status for a specific job
  String? getApplicationStatus(String jobId) {
    return _applicationStatuses[jobId];
  }

  /// Get ApplicationData for a specific job
  ApplicationData? getApplicationDataForJob(String jobId) {
    try {
      return _myApplications.firstWhere(
        (app) => app.job.id == jobId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get job by ID
  JobModel? getJobById(String id) {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Helper to check if a job is scheduled for a specific date (ignoring time)
  bool _isJobScheduledForDate(JobModel job, DateTime date) {
    // Check job_day_dates array first
    if (job.jobDayDates != null && job.jobDayDates!.isNotEmpty) {
      return job.jobDayDates!.any((d) => 
        d.year == date.year && d.month == date.month && d.day == date.day
      );
    }
    // Fallback to single jobDate
    final jDate = job.jobDate;
    return jDate.year == date.year && jDate.month == date.month && jDate.day == date.day;
  }

  /// Get active job based on "job_day_dates"
  /// Returns a job if:
  /// 1. Status is "Selected" or "In Progress"
  /// 2. Today's date matches one of the dates in "job_day_dates" (or "jobDate")
  /// Get active jobs based on "job_days" and "job_day_dates"
  /// Returns jobs if:
  /// 1. Status is "Selected" or "In Progress"
  /// 2. Today's date matches one of the dates in "job_day_dates"
  List<ApplicationData> get activeJobs {
    final now = DateTime.now();
    
    return _myApplications.where((app) {
      // 1. Check Status
      final status = app.status.toLowerCase();
      if (status != 'selected' && status != 'in progress') {
        return false;
      }
      
      // 2. Check Date (Active if today is in the schedule)
      return _isJobScheduledForDate(app.job, now);
    }).toList();
  }

  /// Get active job (Legacy: returns first active job)
  ApplicationData? get activeJob {
    final jobs = activeJobs;
    if (jobs.isEmpty) return null;

    // Prioritize In Progress job
    try {
      return jobs.firstWhere((app) => app.status.toLowerCase() == 'in progress');
    } catch (_) {
      return jobs.first;
    }
  }

  /// Check if Punch In button should be shown
  /// Returns true if:
  /// - Today is in `job_day_dates`
  /// - Status is 'Selected' or 'In Progress' (though usually 'Selected' shows Punch In)
  bool shouldShowCheckInButton(ApplicationData? application) {
    if (application == null) {
      return false;
    }
    
    final now = DateTime.now();
    
    // 1. Verify Date: Must be scheduled for today
    if (!_isJobScheduledForDate(application.job, now)) {
      return false;
    }
    
    // 2. Verify Status
    final status = application.status.toLowerCase();
    // Show Punch In if Selected (waiting to start) or In Progress (if we want to allow re-punch/validation, but usually Selected)
    if (status != 'selected' && status != 'in progress') {
      return false;
    }

    // 3. Time gating (job_day_times)
    // Allow check-in starting 1 hour before the scheduled start time.
    final dayTime = application.job.getJobDayTimeFor(now) ??
        (application.job.jobDayTimes != null &&
                application.job.jobDayTimes!.isNotEmpty
            ? application.job.jobDayTimes!.first
            : null);
    if (dayTime != null && dayTime.hasScheduledStartTime) {
      final checkInFrom =
          dayTime.startDateTime.subtract(const Duration(hours: 1));
      if (now.isBefore(checkInFrom)) {
        return false;
      }
    }
    
    return true;
  }

  /// Fetch attendance records from API
  /// [silent] - If true, doesn't set loading flag (for background refreshes)
  Future<void> fetchAttendance({bool silent = false}) async {
    if (!silent) {
      _isLoadingAttendance = true;
      notifyListeners();
    }

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        if (!silent) {
          _isLoadingAttendance = false;
          notifyListeners();
        }
        return;
      }

      debugPrint('[Attendance API] GET ${ApiEndpoints.getMyAttendance}');
      final response = await ApiClient.get(
        ApiEndpoints.getMyAttendance,
        token: token,
      );

      if (!silent) {
        _isLoadingAttendance = false;
      }

      if (response.isSuccess) {
        final attendanceList = response.getList<Map<String, dynamic>>('attendance');
        if (attendanceList != null) {
          _attendanceRecords = attendanceList
              .map((json) => AttendanceModel.fromJson(json))
              .toList();
          debugPrint('[Attendance API] Loaded ${_attendanceRecords.length} attendance records');
        } else {
          _attendanceRecords = [];
        }
      } else {
        debugPrint('[Attendance API] Failed: ${response.message}');
        _attendanceRecords = [];
      }
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _isLoadingAttendance = false;
      }
      debugPrint('[Attendance API] Exception: $e');
      notifyListeners();
    }
  }

  /// Get today's attendance record for a specific job
  AttendanceModel? getTodayAttendanceForJob(String jobId) {
    final jobIdInt = int.tryParse(jobId);
    if (jobIdInt == null) return null;

    try {
      return _attendanceRecords.firstWhere(
        (attendance) =>
            attendance.jobId == jobIdInt && attendance.isPunchInToday,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all attendance records for a specific job
  List<AttendanceModel> getAllAttendanceForJob(String jobId) {
    final jobIdInt = int.tryParse(jobId);
    if (jobIdInt == null) return [];

    return _attendanceRecords
        .where((attendance) => attendance.jobId == jobIdInt)
        .toList()
      ..sort((a, b) {
        // Sort by punch in date (most recent first)
        if (a.punchInAt == null && b.punchInAt == null) return 0;
        if (a.punchInAt == null) return 1;
        if (b.punchInAt == null) return -1;
        return b.punchInAt!.compareTo(a.punchInAt!);
      });
  }

  /// Check if job is completed today (has punch out for today)
  bool isJobCompletedToday(String jobId) {
    final attendance = getTodayAttendanceForJob(jobId);
    return attendance != null && attendance.isCompletedToday;
  }

  /// Check if Punch Out button should be shown
  bool shouldShowCheckOutButton(ApplicationData? application) {
    if (application == null) {
      return false;
    }
    
    final now = DateTime.now();
    
    // 1. Verify Date
    if (!_isJobScheduledForDate(application.job, now)) {
      return false;
    }
    
    // 2. Check attendance: punch in today but no punch out yet
    final attendance = getTodayAttendanceForJob(application.job.id);
    if (attendance != null && attendance.isActiveToday) {
      return true;
    }
    
    // 3. Fallback: Verify Status (Must be 'In Progress')
    final status = application.status.toLowerCase();
    return status == 'in progress';
  }

  /// Get assigned jobs (jobs where user's application status is "Selected")
  /// Excludes jobs that are currently Active (shown in the active tab)
  List<ApplicationData> get assignedJobs {
    final now = DateTime.now();
    
    return _myApplications.where((app) {
      // Check if application status is "Selected"
      if (app.status.toLowerCase() != 'selected') {
        return false;
      }
      
      // Don't include if today is one of this job's scheduled days (already in Active Job)
      return !_isJobScheduledForDate(app.job, now);
    }).toList();
  }

  List<JobModel> get pendingJobs {
    return [];
  }

  List<JobModel> get allJobs => _jobs;

  /// Check in (punch in) for active job
  Future<bool> checkIn({String? jobId}) async {
    final activeJobApp = jobId != null ? getApplicationDataForJob(jobId) : activeJob;

    if (activeJobApp == null) {
      _errorMessage = 'No active job found';
      notifyListeners();
      return false;
    }

    _isCheckingIn = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isCheckingIn = false;
        notifyListeners();
        return false;
      }

      final endpoint = ApiEndpoints.punchIn(activeJobApp.job.id);
      
      // Get device location with proper permission handling
      final position = await _resolveDeviceLocation();
      if (position == null) {
        _errorMessage = 'Location access is required to punch in. Please enable location services and grant permission.';
        _isCheckingIn = false;
        notifyListeners();
        return false;
      }
      
      // Request body as requested: { "lat": ..., "lng": ... }
      final body = {
        "lat": position.latitude,
        "lng": position.longitude
      };

      final response = await ApiClient.post(
        endpoint,
        body: body,
        token: token,
      );

      if (response.isSuccess) {
        _isCheckedIn = true;
        // Refresh data in background without showing loading indicator
        _refreshMyJobsInBackground().then((_) => fetchAttendance(silent: true));
        _isCheckingIn = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isCheckingIn = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Check-in error: $e');
      _errorMessage = 'Failed to check in. Please ensure location services are enabled and try again.';
      _isCheckingIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Check out (punch out) for active job
  Future<bool> checkOut({String? jobId}) async {
    final activeJobApp = jobId != null ? getApplicationDataForJob(jobId) : activeJob;

    if (activeJobApp == null) {
      _errorMessage = 'No active job found';
      notifyListeners();
      return false;
    }

    _isCheckingOut = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }

      final endpoint = ApiEndpoints.punchOut(activeJobApp.job.id);
      
      // Get device location with proper permission handling
      final position = await _resolveDeviceLocation();
      if (position == null) {
        _errorMessage = 'Location access is required to punch out. Please enable location services and grant permission.';
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }
      
      final body = {
        "lat": position.latitude,
        "lng": position.longitude
      };

      final response = await ApiClient.post(
        endpoint,
        body: body,
        token: token,
      );

      if (response.isSuccess) {
        _isCheckedIn = false;
        // Refresh data in background without showing loading indicator
        _refreshMyJobsInBackground().then((_) => fetchAttendance(silent: true));
        _isCheckingOut = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Check-out error: $e');
      _errorMessage = 'Failed to check out. Please ensure location services are enabled and try again.';
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  Future<Position?> _resolveDeviceLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[Location] Location services are disabled');
        return null;
      }

      // Check current permission status
      var permission = await Geolocator.checkPermission();
      debugPrint('[Location] Current permission: $permission');

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        debugPrint('[Location] Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        debugPrint('[Location] Permission after request: $permission');
      }

      // Check if permission is still denied
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('[Location] Permission denied or denied forever');
        return null;
      }

      // Get current position
      debugPrint('[Location] Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      debugPrint('[Location] Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('[Location] Error getting location: $e');
      return null;
    }
  }

  void _updateLocalApplicationStatus(String jobId, String newStatus) {
    _applicationStatuses[jobId] = newStatus;
    final index = _myApplications.indexWhere((app) => app.job.id == jobId);
    if (index != -1) {
      _myApplications[index] = ApplicationData(
        job: _myApplications[index].job,
        status: newStatus,
        applicationId: _myApplications[index].applicationId,
      );
    }
  }

  /// Whether two application lists represent the same data (ids, status, job updatedAt).
  bool _applicationsUnchanged(
    List<ApplicationData> before,
    List<ApplicationData> after,
  ) {
    if (before.length != after.length) return false;
    String token(ApplicationData x) =>
        '${x.job.id}|${x.status}|${x.job.updatedAt ?? ''}';
    final a = before.map(token).toList()..sort();
    final b = after.map(token).toList()..sort();
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Load user's jobs from /api/me/jobs
  /// [silent]: no loading flag / no spinner; for polling, only [notifyListeners] if data changed.
  Future<void> loadMyJobs({bool forceRefresh = false, bool silent = false}) async {
    final currentEmployeeId = await AuthService.getEmployeeId();
    // Try disk cache first
    if (!forceRefresh && _myApplications.isEmpty) {
      final cachedApplications = await CacheService.loadApplications(
        ownerId: currentEmployeeId,
      );
      if (cachedApplications != null && cachedApplications.isNotEmpty) {
        try {
          _applicationStatuses.clear();
          _myApplications.clear();
          for (var application in cachedApplications) {
            final jobData = application['job'] as Map<String, dynamic>?;
            final jobId = jobData?['id']?.toString() ?? application['job_id']?.toString();
            final status = application['status']?.toString() ?? application['application_status']?.toString();
            final applicationId = application['id']?.toString() ?? '';
            
            if (jobData != null && jobId != null && status != null) {
              try {
                final job = JobModel.fromJson(jobData);
                _applicationStatuses[jobId] = status;
                _myApplications.add(ApplicationData(
                  job: job,
                  status: status,
                  applicationId: applicationId,
                ));
              } catch (e) {
                debugPrint('Failed to parse cached application: $e');
              }
            }
          }
          _hasLoadedApplications = true;
          notifyListeners();
        } catch (_) {}
      }
    }

    if (!forceRefresh && _hasLoadedApplications && _myApplications.isNotEmpty) {
      _refreshMyJobsInBackground();
      return;
    }

    if (!silent) {
      _isLoadingApplications = true;
      notifyListeners();
    }

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        if (!silent) {
          _isLoadingApplications = false;
          notifyListeners();
        }
        return;
      }

      final response = await ApiClient.get(
        ApiEndpoints.getMyJobs,
        queryParameters: {'per_page': '100'},
        token: token,
      );

      if (!silent) {
        _isLoadingApplications = false;
      }
      _hasLoadedApplications = true;

      if (response.isSuccess) {
        List<Map<String, dynamic>>? jobsList = response.getList<Map<String, dynamic>>('jobs');
        if (jobsList != null && jobsList.isNotEmpty) {
          final beforeSnapshot = List<ApplicationData>.from(_myApplications);
          _applicationStatuses.clear();
          _myApplications.clear();
          final applicationsForCache = <Map<String, dynamic>>[];

          for (var jobOrApplication in jobsList) {
            final jobData = jobOrApplication['job'] as Map<String, dynamic>? ?? jobOrApplication;
            final jobId = jobData['id']?.toString() ?? jobOrApplication['job_id']?.toString();
            final applicationId = jobOrApplication['id']?.toString() ?? '';
            
            // IMPORTANT: If 'application_status' is missing from /api/me/jobs, 
            // we default to 'Selected' because these are assigned jobs.
            // Using 'Applied' (previous default) caused active jobs to be hidden.
            final status = jobOrApplication['application_status']?.toString() ?? 'Selected';

            if (jobData.isNotEmpty && jobId != null) {
              try {
                final job = JobModel.fromJson(jobData);
                _applicationStatuses[jobId] = status;
                _myApplications.add(ApplicationData(
                  job: job,
                  status: status,
                  applicationId: applicationId,
                ));
                applicationsForCache.add({
                  'job': jobData,
                  'status': status,
                  'id': applicationId,
                });
              } catch (e) {
                debugPrint('Failed to parse job: $e');
              }
            }
          }

          if (applicationsForCache.isNotEmpty) {
            await CacheService.saveApplications(
              applicationsForCache,
              ownerId: currentEmployeeId,
            );
          }
          if (!silent || !_applicationsUnchanged(beforeSnapshot, _myApplications)) {
            notifyListeners();
          }
        } else {
          final hadApplications = _myApplications.isNotEmpty;
          _myApplications = [];
          await CacheService.clearApplications();
          if (!silent || hadApplications) {
            notifyListeners();
          }
        }
      }
    } catch (e) {
      if (!silent) {
        _isLoadingApplications = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMyApplications({
    bool forceRefresh = false,
    bool silent = false,
  }) async {
    return loadMyJobs(forceRefresh: forceRefresh, silent: silent);
  }

  Future<void> _refreshMyJobsInBackground() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) return;

      final response = await ApiClient.get(
        ApiEndpoints.getMyJobs,
        queryParameters: {'per_page': '100'},
        token: token,
      );

      if (response.isSuccess) {
        List<Map<String, dynamic>>? jobsList = response.getList<Map<String, dynamic>>('jobs');
        if (jobsList != null) {
          _applicationStatuses.clear();
          _myApplications.clear();
          final applicationsForCache = <Map<String, dynamic>>[];

          for (var jobOrApplication in jobsList) {
            final jobData = jobOrApplication['job'] as Map<String, dynamic>? ?? jobOrApplication;
            final jobId = jobData['id']?.toString() ?? jobOrApplication['job_id']?.toString();
            final applicationId = jobOrApplication['id']?.toString() ?? '';
            // Default to 'Selected' if status is missing
            final status = jobOrApplication['application_status']?.toString() ?? 'Selected';

            if (jobData.isNotEmpty && jobId != null) {
              try {
                final job = JobModel.fromJson(jobData);
                _applicationStatuses[jobId] = status;
                _myApplications.add(ApplicationData(
                  job: job,
                  status: status,
                  applicationId: applicationId,
                ));
                applicationsForCache.add({
                  'job': jobData,
                  'status': status,
                  'id': applicationId,
                });
              } catch (_) {}
            }
          }

          if (applicationsForCache.isNotEmpty) {
            final currentEmployeeId = await AuthService.getEmployeeId();
            await CacheService.saveApplications(
              applicationsForCache,
              ownerId: currentEmployeeId,
            );
          }
          notifyListeners();
        }
      }
    } catch (_) {}
  }

}
