import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_model.dart';
import '../viewmodels/job_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../utils/toast_message.dart';

/// Job Detail Screen - Shows full job details and allows user to apply
class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Load user's applications to check if they've already applied
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobViewModel>().loadMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Job Details',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Job Image or Placeholder
            Container(
              height: ScreenUnitUtil.getHeight(250),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
              ),
              child: widget.job.jobImageUrl != null
                  ? Image.network(
                      _getImageUrl(widget.job.jobImageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    )
                  : _buildImagePlaceholder(),
            ),

            Padding(
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title
                  Text(
                    widget.job.jobTitle,
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(24),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // if (widget.job.perHourPay != null) ...[
                  //   SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                  //   Text(
                  //     'USD ${_formatPay(widget.job.perHourPay!)}/hr',
                  //     style: TextStyle(
                  //       fontSize: ScreenUnitUtil.getFontSize(16),
                  //       fontWeight: FontWeight.w600,
                  //       color: Theme.of(context).colorScheme.onSurface,
                  //     ),
                  //   ),
                  // ],


                  if (widget.job.perHourPay != null && widget.job.workMode != null) ...[
  SizedBox(height: ScreenUnitUtil.getSpacing(8)),
  Text(
    _buildPayText(widget.job),
    style: TextStyle(
      fontSize: ScreenUnitUtil.getFontSize(16),
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
],


                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                  // Status Badge and Application Status
                  Consumer<JobViewModel>(
                    builder: (context, viewModel, child) {
                      final applicationData = viewModel.getApplicationDataForJob(widget.job.id);
                      final status = applicationData?.status.toLowerCase();
                      final isInProgress = status == 'in progress';
                      final shouldShowCheckOut = isInProgress && applicationData != null && viewModel.shouldShowCheckOutButton(applicationData);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusBadge(widget.job.jobStatus),
                          // Show "Job In Progress" status when Check Out button is available
                          if (shouldShowCheckOut) ...[
                            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUnitUtil.getSpacing(16),
                                vertical: ScreenUnitUtil.getSpacing(12),
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor('in progress').withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  ScreenUnitUtil.getSpacing(8),
                                ),
                                border: Border.all(
                                  color: _getStatusColor('in progress').withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon('in progress'),
                                    size: ScreenUnitUtil.getFontSize(18),
                                    color: _getStatusColor('in progress'),
                                  ),
                                  SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                                  Text(
                                    'Job In Progress',
                                    style: TextStyle(
                                      fontSize: ScreenUnitUtil.getFontSize(14),
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor('in progress'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),

                  // Job Description Section (when available)
                  if (widget.job.jobDescription.isNotEmpty) ...[
                    _buildSectionTitle('Job Description'),
                    SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                    Text(
                      widget.job.jobDescription,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                  ],

                  // Client Section (from /api/me/jobs client object)
                  if (_hasClientInfo(widget.job)) ...[
                    _buildSectionTitle('Client'),
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildClientSection(context, widget.job),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                  ],

                  // Required Skills Section
                  if (widget.job.requiredSkills != null && widget.job.requiredSkills!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Required Skills'),
                        SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                        Wrap(
                          spacing: ScreenUnitUtil.getSpacing(8),
                          runSpacing: ScreenUnitUtil.getSpacing(8),
                          children: widget.job.requiredSkills!.map((skill) {
                            return Chip(
                              label: Text(
                                skill,
                                style: TextStyle(
                                  fontSize: ScreenUnitUtil.getFontSize(14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: AppColors.secondary.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: AppColors.secondary,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUnitUtil.getSpacing(12),
                                vertical: ScreenUnitUtil.getSpacing(4),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                      ],
                    ),

                  // Job Details Section
                  _buildSectionTitle('Job Details'),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),

                  _buildDetailRow(
                    Icons.people_outline,
                    'Workers Required',
                    _buildWorkersText(widget.job),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Location',
                    _buildLocationText(widget.job),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    widget.job.formattedDateRange ?? widget.job.formattedDate,
                  ),
                  if (widget.job.numberOfDays != null && widget.job.numberOfDays! > 0) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDetailRow(
                      Icons.date_range_outlined,
                      'Number of days',
                      '${widget.job.numberOfDays} day${widget.job.numberOfDays! > 1 ? 's' : ''}',
                    ),
                  ],
                  if (widget.job.shiftType != null && widget.job.shiftType!.isNotEmpty) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDetailRow(
                      Icons.wb_sunny_outlined,
                      'Shift',
                      _formatShiftType(widget.job.shiftType!),
                    ),
                  ],
                  if (widget.job.jobDuration != null && widget.job.jobDuration!.isNotEmpty) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Duration',
                      widget.job.jobDuration!,
                    ),
                  ] else ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Duration',
                      _buildDurationText(widget.job),
                    ),
                  ],
                  if (widget.job.jobDays != null && widget.job.jobDays!.isNotEmpty) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                    _buildJobDaysRow(context, widget.job.jobDays!),
                  ],

                  SizedBox(height: ScreenUnitUtil.getSpacing(8)),

                  // Punch In / Punch Out buttons (only on the job date)
                  Consumer<JobViewModel>(
                    builder: (context, viewModel, child) {
                      if (!_isJobDateToday()) return const SizedBox.shrink();
                      final applicationData = viewModel.getApplicationDataForJob(widget.job.id);
                      if (applicationData == null) return const SizedBox.shrink();
                      final status = applicationData.status.toLowerCase();
                      final isInProgress = status == 'in progress';
                      final shouldShowCheckIn = !isInProgress && viewModel.shouldShowCheckInButton(applicationData);
                      final shouldShowCheckOut = isInProgress && viewModel.shouldShowCheckOutButton(applicationData);
                      
                      if (shouldShowCheckIn || shouldShowCheckOut) {
                        return Column(
                          children: [
                            if (shouldShowCheckOut)
                              _buildCheckOutButton(context, viewModel, applicationData)
                            else
                              _buildCheckInButton(context, viewModel, applicationData),
                            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUnitUtil.getFontSize(18),
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: ScreenUnitUtil.getFontSize(20),
          color: AppColors.secondary,
        ),
        SizedBox(width: ScreenUnitUtil.getSpacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(12),
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(16),
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.active:
        return 'Active';
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.open:
        return 'Open';
      case JobStatus.closed:
        return 'Closed';
      case JobStatus.filled:
        return 'Filled';
    }
  }

  bool _hasClientInfo(JobModel job) {
    final c = job.createdBy;
    if (c == null) return false;
    return c['name'] != null && (c['name'] as String).isNotEmpty;
  }

  Widget _buildClientSection(BuildContext context, JobModel job) {
    final c = job.createdBy!;
    final name = c['name']?.toString() ?? '';
    final email = c['email']?.toString();
    final phone = c['phone']?.toString();
    final address = c['address']?.toString() ?? job.address;
    final postcode = c['postcode']?.toString() ?? job.postcode;
    final country = c['country']?.toString() ?? job.country;
    final region = c['region']?.toString() ?? job.region;
    final district = c['district']?.toString() ?? job.district;
    final parts = <Widget>[];
    if (name.isNotEmpty) {
      parts.add(_buildDetailRow(Icons.person_outline, 'Name', name));
      parts.add(SizedBox(height: ScreenUnitUtil.getSpacing(12)));
    }
    if (email != null && email.isNotEmpty) {
      parts.add(_buildDetailRow(Icons.email_outlined, 'Email', email));
      parts.add(SizedBox(height: ScreenUnitUtil.getSpacing(12)));
    }
    if (phone != null && phone.isNotEmpty) {
      parts.add(_buildDetailRow(Icons.phone_outlined, 'Phone', phone));
      parts.add(SizedBox(height: ScreenUnitUtil.getSpacing(12)));
    }
    final locParts = <String>[];
    if (address != null && address.isNotEmpty) locParts.add(address);
    if (region != null && region.isNotEmpty) locParts.add(region);
    if (district != null && district.isNotEmpty) locParts.add(district);
    if (postcode != null && postcode.isNotEmpty) locParts.add(postcode);
    if (country != null && country.isNotEmpty) locParts.add(country);
    if (locParts.isNotEmpty) {
      parts.add(_buildDetailRow(Icons.location_on_outlined, 'Address', locParts.join(', ')));
      parts.add(SizedBox(height: ScreenUnitUtil.getSpacing(12)));
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts..removeLast(),
    );
  }

  String _buildLocationText(JobModel job) {
    final parts = <String>[];
    if (job.address != null && job.address!.isNotEmpty) parts.add(job.address!);
    if (job.region != null && job.region!.isNotEmpty) parts.add(job.region!);
    if (job.district != null && job.district!.isNotEmpty) parts.add(job.district!);
    if (job.postcode != null && job.postcode!.isNotEmpty) parts.add(job.postcode!);
    if (job.country != null && job.country!.isNotEmpty) parts.add(job.country!);
    if (parts.isNotEmpty) return parts.join(', ');
    return job.jobLocation.isNotEmpty ? job.jobLocation : 'Not specified';
  }

  String _formatShiftType(String shiftType) {
    final s = shiftType.trim().toLowerCase();
    if (s == 'day') return 'Day shift';
    if (s == 'night') return 'Night shift';
    if (s.isEmpty) return shiftType;
    return shiftType[0].toUpperCase() + (shiftType.length > 1 ? shiftType.substring(1).toLowerCase() : '');
  }

  Widget _buildJobDaysRow(BuildContext context, List<String> jobDays) {
    final labels = jobDays.map((d) {
      final s = d.trim();
      if (s.isEmpty) return d;
      return s[0].toUpperCase() + (s.length > 1 ? s.substring(1).toLowerCase() : '');
    }).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.calendar_view_week_outlined,
          size: ScreenUnitUtil.getFontSize(20),
          color: AppColors.secondary,
        ),
        SizedBox(width: ScreenUnitUtil.getSpacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Job days',
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(12),
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: ScreenUnitUtil.getSpacing(8)),
              Wrap(
                spacing: ScreenUnitUtil.getSpacing(8),
                runSpacing: ScreenUnitUtil.getSpacing(8),
                children: labels.map((label) => Chip(
                  label: Text(label, style: TextStyle(fontSize: ScreenUnitUtil.getFontSize(14), fontWeight: FontWeight.w500)),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUnitUtil.getSpacing(12),
                    vertical: ScreenUnitUtil.getSpacing(4),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildWorkersText(JobModel job) {
    final remaining = job.numberOfWorkersRemaining;
    if (job.isFullyFilled) {
      return '${job.numberOfWorkersFilled}/${job.numberOfWorkersRequired} workers (Fully Filled)';
    } else {
      return '${job.numberOfWorkersFilled}/${job.numberOfWorkersRequired} workers ($remaining remaining)';
    }
  }

  String _buildDurationText(JobModel job) {
    if (job.durationStartTime != null && job.durationEndTime != null) {
      // Format time from "09:00" to "9:00 AM"
      final startTime = _formatTime(job.durationStartTime!);
      final endTime = _formatTime(job.durationEndTime!);
      return '$startTime - $endTime';
    } else if (job.jobDuration != null && job.jobDuration!.isNotEmpty) {
      return job.jobDuration!;
    } else {
      return 'Not specified';
    }
  }

  String _formatPay(double pay) {
    if (pay % 1 == 0) {
      return pay.toStringAsFixed(0);
    }
    return pay.toStringAsFixed(2);
  }
String _buildPayText(JobModel job) {
  final pay = _formatPay(job.perHourPay!);

  if (job.workMode == 'fixed') {
    return 'USD $pay / Job';
  }

  // default = per_hour
  return 'USD $pay / hr';
}

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {
      // If parsing fails, return original
    }
    return time;
  }

  Widget _buildStatusBadge(JobStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText = _getStatusText(status);

    switch (status) {
      case JobStatus.open:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case JobStatus.closed:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case JobStatus.filled:
        backgroundColor = AppColors.accent.withOpacity(0.1);
        textColor = AppColors.accent;
        break;
      case JobStatus.active:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case JobStatus.assigned:
        backgroundColor = AppColors.secondary.withOpacity(0.1);
        textColor = AppColors.secondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUnitUtil.getSpacing(12),
        vertical: ScreenUnitUtil.getSpacing(6),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScreenUnitUtil.getFontSize(8),
            height: ScreenUnitUtil.getFontSize(8),
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScreenUnitUtil.getSpacing(8)),
          Text(
            statusText,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(14),
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApply(BuildContext context, JobViewModel viewModel) async {
    setState(() {
      _isApplying = true;
    });

    final success = await viewModel.applyForJob(widget.job.id);

    if (mounted) {
      setState(() {
        _isApplying = false;
      });

      if (success) {
        // Reload applications to get updated status
        await viewModel.loadMyApplications();
        
        if (mounted) {
          ToastMessage.showSuccess(
            'Your application has been submitted successfully!',
            context,
          );
        }
      } else {
        // Show error message from API or default message
        if (mounted) {
          final errorMessage = viewModel.errorMessage ?? 
              'Failed to submit application. Please try again.';
          ToastMessage.showError(
            errorMessage,
            context,
          );
        }
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'applied':
        return AppColors.secondary;
      case 'selected':
        return AppColors.success;
      case 'in progress':
        return AppColors.accent;
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'applied':
        return Icons.check_circle_outline;
      case 'selected':
        return Icons.star;
      case 'in progress':
        return Icons.work_outline;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _getApplicationStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'applied':
        return 'Application Submitted';
      case 'selected':
        return 'Selected for Job';
      case 'in progress':
        return 'Job In Progress';
      case 'completed':
        return 'Job Completed';
      case 'rejected':
        return 'Application Rejected';
      default:
        return 'Application Submitted';
    }
  }

  bool _isJobDateToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.job.isDateScheduledFor(today);
  }

  Widget _buildCheckInButton(BuildContext context, JobViewModel viewModel, ApplicationData applicationData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isCheckingIn
            ? null
            : () => _handleCheckIn(context, viewModel, applicationData),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkPrimary
              : AppColors.secondary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: ScreenUnitUtil.getSpacing(16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
          ),
          elevation: 2,
        ),
        child: viewModel.isCheckingIn
            ? SizedBox(
                height: ScreenUnitUtil.getFontSize(20),
                width: ScreenUnitUtil.getFontSize(20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: ScreenUnitUtil.getFontSize(20),
                  ),
                  SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                  Text(
                    'Punch In',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCheckOutButton(BuildContext context, JobViewModel viewModel, ApplicationData applicationData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isCheckingOut
            ? null
            : () => _handleCheckOut(context, viewModel, applicationData),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: ScreenUnitUtil.getSpacing(16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
          ),
          elevation: 2,
        ),
        child: viewModel.isCheckingOut
            ? SizedBox(
                height: ScreenUnitUtil.getFontSize(20),
                width: ScreenUnitUtil.getFontSize(20),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: ScreenUnitUtil.getFontSize(20),
                  ),
                  SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                  Text(
                    'Punch Out',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleCheckIn(BuildContext context, JobViewModel viewModel, ApplicationData applicationData) async {
    final success = await viewModel.checkIn();
    
    if (success && mounted) {
      // Reload applications to get updated status
      await viewModel.loadMyApplications(forceRefresh: true);
      if (mounted) {
        ToastMessage.showSuccess('Successfully checked in!', context);
      }
    } else if (mounted) {
      final errorMessage = viewModel.errorMessage ?? 'Failed to check in. Please try again.';
      ToastMessage.showError(errorMessage, context);
    }
  }

  Future<void> _handleCheckOut(BuildContext context, JobViewModel viewModel, ApplicationData applicationData) async {
    final success = await viewModel.checkOut();
    
    if (success && mounted) {
      // Reload applications to get updated status
      await viewModel.loadMyApplications(forceRefresh: true);
      if (mounted) {
        ToastMessage.showSuccess('Successfully checked out!', context);
      }
    } else if (mounted) {
      final errorMessage = viewModel.errorMessage ?? 'Failed to check out. Please try again.';
      ToastMessage.showError(errorMessage, context);
    }
  }

  /// Build image placeholder when no image is available
  Widget _buildImagePlaceholder() {
    return Container(
      height: ScreenUnitUtil.getHeight(250),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: ScreenUnitUtil.getFontSize(80),
              color: AppColors.secondary.withOpacity(0.4),
            ),
            SizedBox(height: ScreenUnitUtil.getSpacing(12)),
            Text(
              'No Image Available',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(14),
                color: AppColors.secondary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get full image URL (handle relative paths)
  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    } else {
      // Prepend base URL for relative paths
      return 'https://hr.aibitsoft.cloud$imageUrl';
    }
  }
}

