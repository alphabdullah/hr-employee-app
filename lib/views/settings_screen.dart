import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import '../services/api_client.dart';
import '../services/api_endpoints.dart';
import '../services/auth_service.dart';
import '../utils/toast_message.dart';

/// Settings Screen View
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUnitUtil.getSpacing(8),
        ),
        children: [
          // // Profile Section
          // _buildSettingsItem(
          //   context: context,
          //   icon: Icons.person_outline,
          //   title: 'Profile',
          //   subtitle: 'View and edit your profile',
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => const ProfileScreen(),
          //       ),
          //     );
          //   },
          // ),
          Divider(
            height: 1,
            thickness: 1,
            indent: ScreenUnitUtil.getSpacing(16),
            endIndent: ScreenUnitUtil.getSpacing(16),
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.edit_outlined,
            title: 'Edit Registration Profile',
            subtitle: 'Update compliance, availability or bank info',
            onTap: () {
              AppRouter.pushNamed(context, RouteNames.editProfile);
            },
          ),
          
          Divider(
            height: 1,
            thickness: 1,
            indent: ScreenUnitUtil.getSpacing(16),
            endIndent: ScreenUnitUtil.getSpacing(16),
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          
          // Job History Section
          _buildSettingsItem(
            context: context,
            icon: Icons.history_outlined,
            title: 'Job History',
            subtitle: 'View all your job history',
            onTap: () {
              AppRouter.pushNamed(
                context,
                RouteNames.jobHistory,
              );
            },
          ),
          
          Divider(
            height: 1,
            thickness: 1,
            indent: ScreenUnitUtil.getSpacing(16),
            endIndent: ScreenUnitUtil.getSpacing(16),
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          
          // Theme Mode Section
          Consumer<SettingsViewModel>(
            builder: (context, viewModel, child) {
              return _buildThemeModeSection(context, viewModel);
            },
          ),
          
          Divider(
            height: 1,
            thickness: 1,
            indent: ScreenUnitUtil.getSpacing(16),
            endIndent: ScreenUnitUtil.getSpacing(16),
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          
          // Logout Section
          _buildSettingsItem(
            context: context,
            icon: Icons.logout_outlined,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            iconColor: AppColors.error,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUnitUtil.getSpacing(16),
          vertical: ScreenUnitUtil.getSpacing(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(8)),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.secondary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  ScreenUnitUtil.getSpacing(8),
                ),
              ),
              child: Icon(
                icon,
                size: ScreenUnitUtil.getFontSize(24),
                color: iconColor ?? AppColors.secondary,
              ),
            ),
            SizedBox(width: ScreenUnitUtil.getSpacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(16),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ScreenUnitUtil.getFontSize(24),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUnitUtil.getSpacing(16),
        vertical: ScreenUnitUtil.getSpacing(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(8)),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ScreenUnitUtil.getSpacing(8),
                  ),
                ),
                child: Icon(
                  Icons.brightness_6_outlined,
                  size: ScreenUnitUtil.getFontSize(24),
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Mode',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(16),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      'Choose your preferred theme',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUnitUtil.getSpacing(16)),
          Row(
            children: [
              Expanded(
                child: _buildThemeModeOption(
                  context: context,
                  viewModel: viewModel,
                  mode: ThemeMode.light,
                  label: 'Light',
                  icon: Icons.light_mode_outlined,
                ),
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(8)),
              Expanded(
                child: _buildThemeModeOption(
                  context: context,
                  viewModel: viewModel,
                  mode: ThemeMode.dark,
                  label: 'Dark',
                  icon: Icons.dark_mode_outlined,
                ),
              ),
              SizedBox(width: ScreenUnitUtil.getSpacing(8)),
              Expanded(
                child: _buildThemeModeOption(
                  context: context,
                  viewModel: viewModel,
                  mode: ThemeMode.system,
                  label: 'System',
                  icon: Icons.brightness_auto_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption({
    required BuildContext context,
    required SettingsViewModel viewModel,
    required ThemeMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = viewModel.themeMode == mode;

    return InkWell(
      onTap: () {
        viewModel.updateThemeMode(mode);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUnitUtil.getSpacing(12),
          horizontal: ScreenUnitUtil.getSpacing(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            ScreenUnitUtil.getSpacing(8),
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: ScreenUnitUtil.getFontSize(24),
              color: isSelected
                  ? AppColors.secondary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(height: ScreenUnitUtil.getSpacing(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUnitUtil.getFontSize(12),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.secondary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _handleLogout(context);
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      
      // Call logout API endpoint if token exists (fire and forget)
      if (token != null && token.isNotEmpty) {
        // Call logout API endpoint (no body needed, just Bearer token)
        // Don't await - logout locally regardless of API response
        ApiClient.post(
          ApiEndpoints.logout,
          token: token,
        ).catchError((error) {
          // Silently handle API errors - we'll logout locally anyway
        });
      }
      
      // Always clear local authentication data immediately
      await AuthService.logout();
      
      // Navigate to login screen immediately (don't wait for API)
      if (context.mounted) {
        // Use rootNavigator to ensure we clear all routes
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
        
        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            ToastMessage.showSuccess('Logged out successfully', context);
          }
        });
      }
    } catch (e) {
      // Error occurred, but still logout locally
      await AuthService.logout();
      
      if (context.mounted) {
        // Navigate to login screen
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          RouteNames.login,
          (route) => false,
        );
        
        // Show message after navigation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            ToastMessage.showInfo('Logged out', context);
          }
        });
      }
    }
  }
}

