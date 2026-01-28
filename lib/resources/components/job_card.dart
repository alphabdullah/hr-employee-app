import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../viewmodels/job_viewmodel.dart';
import '../../utils/screen_unit_util.dart';
import '../../resources/app_colors.dart';
import '../../routes/app_router.dart';
import '../../routes/route_names.dart';
import '../../utils/toast_message.dart';

/// Reusable Job Card Widget
/// Used in Home screen and Job History screen
class JobCard extends StatelessWidget {
  final JobModel job;
  final String? applicationStatus;
  final bool showJobImage;
  final bool showJobStatus;
  final bool showCheckInButton;
  final bool showCheckOutButton;
  final JobViewModel? viewModel;
  final ApplicationData? applicationData;
  final String? jobStatusText;
  final Color? jobStatusColor;
  final Color Function(String)? onGetApplicationStatusColor;
  final bool showSkillsCount;
  final bool showDuration;
  final bool showPostedDate;
  final String Function(String)? onFormatDateTime;

  const JobCard({
    super.key,
    required this.job,
    this.applicationStatus,
    this.showJobImage = false,
    this.showJobStatus = false,
    this.showCheckInButton = false,
    this.showCheckOutButton = false,
    this.viewModel,
    this.applicationData,
    this.jobStatusText,
    this.jobStatusColor,
    this.onGetApplicationStatusColor,
    this.showSkillsCount = false,
    this.showDuration = false,
    this.showPostedDate = false,
    this.onFormatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: showJobImage ? ScreenUnitUtil.getSpacing(16) : ScreenUnitUtil.getSpacing(12)),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
      ),
      child: InkWell(
        onTap: () {
          AppRouter.pushNamed(
            context,
            RouteNames.jobDetail,
            arguments: job,
          );
        },
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
        child: Padding(
          padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Image (if enabled - always show with placeholder for Explore screen)
              if (showJobImage) ...[
                Container(
                  height: ScreenUnitUtil.getHeight(180),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
                    color: AppColors.secondary.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
                    child: job.jobImageUrl != null
                        ? Image.network(
                            _getImageUrl(job.jobImageUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),
                  ),
                ),
                SizedBox(height: ScreenUnitUtil.getSpacing(12)),
              ],

              // Job Title and Status Chips
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.jobTitle,
                                style: TextStyle(
                                  fontSize: showJobImage 
                                      ? ScreenUnitUtil.getFontSize(18)
                                      : ScreenUnitUtil.getFontSize(16),
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (showJobStatus && jobStatusText != null && jobStatusColor != null) ...[
                              SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                              _buildStatusBadgeWithDot(context, jobStatusText!, jobStatusColor!),
                            ],
                          ],
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                        Wrap(
                          spacing: ScreenUnitUtil.getSpacing(8),
                          runSpacing: ScreenUnitUtil.getSpacing(8),
                          children: [
                            // Job Status Chip (for Job History screen - inline version)
                            if (showJobStatus && jobStatusText != null && jobStatusColor != null && !showJobImage)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUnitUtil.getSpacing(8),
                                  vertical: ScreenUnitUtil.getSpacing(4),
                                ),
                                decoration: BoxDecoration(
                                  color: jobStatusColor!.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    ScreenUnitUtil.getSpacing(4),
                                  ),
                                ),
                                child: Text(
                                  jobStatusText!,
                                  style: TextStyle(
                                    fontSize: ScreenUnitUtil.getFontSize(12),
                                    fontWeight: FontWeight.w500,
                                    color: jobStatusColor!,
                                  ),
                                ),
                              ),
                            // Application Status Chip
                            if (applicationStatus != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUnitUtil.getSpacing(8),
                                  vertical: ScreenUnitUtil.getSpacing(4),
                                ),
                                decoration: BoxDecoration(
                                  color: (onGetApplicationStatusColor != null
                                          ? onGetApplicationStatusColor!(applicationStatus!)
                                          : AppColors.accent)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    ScreenUnitUtil.getSpacing(4),
                                  ),
                                ),
                                child: Text(
                                  applicationStatus!,
                                  style: TextStyle(
                                    fontSize: ScreenUnitUtil.getFontSize(12),
                                    fontWeight: FontWeight.w500,
                                    color: onGetApplicationStatusColor != null
                                        ? onGetApplicationStatusColor!(applicationStatus!)
                                        : AppColors.accent,
                                  ),
                                ),
                              ),
                            // Required Skills Count Chip (for Explore screen)
                            if (showSkillsCount && job.requiredSkills != null && job.requiredSkills!.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUnitUtil.getSpacing(8),
                                  vertical: ScreenUnitUtil.getSpacing(4),
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    ScreenUnitUtil.getSpacing(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_outline,
                                      size: ScreenUnitUtil.getFontSize(12),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    SizedBox(width: ScreenUnitUtil.getSpacing(4)),
                                    Text(
                                      '${job.requiredSkills!.length} skill${job.requiredSkills!.length > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: ScreenUnitUtil.getFontSize(12),
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ScreenUnitUtil.getSpacing(12)),
              
              // Job Description
              Text(
                job.jobDescription,
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(14),
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: showJobImage ? 1.5 : 1.4,
                ),
                maxLines: showJobImage ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              // if (job.perHourPay != null) ...[
              //   SizedBox(height: ScreenUnitUtil.getSpacing(8)),
              //   Text(
              //     'USD ${_formatPay(job.perHourPay!)}/hr',
              //     style: TextStyle(
              //       fontSize: ScreenUnitUtil.getFontSize(14),
              //       fontWeight: FontWeight.w600,
              //       color: Theme.of(context).colorScheme.onSurface,
              //     ),
              //   ),
              // ],

              if (job.perHourPay != null && job.workMode != null) ...[
  SizedBox(height: ScreenUnitUtil.getSpacing(8)),
  Text(
    _buildPayText(job),
    style: TextStyle(
      fontSize: ScreenUnitUtil.getFontSize(14),
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
],

              
              SizedBox(height: ScreenUnitUtil.getSpacing(12)),
              
              // Job Details Row
              Row(
                children: [
                  _buildJobDetailItem(
                    context,
                    Icons.people_outline,
                    _buildWorkersText(job),
                  ),
                  SizedBox(width: ScreenUnitUtil.getSpacing(16)),
                  _buildJobDetailItem(
                    context,
                    Icons.location_on_outlined,
                    job.jobLocation,
                  ),
                ],
              ),
              
              SizedBox(height: ScreenUnitUtil.getSpacing(8)),
              
              // Job Date and Duration
              Row(
                children: [
                  _buildJobDetailItem(
                    context,
                    Icons.calendar_today_outlined,
                    job.formattedDate,
                  ),
                  if (showDuration && job.jobDuration != null && job.jobDuration!.isNotEmpty) ...[
                    SizedBox(width: ScreenUnitUtil.getSpacing(16)),
                    _buildJobDetailItem(
                      context,
                      Icons.access_time_outlined,
                      job.jobDuration!,
                    ),
                  ],
                ],
              ),
              
              // Posted Date (for Explore screen)
              if (showPostedDate && job.createdAt != null && onFormatDateTime != null) ...[
                SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                Row(
                  children: [
                    _buildJobDetailItem(
                      context,
                      Icons.schedule_outlined,
                      'Posted ${onFormatDateTime!(job.createdAt!)}',
                    ),
                  ],
                ),
              ],
              
              // Check-in or Check-out Button (only for Home screen)
              if ((showCheckInButton || showCheckOutButton) && viewModel != null && applicationData != null) ...[
                SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                if (showCheckOutButton)
                  _buildCheckOutButton(context, viewModel!, applicationData!)
                else
                  _buildCheckInButton(context, viewModel!, applicationData!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailItem(BuildContext context, IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: ScreenUnitUtil.getFontSize(16),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: ScreenUnitUtil.getSpacing(8)),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(14),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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

  String _buildWorkersText(JobModel job) {
    final remaining = job.numberOfWorkersRemaining;
    if (job.isFullyFilled) {
      return '${job.numberOfWorkersFilled}/${job.numberOfWorkersRequired} (Filled)';
    } else {
      return '${job.numberOfWorkersFilled}/${job.numberOfWorkersRequired} ($remaining left)';
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
            vertical: ScreenUnitUtil.getSpacing(14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
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
            vertical: ScreenUnitUtil.getSpacing(14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
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
    if (success && context.mounted) {
      await viewModel.loadMyApplications(forceRefresh: true);
      if (context.mounted) {
        ToastMessage.showSuccess('Successfully checked in!', context);
      }
    } else if (context.mounted) {
      ToastMessage.showError(viewModel.errorMessage ?? 'Failed to check in. Please try again.', context);
    }
  }

  Future<void> _handleCheckOut(BuildContext context, JobViewModel viewModel, ApplicationData applicationData) async {
    final success = await viewModel.checkOut();
    if (success && context.mounted) {
      await viewModel.loadMyApplications(forceRefresh: true);
      if (context.mounted) {
        ToastMessage.showSuccess('Successfully checked out!', context);
      }
    } else if (context.mounted) {
      ToastMessage.showError(viewModel.errorMessage ?? 'Failed to check out. Please try again.', context);
    }
  }

  /// Build status badge with dot indicator (for Explore screen)
  Widget _buildStatusBadgeWithDot(BuildContext context, String statusText, Color statusColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUnitUtil.getSpacing(8),
        vertical: ScreenUnitUtil.getSpacing(4),
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(6)),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScreenUnitUtil.getFontSize(6),
            height: ScreenUnitUtil.getFontSize(6),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScreenUnitUtil.getSpacing(4)),
          Text(
            statusText,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(11),
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
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

  /// Build image placeholder when no image is available
  Widget _buildImagePlaceholder() {
    return Container(
      height: ScreenUnitUtil.getHeight(180),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: ScreenUnitUtil.getFontSize(64),
              color: AppColors.secondary.withOpacity(0.4),
            ),
            SizedBox(height: ScreenUnitUtil.getSpacing(8)),
            Text(
              'No Image Available',
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(12),
                color: AppColors.secondary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
