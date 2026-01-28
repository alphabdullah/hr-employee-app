/// API Endpoints Constants
/// Complete API collection for HR App Backend - Employee Management System
/// 
/// Base URL: http://localhost:8000
/// All endpoints are organized by category for easy reference

class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://hr.aibitsoft.cloud';

  // ============================================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================================

  /// Register a new employee account
  /// 
  /// **Method:** POST
  /// **Path:** /register
  /// **Auth:** Not required
  /// 
  /// **Required Fields:**
  /// - full_name (string)
  /// - email (string, unique)
  /// - phone_number (string)
  /// - residential_address (string)
  /// - skills (array, min: 1, max: 8)
  /// - password (string, max 8 chars, must contain uppercase, lowercase, digit, special char)
  /// 
  /// **Password Rules:**
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 numeric digit
  /// - At least 1 special character (@$!%*?&#)
  /// - Maximum 8 characters
  static const String register = '/register';

  /// Login with email and password
  /// 
  /// **Method:** POST
  /// **Path:** /login
  /// **Auth:** Not required
  /// 
  /// **Request Body:**
  /// - email (string)
  /// - password (string)
  /// 
  /// **Response:** Returns authentication token
  static const String login = '/login';

  /// Logout and invalidate the current authentication token
  /// 
  /// **Method:** POST
  /// **Path:** /logout
  /// **Auth:** Required (Bearer token)
  static const String logout = '/logout';

  // ============================================================================
  // EMAIL VERIFICATION ENDPOINTS
  // ============================================================================

  /// Verify employee email address using the link sent in verification email
  /// 
  /// **Method:** GET
  /// **Path:** /email/verify/:id/:hash
  /// **Auth:** Not required
  /// 
  /// **Path Parameters:**
  /// - id (string): Employee ID
  /// - hash (string): Email verification hash
  /// 
  /// **Note:** This link is typically accessed from the email sent after registration
  static String verifyEmail(String id, String hash) => '/email/verify/$id/$hash';

  /// Resend email verification link
  /// 
  /// **Method:** POST
  /// **Path:** /email/verification-notification
  /// **Auth:** Required (Bearer token)
  static const String resendVerificationEmail = '/email/verification-notification';

  // ============================================================================
  // PASSWORD RESET ENDPOINTS
  // ============================================================================

  /// Request a password reset link
  /// 
  /// **Method:** POST
  /// **Path:** /forgot-password
  /// **Auth:** Not required
  /// 
  /// **Request Body:**
  /// - email (string)
  /// 
  /// **Note:** The link will be sent to the registered email address
  static const String forgotPassword = '/forgot-password';

  /// Reset password using the token received in email
  /// 
  /// **Method:** POST
  /// **Path:** /reset-password
  /// **Auth:** Not required
  /// 
  /// **Required Fields:**
  /// - email (string)
  /// - token (string, from email)
  /// - password (string, must follow password rules)
  /// 
  /// **Password Rules:**
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 numeric digit
  /// - At least 1 special character (@$!%*?&#)
  /// - Maximum 8 characters
  static const String resetPassword = '/reset-password';

  // ============================================================================
  // PROFILE MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Get the authenticated employee's profile information
  /// 
  /// **Method:** GET
  /// **Path:** /profile
  /// **Auth:** Required (Bearer token)
  static const String getProfile = '/profile';

  /// Update profile information (without image)
  /// 
  /// **Method:** PUT
  /// **Path:** /profile
  /// **Auth:** Required (Bearer token)
  /// **Content-Type:** application/json
  /// 
  /// **Updatable Fields (all optional):**
  /// - full_name (string)
  /// - email (string, must remain unique)
  /// - skills (array, min: 1, max: 8)
  /// 
  /// **Note:** Skills list replaces old values, it does not append
  static const String updateProfile = '/profile';

  /// Update profile with profile image upload
  /// 
  /// **Method:** PUT
  /// **Path:** /profile
  /// **Auth:** Required (Bearer token)
  /// **Content-Type:** multipart/form-data
  /// 
  /// **Form Data Fields:**
  /// - full_name (string, optional)
  /// - email (string, optional)
  /// - skills (string, JSON array as string, optional)
  /// - profile_image (file, optional)
  /// 
  /// **File Requirements:**
  /// - Image file (jpeg, png, jpg, gif)
  /// - Maximum size: 2MB
  static const String updateProfileWithImage = '/profile';

  // ============================================================================
  // ADMIN ENDPOINTS
  // ============================================================================

  /// Get admin dashboard with statistics
  /// 
  /// **Method:** GET
  /// **Path:** /admin/dashboard
  /// **Auth:** Required (Bearer token, Admin role)
  static const String adminDashboard = '/admin/dashboard';

  /// Get all employees (users only)
  /// 
  /// **Method:** GET
  /// **Path:** /admin/employees
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 15)
  /// 
  /// **Note:** Supports pagination
  static const String getAllEmployees = '/admin/employees';

  /// Get a specific employee by ID
  /// 
  /// **Method:** GET
  /// **Path:** /admin/employees/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Path Parameters:**
  /// - id (string): Employee ID
  static String getEmployeeById(String id) => '/admin/employees/$id';

  /// Update employee details
  /// 
  /// **Method:** PUT
  /// **Path:** /admin/employees/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** application/json
  /// 
  /// **Path Parameters:**
  /// - id (string): Employee ID
  /// 
  /// **Updatable Fields (all optional):**
  /// - full_name (string)
  /// - email (string)
  /// - phone_number (string)
  /// - residential_address (string)
  /// - skills (array)
  /// - status (string): "Active" or "Inactive"
  static String updateEmployee(String id) => '/admin/employees/$id';

  /// Update employee status (Active/Inactive)
  /// 
  /// **Method:** PATCH
  /// **Path:** /admin/employees/:id/status
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** application/json
  /// 
  /// **Path Parameters:**
  /// - id (string): Employee ID
  /// 
  /// **Request Body:**
  /// - status (string): "Active" or "Inactive"
  static String updateEmployeeStatus(String id) => '/admin/employees/$id/status';

  /// Delete an employee
  /// 
  /// **Method:** DELETE
  /// **Path:** /admin/employees/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Path Parameters:**
  /// - id (string): Employee ID
  static String deleteEmployee(String id) => '/admin/employees/$id';

  // ============================================================================
  // JOBS ENDPOINTS
  // ============================================================================

  /// Get all jobs visible to employees
  /// 
  /// **Method:** GET
  /// **Path:** /jobs
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Query Parameters:**
  /// - status (string, optional): Filter by status - "Open" or "Closed" (default: "Open")
  /// - per_page (int, optional): Items per page (default: 15)
  /// 
  /// **Note:** 
  /// - Only shows 'Open' jobs by default
  /// - Jobs with status 'Filled' are never displayed
  /// - Supports pagination and status filtering (Open/Closed only)
  static const String getAllJobs = '/jobs';

  /// Get a specific job by ID
  /// 
  /// **Method:** GET
  /// **Path:** /jobs/:id
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Note:** Only accessible if job status is not 'Filled'
  static String getJobById(String id) => '/jobs/$id';

  /// Create a new job posting (Admin only)
  /// 
  /// **Method:** POST
  /// **Path:** /admin/jobs
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** multipart/form-data
  /// 
  /// **Required Fields:**
  /// - job_title (string)
  /// - job_description (string)
  /// - number_of_workers_required (int, min: 1)
  /// - job_location (string)
  /// - job_duration (string): Time range (e.g., "9am to 9pm")
  /// - job_date (string): Date in YYYY-MM-DD format (must be today or future date)
  /// 
  /// **Optional:**
  /// - job_image (file): Image file, max 2MB
  /// 
  /// **Note:** Job will be created with status 'Open'
  static const String createJob = '/admin/jobs';

  /// Update a job posting (Admin only)
  /// 
  /// **Method:** PUT
  /// **Path:** /admin/jobs/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** application/json
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Updatable Fields (all optional):**
  /// - job_title (string)
  /// - job_description (string)
  /// - number_of_workers_required (int)
  /// - job_location (string)
  /// - job_duration (string)
  /// - job_date (string): YYYY-MM-DD format
  /// - status (string): "Open", "Closed", or "Filled"
  static String updateJob(String id) => '/admin/jobs/$id';

  /// Delete a job posting (Admin only)
  /// 
  /// **Method:** DELETE
  /// **Path:** /admin/jobs/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  static String deleteJob(String id) => '/admin/jobs/$id';

  /// Apply for an open job
  /// 
  /// **Method:** POST
  /// **Path:** /jobs/:id/apply
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Note:** 
  /// - Employees can apply only once per job
  /// - Cannot apply if already assigned to another job on the same day
  /// - Application status will be 'Applied' and timestamp will be recorded
  static String applyForJob(String id) => '/jobs/$id/apply';

  /// Punch in (start job) for a selected employee
  /// 
  /// **Method:** POST
  /// **Path:** /jobs/:id/punch-in
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Note:**
  /// - Only employees with application status 'Selected' for this job can punch in
  /// - Punch-in is allowed only once per job, only on the job date
  /// - Only allowed between the job's duration_start_time and 1 hour after start
  /// - Employee must not have another active job 'In Progress' on the same day
  /// - On success, application status is updated to 'In Progress' and 'punch_in_at' timestamp is recorded
  static String punchIn(String id) => '/jobs/$id/punch-in';

  /// Punch out (complete job) for an employee
  /// 
  /// **Method:** POST
  /// **Path:** /jobs/:id/punch-out
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Note:**
  /// - Only employees with application status 'In Progress' and a recorded punch_in_at can punch out
  /// - Punch-out is allowed only once per job, only on the job date
  /// - Only allowed at or after the job's duration_end_time (not before)
  /// - On success, application status is updated to 'Completed' and 'punch_out_at' timestamp is recorded
  /// - Punch-out is mandatory for job closure
  static String punchOut(String id) => '/jobs/$id/punch-out';

  /// Get all job applications submitted by the authenticated employee
  /// 
  /// **Method:** GET
  /// **Path:** /my-applications
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 15)
  /// 
  /// **Note:**
  /// - Returns full job details including job title, job location, job description, job duration, job date, job image
  /// - Includes application status (Applied, Selected, In Progress, Completed, Rejected)
  /// - Supports pagination
  static const String getMyApplications = '/my-applications';

  /// Get all applications for a specific job (Admin only)
  /// 
  /// **Method:** GET
  /// **Path:** /admin/jobs/:id/applications
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 15)
  /// 
  /// **Note:**
  /// - Returns employee profile (full_name, email, phone_number, profile_image), skills, residential_address
  /// - Includes application status and past job completion count
  /// - Supports pagination
  static String getJobApplications(String id) => '/admin/jobs/$id/applications';

  /// Select employees for a job (Admin only)
  /// 
  /// **Method:** POST
  /// **Path:** /admin/jobs/:id/select-employees
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** application/json
  /// 
  /// **Path Parameters:**
  /// - id (string): Job ID
  /// 
  /// **Request Body:**
  /// - employee_ids (array): Array of employee IDs to select
  /// 
  /// **Note:**
  /// - Validates that selection count doesn't exceed required workers
  /// - Validates that employee skills match job requirements
  /// - Updates application status to 'Selected'
  /// - Job status is updated to 'Assigned' when required number is reached
  static String selectEmployeesForJob(String id) => '/admin/jobs/$id/select-employees';

  // ============================================================================
  // SKILLS MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Get all available skills for dropdown (Admin only)
  /// 
  /// **Method:** GET
  /// **Path:** /admin/skills
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 50)
  /// 
  /// **Note:** Supports pagination. Used for dropdown options like Plumber, Driver, Waiter, etc.
  static const String getAllSkills = '/skills';

  /// Create a new skill (Admin only)
  /// 
  /// **Method:** POST
  /// **Path:** /admin/skills
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** application/json
  /// 
  /// **Request Body:**
  /// - name (string): Skill name (e.g., "Plumber", "Driver", "Waiter")
  /// - description (string, optional): Skill description
  /// 
  /// **Note:** Used for dropdown options in job creation and employee profiles
  static const String createSkill = '/admin/skills';

  /// Update a skill (Admin only)
  /// 
  /// **Method:** PUT
  /// **Path:** /admin/skills/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// **Content-Type:** application/json
  /// 
  /// **Path Parameters:**
  /// - id (string): Skill ID
  /// 
  /// **Request Body:**
  /// - name (string, optional): Updated skill name
  /// - description (string, optional): Updated skill description
  static String updateSkill(String id) => '/admin/skills/$id';

  /// Delete a skill (Admin only)
  /// 
  /// **Method:** DELETE
  /// **Path:** /admin/skills/:id
  /// **Auth:** Required (Bearer token, Admin role)
  /// 
  /// **Path Parameters:**
  /// - id (string): Skill ID
  static String deleteSkill(String id) => '/admin/skills/$id';

  // ============================================================================
  // GROUP CHATS ENDPOINTS
  // ============================================================================

  /// Get all group chats the authenticated user is a member of
  /// 
  /// **Method:** GET
  /// **Path:** /group-chats
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 15)
  /// 
  /// **Note:**
  /// - Group chats are automatically created when a job is fully assigned
  /// - Returns group chat details, job information, member count, and whether user can send messages
  /// - Supports pagination
  static const String getMyGroupChats = '/group-chats';

  /// Get all messages for a specific group chat
  /// 
  /// **Method:** GET
  /// **Path:** /group-chats/:id/messages
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Path Parameters:**
  /// - id (string): Group Chat ID
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 50)
  /// 
  /// **Note:**
  /// - Only accessible to group members
  /// - Returns messages with sender information and timestamps
  /// - Supports pagination
  static String getGroupChatMessages(String id) => '/group-chats/$id/messages';

  /// Send a message to a group chat
  /// 
  /// **Method:** POST
  /// **Path:** /group-chats/:id/messages
  /// **Auth:** Required (Bearer token)
  /// **Content-Type:** application/json
  /// 
  /// **Path Parameters:**
  /// - id (string): Group Chat ID
  /// 
  /// **Request Body:**
  /// - message (string): Message content (max 5000 characters)
  /// 
  /// **Note:**
  /// - Only group members can send messages
  /// - Employees cannot send messages if the job is Closed or Filled (admin can always send)
  static String sendGroupChatMessage(String id) => '/group-chats/$id/messages';

  // ============================================================================
  // NOTIFICATIONS ENDPOINTS
  // ============================================================================

  /// Get all notifications for the authenticated employee
  /// Method: GET
  /// Path: /notifications
  /// Auth: Bearer
  static const String getNotifications = '/notifications';

  /// Mark a specific notification as read
  /// Method: POST
  /// Path: /notifications/:id/read
  /// Auth: Bearer
  static String markNotificationRead(String id) => '/notifications/$id/read';

  /// Mark all notifications as read
  /// Method: POST
  /// Path: /notifications/read-all
  /// Auth: Bearer
  static const String markAllNotificationsRead = '/notifications/read-all';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Build full URL from endpoint path
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Build URL with query parameters
  static String buildUrlWithQuery(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    final url = buildUrl(endpoint);
    if (queryParameters == null || queryParameters.isEmpty) {
      return url;
    }

    final queryString = queryParameters.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    return queryString.isNotEmpty ? '$url?$queryString' : url;
  }
}

/// API Request Methods
class ApiMethod {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';
}

/// API Response Status Codes
class ApiStatusCode {
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int unprocessableEntity = 422;
  static const int serverError = 500;
}

/// Content Types
class ApiContentType {
  static const String json = 'application/json';
  static const String formData = 'multipart/form-data';
  static const String urlEncoded = 'application/x-www-form-urlencoded';
}
