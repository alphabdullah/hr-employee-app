import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/job_model.dart';
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
  Map<String, String> _applicationStatuses = {}; // jobId -> application status (Applied, Selected, In Progress, Completed, Rejected)
  List<ApplicationData> _myApplications = []; // Full application data with job details
  bool _isLoadingApplications = false;
  bool _hasLoadedApplications = false; // Track if applications have been loaded at least once
  bool _isCheckingIn = false; // Track check-in operation in progress
  bool _isCheckingOut = false; // Track check-out operation in progress

  List<JobModel> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCheckedIn => _isCheckedIn;
  bool get isLoadingApplications => _isLoadingApplications;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
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

  /// Load job posts from API
  Future<void> loadJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Call jobs API endpoint
      final response = await ApiClient.get(
        ApiEndpoints.getAllJobs,
        token: token,
      );

      _isLoading = false;

      if (response.isSuccess) {
        // Parse jobs array from response
        final jobsList = response.getList<Map<String, dynamic>>('jobs');
        
        if (jobsList != null && jobsList.isNotEmpty) {
          // Convert API jobs to JobModel list
          _jobs = jobsList.map((jobJson) {
            return JobModel.fromJson(jobJson);
          }).toList();
          
          _errorMessage = null;
        } else {
          // No jobs found
          _jobs = [];
          _errorMessage = null;
        }
      } else {
        _errorMessage = response.message;
        _jobs = [];
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load job posts. Please try again.';
      _jobs = [];
      notifyListeners();
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

  /// Get active job (job where date is today AND user's application status is "Selected" or "In Progress")
  /// Shows today's job whether user has checked in or not
  ApplicationData? get activeJob {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final activeAppsForToday = _myApplications.where((app) {
      // Check if application status is "Selected" or "In Progress"
      final status = app.status.toLowerCase();
      if (status != 'selected' && status != 'in progress') {
        return false;
      }
      
      // Check if today is one of the job's scheduled days (job_day_dates or jobDate)
      return app.job.isDateScheduledFor(today);
    }).toList();
    
    if (activeAppsForToday.isEmpty) {
      return null;
    }
    
    // Return the first active job for today (should only be one)
    return activeAppsForToday.first;
  }

  /// Check if check-in button should be shown for a job
  /// Returns true if:
  /// - Job date is today
  /// - Current time is between start time and 1 hour after start time
  /// - User's application status is "In Progress" or "Selected"
  bool shouldShowCheckInButton(ApplicationData? application) {
    if (application == null) {
      return false;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if today is one of the job's scheduled days (job_day_dates or jobDate)
    if (!application.job.isDateScheduledFor(today)) {
      return false;
    }
    
    // Check application status (should be "In Progress" or "Selected")
    final status = application.status.toLowerCase();
    if (status != 'in progress' && status != 'selected') {
      return false;
    }
    
    // If no start time from API (e.g. /api/me/jobs), show Punch In all day on scheduled dates
    final startTime = application.job.durationStartTime;
    if (startTime == null || startTime.isEmpty) {
      return true;
    }
    
    try {
      // Parse start time (format: "09:00" or "09:00:00")
      final startTimeParts = startTime.split(':');
      if (startTimeParts.length < 2) {
        return true;
      }
      
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      
      // Create DateTime for today's start time
      final startDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );
      
      // Check if current time is between start time (inclusive) and 1 hour after start time (exclusive)
      // Show button when: start_time <= current_time < start_time + 1 hour
      final timeDifference = now.difference(startDateTime);
      return timeDifference.inMinutes >= 0 && timeDifference.inMinutes < 60;
    } catch (e) {
      debugPrint('Failed to parse start time: $e');
      return true;
    }
  }

  /// Get assigned jobs (jobs where user's application status is "Selected")
  /// Excludes jobs that are shown in Active Job (today's Selected jobs)
  List<ApplicationData> get assignedJobs {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _myApplications.where((app) {
      // Check if application status is "Selected"
      if (app.status.toLowerCase() != 'selected') {
        return false;
      }
      
      // Don't include if today is one of this job's scheduled days (already in Active Job)
      return !app.job.isDateScheduledFor(today);
    }).toList();
  }

  /// Get pending jobs (awaiting accept/reject response) - legacy method, kept for compatibility
  /// Note: JobStatus.pending was removed as API only returns 'open', 'closed', or 'filled'
  List<JobModel> get pendingJobs {
    return []; // No pending job status from API
  }

  /// Get all jobs
  List<JobModel> get allJobs => _jobs;

  /// Check in (punch in) for active job
  Future<bool> checkIn() async {
    if (_isCheckedIn) {
      debugPrint('[Check-in API] Already checked in, skipping API call');
      return false; // Already checked in
    }

    // Get the active job
    final activeJobApp = activeJob;
    if (activeJobApp == null) {
      debugPrint('[Check-in API] No active job found');
      _errorMessage = 'No active job found';
      notifyListeners();
      return false;
    }

    // Set loading state
    _isCheckingIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('[Check-in API] Authentication token is missing');
        _errorMessage = 'Authentication required. Please login again.';
        notifyListeners();
        return false;
      }

      final endpoint = ApiEndpoints.punchIn(activeJobApp.job.id);
      
      // Get current time information for debugging
      final now = DateTime.now();
      final nowUtc = DateTime.now().toUtc();
      final jobStartTime = activeJobApp.job.durationStartTime;
      
      debugPrint('[Check-in API] Starting check-in request');
      debugPrint('[Check-in API] Endpoint: $endpoint');
      debugPrint('[Check-in API] Job ID: ${activeJobApp.job.id}');
      debugPrint('[Check-in API] Job Title: ${activeJobApp.job.jobTitle}');
      debugPrint('[Check-in API] Current Application Status: ${activeJobApp.status}');
      debugPrint('[Check-in API] Job Date: ${activeJobApp.job.jobDate}');
      debugPrint('[Check-in API] Job Start Time (from API): $jobStartTime');
      debugPrint('[Check-in API] Device Current Time (Local): $now');
      debugPrint('[Check-in API] Device Current Time (UTC): $nowUtc');
      debugPrint('[Check-in API] Device Timezone Offset: ${now.timeZoneOffset}');
      debugPrint('[Check-in API] Device Timezone Name: ${now.timeZoneName}');
      
      // Parse and log the start time comparison
      if (jobStartTime != null && jobStartTime.isNotEmpty) {
        try {
          final startTimeParts = jobStartTime.split(':');
          if (startTimeParts.length >= 2) {
            final startHour = int.parse(startTimeParts[0]);
            final startMinute = int.parse(startTimeParts[1]);
            final startDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              startHour,
              startMinute,
            );
            final startDateTimeUtc = startDateTime.toUtc();
            final timeDifference = now.difference(startDateTime);
            final timeDifferenceMinutes = timeDifference.inMinutes;
            
            debugPrint('[Check-in API] Parsed Start Time (Local): $startDateTime');
            debugPrint('[Check-in API] Parsed Start Time (UTC): $startDateTimeUtc');
            debugPrint('[Check-in API] Time Difference (minutes): $timeDifferenceMinutes');
            debugPrint('[Check-in API] Time Difference (seconds): ${timeDifference.inSeconds}');
            debugPrint('[Check-in API] Is current time >= start time? ${now.isAfter(startDateTime) || now.isAtSameMomentAs(startDateTime)}');
      debugPrint('[Check-in API] Current hour: ${now.hour}, minute: ${now.minute}, second: ${now.second}');
      debugPrint('[Check-in API] Start hour: ${startDateTime.hour}, minute: ${startDateTime.minute}');
      debugPrint('[Check-in API] ⚠️ TIMEZONE ISSUE DETECTED ⚠️');
      debugPrint('[Check-in API] Backend likely sees: Server time (probably UTC: ${nowUtc.hour}:${nowUtc.minute.toString().padLeft(2, '0')}) vs Job start time (11:15 in backend timezone)');
      debugPrint('[Check-in API] Backend comparison: ${nowUtc.hour}:${nowUtc.minute.toString().padLeft(2, '0')} >= 11:15? ${nowUtc.hour > 11 || (nowUtc.hour == 11 && nowUtc.minute >= 15)}');
      }
        } catch (e) {
          debugPrint('[Check-in API] Error parsing start time: $e');
        }
      }

      final location = await _resolveDeviceLocation();
      final body = <String, dynamic>{};
      if (location != null) {
        body['punch_in_latitude'] = location.latitude.toString();
        body['punch_in_longitude'] = location.longitude.toString();
      } else {
        debugPrint('[Check-in API] Unable to retrieve location for punch in');
      }

      // Call punch-in API endpoint
      // NOTE: Backend uses server time for validation, not client time
      // This may cause timezone mismatch issues
      final response = await ApiClient.post(
        endpoint,
        token: token,
        body: body.isEmpty ? null : body,
      );

      debugPrint('[Check-in API] Response received');
      debugPrint('[Check-in API] Success: ${response.isSuccess}');
      debugPrint('[Check-in API] Status Code: ${response.statusCode}');
      debugPrint('[Check-in API] Message: ${response.message}');
      debugPrint('[Check-in API] Response Data: ${response.data}');

      if (response.isSuccess) {
        _isCheckedIn = true;
        _errorMessage = null;
        
        debugPrint('[Check-in API] Check-in successful');
        debugPrint('[Check-in API] Updating application status from "${activeJobApp.status}" to "In Progress"');
        
        // Update application status to "In Progress" if it was "Selected"
        if (activeJobApp.status.toLowerCase() == 'selected') {
          _applicationStatuses[activeJobApp.job.id] = 'In Progress';
          // Update the application in the list
          final index = _myApplications.indexWhere((app) => app.job.id == activeJobApp.job.id);
          if (index != -1) {
            _myApplications[index] = ApplicationData(
              job: activeJobApp.job,
              status: 'In Progress',
              applicationId: activeJobApp.applicationId,
            );
          }
        }
        
        _isCheckingIn = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('[Check-in API] Check-in failed: ${response.message}');
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to check in. Please try again.';
        _isCheckingIn = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('[Check-in API] Exception occurred: $e');
      debugPrint('[Check-in API] Stack trace: ${StackTrace.current}');
      _errorMessage = 'Failed to check in. Please try again.';
      _isCheckingIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset check-in status (for testing or logout)
  void resetCheckIn() {
    _isCheckedIn = false;
    notifyListeners();
  }

  /// Check out (punch out) for active job
  Future<bool> checkOut() async {
    // Get the active job
    final activeJobApp = activeJob;
    if (activeJobApp == null) {
      debugPrint('[Check-out API] No active job found');
      _errorMessage = 'No active job found';
      notifyListeners();
      return false;
    }

    // Check if status is "In Progress"
    if (activeJobApp.status.toLowerCase() != 'in progress') {
      debugPrint('[Check-out API] Job is not in progress. Current status: ${activeJobApp.status}');
      _errorMessage = 'You must check in before checking out';
      notifyListeners();
      return false;
    }

    // Set loading state
    _isCheckingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('[Check-out API] Authentication token is missing');
        _errorMessage = 'Authentication required. Please login again.';
        notifyListeners();
        return false;
      }

      final endpoint = ApiEndpoints.punchOut(activeJobApp.job.id);
      
      // Get current time information for debugging
      final now = DateTime.now();
      final nowUtc = DateTime.now().toUtc();
      final jobEndTime = activeJobApp.job.durationEndTime;
      
      debugPrint('[Check-out API] Starting check-out request');
      debugPrint('[Check-out API] Endpoint: $endpoint');
      debugPrint('[Check-out API] Job ID: ${activeJobApp.job.id}');
      debugPrint('[Check-out API] Job Title: ${activeJobApp.job.jobTitle}');
      debugPrint('[Check-out API] Current Application Status: ${activeJobApp.status}');
      debugPrint('[Check-out API] Job Date: ${activeJobApp.job.jobDate}');
      debugPrint('[Check-out API] Job End Time (from API): $jobEndTime');
      debugPrint('[Check-out API] Device Current Time (Local): $now');
      debugPrint('[Check-out API] Device Current Time (UTC): $nowUtc');
      debugPrint('[Check-out API] Device Timezone Offset: ${now.timeZoneOffset}');
      debugPrint('[Check-out API] Device Timezone Name: ${now.timeZoneName}');

      // Request device location for punch out
      final location = await _resolveDeviceLocation();
      final body = <String, dynamic>{};
      if (location != null) {
        body['punch_out_latitude'] = location.latitude.toString();
        body['punch_out_longitude'] = location.longitude.toString();
      } else {
        debugPrint('[Check-out API] Unable to retrieve location for punch out');
      }

      // Call punch-out API endpoint
      final response = await ApiClient.post(
        endpoint,
        token: token,
        body: body.isEmpty ? null : body,
      );

      debugPrint('[Check-out API] Response received');
      debugPrint('[Check-out API] Success: ${response.isSuccess}');
      debugPrint('[Check-out API] Status Code: ${response.statusCode}');
      debugPrint('[Check-out API] Message: ${response.message}');
      debugPrint('[Check-out API] Response Data: ${response.data}');

      if (response.isSuccess) {
        _isCheckedIn = false;
        _errorMessage = null;
        
        debugPrint('[Check-out API] Check-out successful');
        debugPrint('[Check-out API] Updating application status from "${activeJobApp.status}" to "Completed"');
        
        // Update application status to "Completed"
        _applicationStatuses[activeJobApp.job.id] = 'Completed';
        // Update the application in the list
        final index = _myApplications.indexWhere((app) => app.job.id == activeJobApp.job.id);
        if (index != -1) {
          _myApplications[index] = ApplicationData(
            job: activeJobApp.job,
            status: 'Completed',
            applicationId: activeJobApp.applicationId,
          );
        }
        
        _isCheckingOut = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('[Check-out API] Check-out failed: ${response.message}');
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to check out. Please try again.';
        _isCheckingOut = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('[Check-out API] Exception occurred: $e');
      debugPrint('[Check-out API] Stack trace: ${StackTrace.current}');
      _errorMessage = 'Failed to check out. Please try again.';
      _isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if check-out button should be shown for a job
  /// Returns true if:
  /// - Job date is today
  /// - User's application status is "In Progress"
  /// Note: Check-out button is shown immediately after check-in, regardless of end time
  bool shouldShowCheckOutButton(ApplicationData? application) {
    if (application == null) {
      return false;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if today is one of the job's scheduled days (job_day_dates or jobDate)
    if (!application.job.isDateScheduledFor(today)) {
      return false;
    }
    
    // Check application status (should be "In Progress")
    final status = application.status.toLowerCase();
    return status == 'in progress';
  }

  Future<Position?> _resolveDeviceLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[Location] Location services are disabled');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        debugPrint('[Location] Permission still denied after request');
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[Location] Permission denied forever - please open app settings');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      debugPrint('[Location] Obtained coordinates: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('[Location] Failed to get device location: $e');
      return null;
    }
  }

  /// Load user's jobs from /api/me/jobs and store in my applications list.
  /// 
  /// [forceRefresh] - If true, always fetch from API. If false and data exists, show cached data and refresh in background.
  Future<void> loadMyJobs({bool forceRefresh = false}) async {
    // Try to load from disk cache first (if not forcing refresh)
    if (!forceRefresh && _myApplications.isEmpty) {
      final cachedApplications = await CacheService.loadApplications();
      if (cachedApplications != null && cachedApplications.isNotEmpty) {
        try {
          _applicationStatuses.clear();
          _myApplications.clear();
          for (var application in cachedApplications) {
            final jobData = application['job'] as Map<String, dynamic>?;
            final jobId = jobData?['id']?.toString() ?? 
                         application['job_id']?.toString();
            final status = application['status']?.toString() ?? 
                          application['application_status']?.toString();
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
        } catch (e) {
          debugPrint('Failed to parse cached applications: $e');
        }
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
        debugPrint('[api/me/jobs] Authentication token is missing');
        _isLoadingApplications = false;
        notifyListeners();
        return;
      }

      final queryParams = {'per_page': '100'};
      debugPrint('[api/me/jobs] GET ${ApiEndpoints.getMyJobs}');
      debugPrint('[api/me/jobs] Query: $queryParams, forceRefresh: $forceRefresh');

      final response = await ApiClient.get(
        ApiEndpoints.getMyJobs,
        queryParameters: queryParams,
        token: token,
      );

      _isLoadingApplications = false;
      _hasLoadedApplications = true;

      debugPrint('[api/me/jobs] Response success: ${response.isSuccess}, statusCode: ${response.statusCode}');
      debugPrint('[api/me/jobs] Message: ${response.message}');

      if (response.isSuccess) {
        List<Map<String, dynamic>>? jobsList = response.getList<Map<String, dynamic>>('jobs');
        if (jobsList != null && jobsList.isNotEmpty) {
          debugPrint('[api/me/jobs] Parsing ${jobsList.length} jobs');
          _applicationStatuses.clear();
          _myApplications.clear();
          final applicationsForCache = <Map<String, dynamic>>[];

          for (var jobOrApplication in jobsList) {
            // /api/me/jobs returns flat job objects (no nested 'job'); support both shapes
            final jobData = jobOrApplication['job'] as Map<String, dynamic>? ?? jobOrApplication;
            final jobId = jobData['id']?.toString() ?? jobOrApplication['job_id']?.toString();
            // Use application_status for tab filtering; job 'status' (filled/open) is for JobModel only
            final status = jobOrApplication['application_status']?.toString() ?? 'Applied';
            final applicationId = jobOrApplication['id']?.toString() ?? '';

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
                debugPrint('[api/me/jobs] Failed to parse job: $e');
              }
            }
          }

          if (applicationsForCache.isNotEmpty) {
            await CacheService.saveApplications(applicationsForCache);
          }
          debugPrint('[api/me/jobs] Loaded ${_myApplications.length} jobs');
          notifyListeners();
        } else {
          debugPrint('[api/me/jobs] No jobs in response');
          _applicationStatuses.clear();
          _myApplications.clear();
          await CacheService.clearApplications();
          notifyListeners();
        }
      } else {
        debugPrint('[api/me/jobs] Request failed: ${response.message}');
      }
    } catch (e) {
      _isLoadingApplications = false;
      debugPrint('[api/me/jobs] Exception: $e');
      notifyListeners();
    }
  }

  /// Load user's applications to check application status.
  /// Delegates to loadMyJobs (GET /api/me/jobs).
  Future<void> loadMyApplications({bool forceRefresh = false}) async {
    return loadMyJobs(forceRefresh: forceRefresh);
  }

  /// Refresh my jobs in background without showing loading indicator (GET /api/me/jobs).
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
            final status = jobOrApplication['application_status']?.toString() ?? 'Applied';
            final applicationId = jobOrApplication['id']?.toString() ?? '';

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
                debugPrint('Background refresh parse error: $e');
              }
            }
          }

          if (applicationsForCache.isNotEmpty) {
            await CacheService.saveApplications(applicationsForCache);
          } else {
            await CacheService.clearApplications();
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[api/me/jobs] Background refresh failed: $e');
    }
  }

  /// Apply for a job
  Future<bool> applyForJob(String jobId) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication required. Please login again.';
        notifyListeners();
        return false;
      }

      // Call apply for job API endpoint
      final response = await ApiClient.post(
        ApiEndpoints.applyForJob(jobId),
        token: token,
      );

      if (response.isSuccess) {
        // Mark job as applied
        _applicationStatuses[jobId] = 'Applied';
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // Set error message from API response
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to apply for job. Please try again.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to submit application. Please try again.';
      notifyListeners();
      return false;
    }
  }
}

