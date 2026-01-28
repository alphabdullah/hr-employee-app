import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/job_viewmodel.dart';
import '../models/job_model.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../resources/components/job_card.dart';

/// Explore Screen View - Shows available job posts
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobViewModel>().loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Explore',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<JobViewModel>(
        builder: (context, viewModel, child) {
          // Initial loading state
          if (viewModel.isLoading && viewModel.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state with refresh capability
          if (viewModel.errorMessage != null && viewModel.jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => viewModel.loadJobs(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: ScreenUnitUtil.getFontSize(48),
                          color: AppColors.error,
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                        Text(
                          viewModel.errorMessage!,
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(16),
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(14),
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Empty state with refresh capability
          if (viewModel.jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => viewModel.loadJobs(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: ScreenUnitUtil.getFontSize(64),
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                        Text(
                          'No job posts available',
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(18),
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(14),
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Jobs list with pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => viewModel.loadJobs(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: ScreenUnitUtil.getSpacing(16),
                right: ScreenUnitUtil.getSpacing(16),
                top: ScreenUnitUtil.getSpacing(8),
                bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
              ),
              itemCount: viewModel.jobs.length,
              itemBuilder: (context, index) {
                final job = viewModel.jobs[index];
                return JobCard(
                  job: job,
                  showJobImage: true,
                  showJobStatus: true,
                  jobStatusText: _getStatusText(job.jobStatus),
                  jobStatusColor: _getStatusColor(job.jobStatus),
                  showSkillsCount: true,
                  showDuration: true,
                  showPostedDate: true,
                  onFormatDateTime: _formatDateTime,
                );
              },
            ),
          );
        },
      ),
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

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.active:
        return AppColors.success;
      case JobStatus.assigned:
        return AppColors.secondary;
      case JobStatus.open:
        return AppColors.success;
      case JobStatus.closed:
        return AppColors.error;
      case JobStatus.filled:
        return AppColors.accent;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'just now';
          }
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else {
        return '${_getMonthName(dateTime.month)} ${dateTime.day}';
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
