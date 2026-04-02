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
        centerTitle: false,
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPerHourCard(context, earnings),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                  _buildWeekSelector(context, viewModel),
                  SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                  _buildDetailCard(context, earnings),
                  if (earnings.jobTitles.isNotEmpty) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(24)),
                    _buildJobTitlesSection(context, earnings.jobTitles),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerHourCard(BuildContext context, earnings) {
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
            'Per Hour Rate',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(14),
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(8)),
          Text(
            '£${earnings.perHourRate.toStringAsFixed(2)} / hr',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(28),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context, EarningsViewModel viewModel) {
    final selectedLabel =
        DateFormat('EEE dd MMM yyyy').format(viewModel.selectedWeekStart);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Week starting (Saturday): $selectedLabel',
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () => _selectWeekStart(context, viewModel),
          child: const Text('Change'),
        ),
      ],
    );
  }

  Future<void> _selectWeekStart(
    BuildContext context,
    EarningsViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedWeekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final saturday = EarningsViewModel.alignToSaturday(picked);
      await viewModel.fetchEarnings(
        forceRefresh: true,
        requestedDate: saturday,
      );
    }
  }

  Widget _buildDetailCard(BuildContext context, earnings) {
    return Container(
      padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDetailRow(context, 'Week label', earnings.weekLabel),
          const Divider(),
          _buildDetailRow(
            context,
            'Week start',
            DateFormat('dd MMM yyyy').format(earnings.weekStart),
          ),
          _buildDetailRow(
            context,
            'Week end',
            DateFormat('dd MMM yyyy').format(earnings.weekEnd),
          ),
          _buildDetailRow(context, 'Total hours', _formatHours(earnings.totalHours)),
          _buildDetailRow(
            context,
            'Total earning',
            _formatCurrency(earnings.totalEarning),
          ),
          _buildDetailRow(
            context,
            'Effective per hour',
            '£${earnings.effectivePerHour.toStringAsFixed(2)} / hr',
          ),
          _buildDetailRow(context, 'Jobs count', earnings.jobsCount.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUnitUtil.getSpacing(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(14),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTitlesSection(BuildContext context, List<String> jobTitles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jobs this week',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(12)),
        Wrap(
          spacing: ScreenUnitUtil.getSpacing(8),
          runSpacing: ScreenUnitUtil.getSpacing(8),
          children: jobTitles
              .map((title) => Chip(label: Text(title)))
              .toList(),
        ),
      ],
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
