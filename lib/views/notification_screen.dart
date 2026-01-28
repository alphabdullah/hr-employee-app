import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../viewmodels/job_viewmodel.dart';
import '../models/notification_model.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import 'package:intl/intl.dart';

/// Notification Screen View
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.unreadCount > 0) {
                return TextButton(
                  onPressed: () => viewModel.markAllAsRead(),
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(14),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkPrimary
                          : AppColors.secondary,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: ScreenUnitUtil.getFontSize(48),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(16),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                  ElevatedButton(
                    onPressed: () => viewModel.loadNotifications(),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: ScreenUnitUtil.getFontSize(64),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(18),
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadNotifications(forceRefresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: ScreenUnitUtil.getSpacing(8),
                bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
              ),
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                return _buildNotificationItem(context, notification, viewModel);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    NotificationViewModel viewModel,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: ScreenUnitUtil.getSpacing(16)),
        color: AppColors.secondary,
        child: Icon(
          Icons.visibility_outlined,
          color: Colors.white,
          size: ScreenUnitUtil.getFontSize(24),
        ),
      ),
      confirmDismiss: (direction) async {
        // Mark as read via API
        await viewModel.markAsRead(notification.id);
        // Navigate to job detail if job_id is available
        if (notification.jobId != null && mounted) {
          final jobViewModel = context.read<JobViewModel>();
          final job = jobViewModel.getJobById(notification.jobId!);
          if (job != null && mounted) {
            AppRouter.pushNamed(
              context,
              RouteNames.jobDetail,
              arguments: job,
            );
          }
        }
        // Return false to prevent dismissal (keep notification in list)
        return false;
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            viewModel.markAsRead(notification.id);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUnitUtil.getSpacing(16),
            vertical: ScreenUnitUtil.getSpacing(12),
          ),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkPrimary.withOpacity(0.1)
                    : AppColors.secondary.withOpacity(0.05),
            border: Border(
              left: BorderSide(
                color: _getNotificationColor(notification.type),
                width: ScreenUnitUtil.getWidth(4),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(8)),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: ScreenUnitUtil.getFontSize(20),
                ),
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(12)),
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(16),
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: ScreenUnitUtil.getWidth(8),
                            height: ScreenUnitUtil.getWidth(8),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'job':
        return AppColors.secondary;
      case 'message':
        return AppColors.darkPrimary;
      case 'system':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'job':
        return Icons.work_outline;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}

