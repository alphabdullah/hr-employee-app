import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/earnings_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../utils/toast_message.dart';
import 'package:intl/intl.dart';

/// Earnings Screen - Displays user's earnings per job and overall totals
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    // Load earnings data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<EarningsViewModel>();
      viewModel.fetchEarnings(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<EarningsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.earnings == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.errorMessage != null && viewModel.earnings == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ScreenUnitUtil.getFontSize(64),
                      color: AppColors.error,
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.clearError();
                        viewModel.fetchEarnings(forceRefresh: true);
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final earnings = viewModel.earnings;
          if (earnings == null) {
            return Center(
              child: Text(
                'No earnings data available',
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(16),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final success = await viewModel.fetchEarnings(forceRefresh: true);
              if (!success && mounted && viewModel.errorMessage != null) {
                ToastMessage.showError(viewModel.errorMessage!, context);
              }
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Summary Card
                  _buildOverallSummaryCard(context, earnings.overall),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                  
                  // Per Job Earnings Section
                  Text(
                    'Per Job Earnings',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(20),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                  
                  if (earnings.perJob.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...earnings.perJob.map((job) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenUnitUtil.getSpacing(12)),
                      child: _buildJobEarningCard(context, job),
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallSummaryCard(BuildContext context, overall) {
    return Container(
      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Summary',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(18),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Hours',
                  _formatHours(overall.totalHours),
                  Icons.access_time,
                ),
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(16)),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Earnings',
                  _formatCurrency(overall.totalEarning),
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: ScreenUnitUtil.getFontSize(20),
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
            SizedBox(width: ScreenUnitUtil.getSpacing(4)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(12),
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildJobEarningCard(BuildContext context, job) {
    return Container(
      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Title
          Text(
            job.jobTitle,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
          
          // Date Range
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: ScreenUnitUtil.getFontSize(14),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(4)),
              Text(
                job.formattedDateRange,
                style: TextStyle(
                  fontSize: ScreenUnitUtil.getFontSize(14),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(12)),
          
          // Hours and Earnings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildJobStat(
                  context,
                  'Hours',
                  _formatHours(job.totalHours),
                ),
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(16)),
              Expanded(
                child: _buildJobStat(
                  context,
                  'Earnings',
                  _formatCurrency(job.totalEarning),
                  isEarning: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobStat(
    BuildContext context,
    String label,
    String value, {
    bool isEarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(12),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(16),
            fontWeight: FontWeight.w600,
            color: isEarning
                ? AppColors.success
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(32)),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: ScreenUnitUtil.getFontSize(64),
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
          Text(
            'No earnings data available',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(16),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    if (hours == 0) return '0 hrs';
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes min';
    }
    if (hours == hours.roundToDouble()) {
      return '${hours.round()} hrs';
    }
    return '${hours.toStringAsFixed(1)} hrs';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '£',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
