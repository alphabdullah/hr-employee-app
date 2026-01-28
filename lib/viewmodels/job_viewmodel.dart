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
      
      // Check if job date is today
      final jobDay = DateTime(
        app.job.jobDate.year,
        app.job.jobDate.month,
        app.job.jobDate.day,
      );
      
      return jobDay.isAtSameMomentAs(today);
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
    
    // Check if job date is today
    final jobDay = DateTime(
      application.job.jobDate.year,
      application.job.jobDate.month,
      application.job.jobDate.day,
    );
    
    if (!jobDay.isAtSameMomentAs(today)) {
      return false;
    }
    
    // Check application status (should be "In Progress" or "Selected")
    final status = application.status.toLowerCase();
    if (status != 'in progress' && status != 'selected') {
      return false;
    }
    
    // Check if start time exists
    if (application.job.durationStartTime == null || 
        application.job.durationStartTime!.isEmpty) {
      return false;
    }
    
    try {
      // Parse start time (format: "09:00" or "09:00:00")
      final startTimeParts = application.job.durationStartTime!.split(':');
      if (startTimeParts.length < 2) {
        return false;
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
      return false;
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
      
      // Exclude jobs that are shown in Active Job (today's Selected jobs)
      final jobDay = DateTime(
        app.job.jobDate.year,
        app.job.jobDate.month,
        app.job.jobDate.day,
      );
      
      // Don't include if it's today's job (already shown in Active Job)
      return !jobDay.isAtSameMomentAs(today);
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
    
    // Check if job date is today
    final jobDay = DateTime(
      application.job.jobDate.year,
      application.job.jobDate.month,
      application.job.jobDate.day,
    );
    
    if (!jobDay.isAtSameMomentAs(today)) {
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

  /// Load user's applications to check application status
  /// 
  /// [forceRefresh] - If true, always fetch from API. If false and data exists, show cached data and refresh in background.
  Future<void> loadMyApplications({bool forceRefresh = false}) async {
    // Try to load from disk cache first (if not forcing refresh)
    if (!forceRefresh && _myApplications.isEmpty) {
      final cachedApplications = await CacheService.loadApplications();
      if (cachedApplications != null && cachedApplications.isNotEmpty) {
        try {
          // Clear previous data
          _applicationStatuses.clear();
          _myApplications.clear();
          
          // Parse cached applications
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
          // Continue to refresh in background
        } catch (e) {
          debugPrint('Failed to parse cached applications: $e');
        }
      }
    }
    
    // If we have cached data (in-memory or disk) and not forcing refresh, refresh in background
    if (!forceRefresh && _hasLoadedApplications && _myApplications.isNotEmpty) {
      // Show cached data immediately (already in state)
      // Refresh in background without blocking UI
      _refreshApplicationsInBackground();
      return;
    }
    
    // First time loading or force refresh - show loading indicator
    _isLoadingApplications = true;
    notifyListeners();
    
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('[Job Applications API] Authentication token is missing');
        _isLoadingApplications = false;
        notifyListeners();
        return;
      }

      final queryParams = {'per_page': '100'};
      debugPrint('[Job Applications API] Starting load applications request');
      debugPrint('[Job Applications API] Endpoint: ${ApiEndpoints.getMyApplications}');
      debugPrint('[Job Applications API] Query Parameters: $queryParams');
      debugPrint('[Job Applications API] Force Refresh: $forceRefresh');

      // Call my applications API endpoint
      final response = await ApiClient.get(
        ApiEndpoints.getMyApplications,
        queryParameters: queryParams, // Get more applications
        token: token,
      );

      _isLoadingApplications = false;
      _hasLoadedApplications = true;

      debugPrint('[Job Applications API] Response received');
      debugPrint('[Job Applications API] Success: ${response.isSuccess}');
      debugPrint('[Job Applications API] Status Code: ${response.statusCode}');
      debugPrint('[Job Applications API] Message: ${response.message}');

      if (response.isSuccess) {
        // Parse applications array from response
        // Try different possible keys: 'applications', 'data', or direct array
        List<Map<String, dynamic>>? applicationsList = 
            response.getList<Map<String, dynamic>>('applications') ??
            response.getList<Map<String, dynamic>>('data');
        
        if (applicationsList != null && applicationsList.isNotEmpty) {
          debugPrint('[Job Applications API] Found ${applicationsList.length} applications');
          
          // Clear previous data
          _applicationStatuses.clear();
          _myApplications.clear();
          
          // Prepare list for caching
          final applicationsForCache = <Map<String, dynamic>>[];
          
          // Parse each application
          for (var application in applicationsList) {
            // Handle nested job object or direct job_id field
            final jobData = application['job'] as Map<String, dynamic>?;
            final jobId = jobData?['id']?.toString() ?? 
                         application['job_id']?.toString();
            final status = application['status']?.toString() ?? 
                          application['application_status']?.toString();
            final applicationId = application['id']?.toString() ?? '';
            
            if (jobData != null && jobId != null && status != null) {
              try {
                // Parse job from application data
                final job = JobModel.fromJson(jobData);
                
                // Store application status mapping
                _applicationStatuses[jobId] = status;
                
                // Store full application data
                _myApplications.add(ApplicationData(
                  job: job,
                  status: status,
                  applicationId: applicationId,
                ));
                
                // Prepare for caching (store original application data)
                applicationsForCache.add(application);
              } catch (e) {
                debugPrint('Failed to parse job from application: $e');
              }
            }
          }
          
          // Save to cache
          if (applicationsForCache.isNotEmpty) {
            await CacheService.saveApplications(applicationsForCache);
            debugPrint('[Job Applications API] Saved ${applicationsForCache.length} applications to cache');
          }
          
          notifyListeners();
          debugPrint('[Job Applications API] Successfully loaded ${_myApplications.length} applications');
          debugPrint('[Job Applications API] Application statuses: $_applicationStatuses');
        } else {
          // No applications found
          debugPrint('[Job Applications API] No applications found in response');
          _applicationStatuses.clear();
          _myApplications.clear();
          // Clear cache if no applications
          await CacheService.clearApplications();
          notifyListeners();
        }
      } else {
        debugPrint('[Job Applications API] Failed to load applications');
        debugPrint('[Job Applications API] Error message: ${response.message}');
        debugPrint('[Job Applications API] Error response data: ${response.data}');
      }
    } catch (e) {
      _isLoadingApplications = false;
      debugPrint('[Job Applications API] Exception occurred: $e');
      debugPrint('[Job Applications API] Stack trace: ${StackTrace.current}');
      notifyListeners();
    }
  }

  /// Refresh applications in background without showing loading indicator
  Future<void> _refreshApplicationsInBackground() async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      if (token == null || token.isEmpty) {
        return;
      }

      // Call my applications API endpoint silently
      final response = await ApiClient.get(
        ApiEndpoints.getMyApplications,
        queryParameters: {'per_page': '100'},
        token: token,
      );

      if (response.isSuccess) {
        // Parse applications array from response
        List<Map<String, dynamic>>? applicationsList = 
            response.getList<Map<String, dynamic>>('applications') ??
            response.getList<Map<String, dynamic>>('data');
        
        if (applicationsList != null) {
          // Clear previous data
          _applicationStatuses.clear();
          _myApplications.clear();
          
          // Prepare list for caching
          final applicationsForCache = <Map<String, dynamic>>[];
          
          // Parse each application
          for (var application in applicationsList) {
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
                
                // Prepare for caching
                applicationsForCache.add(application);
              } catch (e) {
                debugPrint('Failed to parse job from application: $e');
              }
            }
          }
          
          // Save to cache
          if (applicationsForCache.isNotEmpty) {
            await CacheService.saveApplications(applicationsForCache);
          } else {
            await CacheService.clearApplications();
          }
          
          // Update UI with fresh data
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail background refresh
      debugPrint('Background refresh failed: $e');
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

