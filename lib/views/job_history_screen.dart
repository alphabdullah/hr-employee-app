import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/job_viewmodel.dart';
import '../models/job_model.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../resources/components/job_card.dart';

/// Job History Screen - Shows all job history
class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<JobViewModel>();
      viewModel.loadMyJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Job History',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<JobViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingApplications) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get all applications and sort by date (most recent first)
          final allApplications = List.from(viewModel.allApplications);
          allApplications.sort((a, b) => b.job.jobDate.compareTo(a.job.jobDate));

          if (allApplications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => viewModel.loadMyJobs(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: ScreenUnitUtil.getFontSize(64),
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                        Text(
                          'No job history available',
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(18),
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

          return RefreshIndicator(
            onRefresh: () => viewModel.loadMyApplications(forceRefresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: ScreenUnitUtil.getSpacing(16),
                right: ScreenUnitUtil.getSpacing(16),
                top: ScreenUnitUtil.getSpacing(8),
                bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
              ),
              itemCount: allApplications.length,
              itemBuilder: (context, index) {
                final application = allApplications[index];
                return JobCard(
                  job: application.job,
                  applicationStatus: application.status,
                  showJobImage: true,
                  showJobStatus: true,
                  jobStatusText: _getStatusText(application.job.jobStatus),
                  jobStatusColor: _getStatusColor(application.job.jobStatus),
                  onGetApplicationStatusColor: _getApplicationStatusColor,
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

  Color _getApplicationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return AppColors.accent;
      case 'selected':
        return AppColors.success;
      case 'in progress':
        return AppColors.secondary;
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.accent;
    }
  }
}
