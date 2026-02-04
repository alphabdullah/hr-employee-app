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

  /// Register Step 1 - Create account & profile
  /// 
  /// **Method:** POST
  /// **Path:** /api/register/step-1
  /// **Auth:** Not required
  /// **Headers:** Content-Type: application/json, Accept: application/json
  /// 
  /// **Required Fields:**
  /// - name (string, max 255)
  /// - surname (string, max 255)
  /// - email (string, unique, valid email)
  /// - password (string, min 8, must match password_confirmation)
  /// - password_confirmation (string, same as password)
  /// 
  /// **Optional Fields:**
  /// - dob (string, date Y-m-d)
  /// - tel_no (string, max 50)
  /// - whatsapp_no (string, max 50)
  /// - address (string)
  /// - country (string, max 100)
  /// - city (string, max 100)
  /// - latitude (number, -90 to 90)
  /// - longitude (number, -180 to 180)
  /// - post_code (string, max 20)
  /// - nat_insurance_no (string, max 50)
  /// - nationality (string, max 100)
  /// - right_to_work_uk (boolean)
  /// - gender (string, max 50)
  /// - marital_status (string, max 50)
  /// - need_work_permit (boolean)
  /// - work_permit_expiry (string, date Y-m-d, if need_work_permit is true)
  /// - student_visa_hours_per_week (integer, 0-168)
  /// - prefer_contact (string: email | sms | both)
  /// - user_type (string: merchandisers | support_staff | drivers | team_leaders)
  /// 
  /// **Response:** Returns token for use in subsequent steps
  static const String registerStep1 = '/api/register/step-1';

  /// Register Step 2 - Compliance
  /// 
  /// **Method:** POST
  /// **Path:** /api/register/step-2
  /// **Auth:** Required (Bearer token from Step 1)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Optional Fields:**
  /// - is_driver (boolean)
  /// - driving_license_no (string, max 100, if is_driver is true)
  /// - driving_license_date (string, date Y-m-d, if is_driver is true)
  /// - own_car (boolean)
  /// - criminal_record (boolean)
  /// - criminal_record_type (string: spent | unspent, if criminal_record is true)
  /// - cscs (boolean)
  /// - sia (boolean)
  /// - mhe (boolean)
  /// - cis (boolean)
  /// - first_aid (boolean)
  /// - other_card_text (string, max 255)
  /// - registered_disabled (boolean)
  /// - disability_adjustments_text (string, if registered_disabled is true)
  /// - disability_details_text (string, if registered_disabled is true)
  static const String registerStep2 = '/api/register/step-2';

  /// Register Step 3 - Availability
  /// 
  /// **Method:** POST
  /// **Path:** /api/register/step-3
  /// **Auth:** Required (Bearer token from Step 1)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Optional Fields:**
  /// - day_days (array of string: monday, tuesday, wednesday, thursday, friday, saturday, sunday)
  /// - night_days (array of string: same values as day_days)
  static const String registerStep3 = '/api/register/step-3';

  /// Register Step 4 - Bank Details
  /// 
  /// **Method:** POST
  /// **Path:** /api/register/step-4
  /// **Auth:** Required (Bearer token from Step 1)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Optional Fields:**
  /// - account_holder (string, max 255)
  /// - bank_name (string, max 255)
  /// - bank_town (string, max 100)
  /// - account_number (string, max 50)
  /// - sort_code (string, max 20)
  static const String registerStep4 = '/api/register/step-4';

  /// Legacy register endpoint (deprecated - use registerStep1 instead)
  @Deprecated('Use registerStep1 instead')
  static const String register = '/register';

  /// Login with email and password
  /// 
  /// **Method:** POST
  /// **Path:** /api/login
  /// **Auth:** Not required
  /// 
  /// **Request Body:**
  /// - email (string)
  /// - password (string)
  /// 
  /// **Response:** Returns authentication token
  static const String login = '/api/login';

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

  /// Get authenticated user's complete profile data including all steps
  /// 
  /// **Method:** GET
  /// **Path:** /api/me
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Response:** Returns user data with nested profile, compliance, availability, and bank_detail objects
  static const String getMe = '/api/me';

  /// User - Update Step 1 (Profile)
  /// 
  /// **Method:** PUT
  /// **Path:** /api/me/step-1
  /// **Auth:** Required (Bearer token)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Required Fields:**
  /// - name (string, max 255)
  /// - surname (string, max 255)
  /// - email (string, unique except current user)
  /// 
  /// **Optional Fields:**
  /// - dob (string, date Y-m-d)
  /// - tel_no (string, max 50)
  /// - whatsapp_no (string, max 50)
  /// - address (string)
  /// - country (string, max 100)
  /// - city (string, max 100)
  /// - latitude (number, -90 to 90)
  /// - longitude (number, -180 to 180)
  /// - post_code (string, max 20)
  /// - nat_insurance_no (string, max 50)
  /// - nationality (string, max 100)
  /// - right_to_work_uk (boolean)
  /// - gender (string, max 50)
  /// - marital_status (string, max 50)
  /// - need_work_permit (boolean)
  /// - work_permit_expiry (string, date Y-m-d, if need_work_permit is true)
  /// - student_visa_hours_per_week (integer, 0-168)
  /// - password (string, min 8, use with password_confirmation)
  /// - password_confirmation (string, if password sent)
  /// - prefer_contact (string: email | sms | both)
  /// - user_type (string: merchandisers | support_staff | drivers | team_leaders)
  static const String updateProfileStep1 = '/api/me/step-1';

  /// User - Update Step 2 (Compliance)
  /// 
  /// **Method:** PUT
  /// **Path:** /api/me/step-2
  /// **Auth:** Required (Bearer token)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Optional Fields:**
  /// - is_driver (boolean)
  /// - driving_license_no (string, max 100, if is_driver is true)
  /// - driving_license_date (string, date Y-m-d, if is_driver is true)
  /// - own_car (boolean)
  /// - criminal_record (boolean)
  /// - criminal_record_type (string: spent | unspent, if criminal_record is true)
  /// - cscs, sia, mhe, cis, first_aid (boolean)
  /// - other_card_text (string, max 255)
  /// - registered_disabled (boolean)
  /// - disability_adjustments_text (string, if registered_disabled is true)
  /// - disability_details_text (string, if registered_disabled is true)
  static const String updateProfileStep2 = '/api/me/step-2';

  /// User - Update Step 3 (Availability)
  /// 
  /// **Method:** PUT
  /// **Path:** /api/me/step-3
  /// **Auth:** Required (Bearer token)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Optional Fields:**
  /// - day_days (array of string: monday, tuesday, wednesday, thursday, friday, saturday, sunday)
  /// - night_days (array of string: same values as day_days)
  static const String updateProfileStep3 = '/api/me/step-3';

  /// User - Update Step 4 (Bank Details)
  /// 
  /// **Method:** PUT
  /// **Path:** /api/me/step-4
  /// **Auth:** Required (Bearer token)
  /// **Headers:** Content-Type: application/json, Accept: application/json, Authorization: Bearer {token}
  /// 
  /// **Optional Fields:**
  /// - account_holder (string, max 255)
  /// - bank_name (string, max 255)
  /// - bank_town (string, max 100)
  /// - account_number (string, max 50)
  /// - sort_code (string, max 20)
  static const String updateProfileStep4 = '/api/me/step-4';

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
  static String punchIn(String id) => '/api/me/jobs/$id/punch-in';

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
  static String punchOut(String id) => '/api/me/jobs/$id/punch-out';

  /// Get authenticated user's jobs (my jobs list)
  /// 
  /// **Method:** GET
  /// **Path:** /api/me/jobs
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Response:** Returns jobs list with job title, client, dates, status, image
  static const String getMyJobs = '/api/me/jobs';

  /// Get authenticated user's attendance records
  /// 
  /// **Method:** GET
  /// **Path:** /api/me/attendance
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Response:** Returns attendance list with punch_in_at, punch_out_at, job details
  static const String getMyAttendance = '/api/me/attendance';

  /// Get authenticated user's earnings
  /// 
  /// **Method:** GET
  /// **Path:** /api/me/earnings
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Response:** Returns earnings data with per_job and overall totals
  static const String getMyEarnings = '/api/me/earnings';

  // ============================================================================
  // SKILLS MANAGEMENT ENDPOINTS
  // ============================================================================

  /// Get all available skills for dropdown
  /// 
  /// **Method:** GET
  /// **Path:** /skills
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 50)
  /// 
  /// **Note:** Supports pagination. Used for dropdown options like Plumber, Driver, Waiter, etc.
  static const String getAllSkills = '/skills';
  // ============================================================================
  // GROUP CHATS ENDPOINTS
  // ============================================================================

  /// Get all groups the authenticated user is a member of
  /// 
  /// **Method:** GET
  /// **Path:** /api/me/groups
  /// **Auth:** Required (Bearer token)
  /// 
  /// **Query Parameters:**
  /// - per_page (int, optional): Items per page (default: 15)
  /// 
  static const String getMyGroups = '/api/me/groups';
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
  static String getGroupChatMessages(String id) => '/api/me/groups/$id/messages';

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
  static String sendGroupChatMessage(String id) => '/api/me/groups/$id/messages';

  // ============================================================================
  // NOTIFICATIONS ENDPOINTS
  // ============================================================================

  /// Get all notifications for the authenticated employee
  /// Method: GET
  /// Path: /api/me/notifications
  /// Auth: Bearer
  /// Response: Returns notifications list with pagination
  static const String getNotifications = '/api/me/notifications';

  /// Mark a specific notification as read
  /// Method: POST
  /// Path: /api/me/notifications/:id/mark-read
  /// Auth: Bearer
  /// Response: {"message": "Marked as read."}
  static String markNotificationRead(String id) => '/api/me/notifications/$id/mark-read';

  /// Mark all notifications as read
  /// Method: POST
  /// Path: /api/me/notifications/mark-all-read
  /// Auth: Bearer
  /// Response: {"message": "All marked as read."}
  static const String markAllNotificationsRead = '/api/me/notifications/mark-all-read';

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
