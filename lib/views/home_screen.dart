import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/job_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import '../resources/components/job_card.dart';
import 'notification_screen.dart';

/// Home Screen View with carousel and job tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _carouselController;
  int _currentCarouselIndex = 0;

  // Demo cards for carousel
  final List<Map<String, dynamic>> _carouselCards = [
    {
      'title': 'Welcome to HR Portal',
      'subtitle': 'Manage your work efficiently',
      'color': AppColors.primary,
      'icon': Icons.work_outline,
    },
    {
      'title': 'New Opportunities',
      'subtitle': 'Explore available jobs',
      'color': AppColors.secondary,
      'icon': Icons.explore_outlined,
    },
    {
      'title': 'Stay Connected',
      'subtitle': 'Chat with your team',
      'color': AppColors.accent,
      'icon': Icons.chat_bubble_outline,
    },
    {
      'title': 'Track Progress',
      'subtitle': 'Monitor your assignments',
      'color': AppColors.success,
      'icon': Icons.trending_up_outlined,
    },
    {
      'title': 'Update Profile',
      'subtitle': 'Keep your info current',
      'color': AppColors.darkPrimary,
      'icon': Icons.person_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Active Job, Assigned Jobs
    _carouselController = PageController();
    
    // Load jobs, applications, and notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobViewModel = context.read<JobViewModel>();
      jobViewModel.loadJobs();
      jobViewModel.loadMyApplications(); // Load user's applications (needed for Active/Assigned tabs)
      context.read<NotificationViewModel>().loadNotifications();
    });

    // Auto-slide carousel every 3 seconds
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _carouselController.hasClients) {
        _currentCarouselIndex = (_currentCarouselIndex + 1) % _carouselCards.length;
        _carouselController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startCarouselTimer();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, notificationViewModel, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      size: ScreenUnitUtil.getFontSize(24),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: notificationViewModel,
                            child: const NotificationScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  if (notificationViewModel.unreadCount > 0)
                    Positioned(
                      right: ScreenUnitUtil.getWidth(8),
                      top: ScreenUnitUtil.getHeight(8),
                      child: Container(
                        padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(4)),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: ScreenUnitUtil.getWidth(16),
                          minHeight: ScreenUnitUtil.getWidth(16),
                        ),
                        child: Text(
                          notificationViewModel.unreadCount > 9
                              ? '9+'
                              : notificationViewModel.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUnitUtil.getFontSize(10),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildCarousel(),
            ),
            SliverPersistentHeader(
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkPrimary
                      : AppColors.secondary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  indicatorColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkPrimary
                      : AppColors.secondary,
                  labelStyle: TextStyle(
                    fontSize: ScreenUnitUtil.getFontSize(14),
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Active Job'),
                    Tab(text: 'Assigned Jobs'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveJobTab(),
            _buildAssignedJobsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        Container(
          height: ScreenUnitUtil.getHeight(180),
          margin: EdgeInsets.symmetric(
            vertical: ScreenUnitUtil.getSpacing(16),
            horizontal: ScreenUnitUtil.getSpacing(16),
          ),
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: _carouselCards.length,
            itemBuilder: (context, index) {
              final card = _carouselCards[index];
              return _buildCarouselCard(card);
            },
          ),
        ),
        // Carousel Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselCards.length,
            (index) => Container(
              width: ScreenUnitUtil.getWidth(8),
              height: ScreenUnitUtil.getWidth(8),
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUnitUtil.getSpacing(4),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == index
                    ? AppColors.secondary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
              ),
            ),
          ),
        ),
        SizedBox(height: ScreenUnitUtil.getSpacing(8)),
      ],
    );
  }

  Widget _buildCarouselCard(Map<String, dynamic> card) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUnitUtil.getSpacing(4),
      ),
      decoration: BoxDecoration(
        color: card['color'],
        borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(16)),
        boxShadow: [
          BoxShadow(
            color: card['color'].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(24)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card['title'],
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(20),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(8)),
                  Text(
                    card['subtitle'],
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(14),
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              card['icon'],
              size: ScreenUnitUtil.getFontSize(64),
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobTab() {
    return Consumer<JobViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || viewModel.isLoadingApplications) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeJobApplication = viewModel.activeJob;

        if (activeJobApplication == null) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadJobs();
              await viewModel.loadMyApplications();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildEmptyState('No active job for today'),
              ),
            ),
          );
        }

        // Check if check-in or check-out button should be shown
        final status = activeJobApplication.status.toLowerCase();
        final isInProgress = status == 'in progress';
        final shouldShowCheckIn = !isInProgress && viewModel.shouldShowCheckInButton(activeJobApplication);
        final shouldShowCheckOut = isInProgress && viewModel.shouldShowCheckOutButton(activeJobApplication);

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadJobs();
            await viewModel.loadMyApplications();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: ScreenUnitUtil.getSpacing(16),
              right: ScreenUnitUtil.getSpacing(16),
              top: ScreenUnitUtil.getSpacing(8),
              bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
            ),
            child: Column(
              children: [
                JobCard(
                  job: activeJobApplication.job,
                  applicationStatus: activeJobApplication.status,
                  showCheckInButton: shouldShowCheckIn,
                  showCheckOutButton: shouldShowCheckOut,
                  viewModel: viewModel,
                  applicationData: activeJobApplication,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignedJobsTab() {
    return Consumer<JobViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || viewModel.isLoadingApplications) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignedApplications = viewModel.allApplications;

        if (assignedApplications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadJobs();
              await viewModel.loadMyApplications();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmptyState('No jobs available'),
                ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadJobs();
            await viewModel.loadMyApplications();
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: ScreenUnitUtil.getSpacing(16),
              right: ScreenUnitUtil.getSpacing(16),
              top: ScreenUnitUtil.getSpacing(8),
              bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
            ),
            itemCount: assignedApplications.length,
            itemBuilder: (context, index) {
              final application = assignedApplications[index];
              return JobCard(
                job: application.job,
                applicationStatus: application.status,
                applicationData: application,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
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
            message,
            style: TextStyle(
              fontSize: ScreenUnitUtil.getFontSize(18),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

}

/// Delegate for TabBar in SliverPersistentHeader
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
