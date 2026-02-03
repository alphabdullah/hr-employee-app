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
      final endpoint = ApiEndpoints.punchIn(activeJobApp.job.id);
      
      // Get device location
      Position position = await Geolocator.getCurrentPosition();
      
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
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Location access is required to punch in.';
      return false;
    } finally {
      _isCheckingIn = false;
      notifyListeners();
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
      final endpoint = ApiEndpoints.punchOut(activeJobApp.job.id);
      
      Position position = await Geolocator.getCurrentPosition();
      
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
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Location access is required to punch out.';
      return false;
    } finally {
      _isCheckingOut = false;
      notifyListeners();
    }
  }

  Future<Position?> _resolveDeviceLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
    } catch (e) {
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

  /// Load user's jobs from /api/me/jobs
  Future<void> loadMyJobs({bool forceRefresh = false}) async {
    // Try disk cache first
    if (!forceRefresh && _myApplications.isEmpty) {
      final cachedApplications = await CacheService.loadApplications();
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

    _isLoadingApplications = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        _isLoadingApplications = false;
        notifyListeners();
        return;
      }

      final response = await ApiClient.get(
        ApiEndpoints.getMyJobs,
        queryParameters: {'per_page': '100'},
        token: token,
      );

      _isLoadingApplications = false;
      _hasLoadedApplications = true;

      if (response.isSuccess) {
        List<Map<String, dynamic>>? jobsList = response.getList<Map<String, dynamic>>('jobs');
        if (jobsList != null && jobsList.isNotEmpty) {
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
            await CacheService.saveApplications(applicationsForCache);
          }
          notifyListeners();
        } else {
          _myApplications = [];
          await CacheService.clearApplications();
          notifyListeners();
        }
      }
    } catch (e) {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  Future<void> loadMyApplications({bool forceRefresh = false}) async {
    return loadMyJobs(forceRefresh: forceRefresh);
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
            await CacheService.saveApplications(applicationsForCache);
          }
          notifyListeners();
        }
      }
    } catch (_) {}
  }

}
