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

                  // Job Description Section
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
                    widget.job.jobLocation,
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    widget.job.formattedDate,
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(12)),
                  _buildDetailRow(
                    Icons.access_time_outlined,
                    'Duration',
                    _buildDurationText(widget.job),
                  ),

                  SizedBox(height: ScreenUnitUtil.getSpacing(8)),

                  // Check-in or Check-out Button (if applicable)
                  Consumer<JobViewModel>(
                    builder: (context, viewModel, child) {
                      final applicationData = viewModel.getApplicationDataForJob(widget.job.id);
                      if (applicationData != null) {
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
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Apply Button or Application Status (hide when Check In/Check Out button is shown)
                  Consumer<JobViewModel>(
                    builder: (context, viewModel, child) {
                      final applicationData = viewModel.getApplicationDataForJob(widget.job.id);
                      final hasApplied = viewModel.hasAppliedToJob(widget.job.id);
                      final applicationStatus = viewModel.getApplicationStatus(widget.job.id);
                      
                      // Hide the status button if:
                      // 1. Check In button is shown (status is "Selected")
                      // 2. Check Out button is shown (status is "In Progress")
                      if (applicationData != null) {
                        final status = applicationData.status.toLowerCase();
                        final isInProgress = status == 'in progress';
                        final isSelected = status == 'selected';
                        final shouldShowCheckIn = !isInProgress && viewModel.shouldShowCheckInButton(applicationData);
                        final shouldShowCheckOut = isInProgress && viewModel.shouldShowCheckOutButton(applicationData);
                        
                        if ((isSelected && shouldShowCheckIn) || (isInProgress && shouldShowCheckOut)) {
                          return const SizedBox.shrink();
                        }
                      }
                      
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isApplying || hasApplied)
                              ? null
                              : () => _handleApply(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasApplied
                                ? _getStatusColor(applicationStatus)
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkPrimary
                                    : AppColors.secondary),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: ScreenUnitUtil.getSpacing(16),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ScreenUnitUtil.getSpacing(12),
                              ),
                            ),
                            elevation: hasApplied ? 0 : 2,
                          ),
                          child: _isApplying
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
                                      hasApplied
                                          ? _getStatusIcon(applicationStatus)
                                          : Icons.send_outlined,
                                      size: ScreenUnitUtil.getFontSize(20),
                                    ),
                                    SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                                    Text(
                                      hasApplied
                                          ? _getApplicationStatusText(applicationStatus)
                                          : 'Apply for Job',
                                      style: TextStyle(
                                        fontSize: ScreenUnitUtil.getFontSize(16),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
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
                    'Check In',
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
                    'Check Out',
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

