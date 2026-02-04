import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_viewmodel.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';

import '../viewmodels/chat_detail_viewmodel.dart';
import '../views/chat_detail_screen.dart';

/// Chat Screen View with groups list
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadGroups();
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
          'Groups',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return RefreshIndicator(
              onRefresh: viewModel.loadGroups,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
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

          // ✅ Groups empty state
          if (viewModel.groups.isEmpty) {
            return RefreshIndicator(
              onRefresh: viewModel.loadGroups,
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 500,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No groups yet'),
                        SizedBox(height: 6),
                        Text('Join or create a group to start chatting'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // ✅ Groups list
          return RefreshIndicator(
            onRefresh: viewModel.loadGroups,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.groups.length,
              padding: EdgeInsets.only(
                top: ScreenUnitUtil.getSpacing(8),
                bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
              ),
              itemBuilder: (context, index) {
                final group = viewModel.groups[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    child: Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                  ),
                  title: Text(
                    group.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUnitUtil.getFontSize(16),
                    ),
                  ),
                  subtitle: Text(
                    group.subtitle, // e.g. "5 members • London"
                    style: TextStyle(
                      fontSize: ScreenUnitUtil.getFontSize(13),
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // trailing: group.lastMessagePreview != null
                  //     ? Container(
                  //         padding: EdgeInsets.symmetric(
                  //           horizontal: ScreenUnitUtil.getSpacing(8),
                  //           vertical: ScreenUnitUtil.getSpacing(4),
                  //         ),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.secondary,
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: Text(
                  //           group.membersCount.toString(),
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: ScreenUnitUtil.getFontSize(12),
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       )
                  //     : null,
                 // In chat_screen.dart → onTap of group ListTile
// onTap: () {
//   Navigator.pushNamed(
//     context,
//     '/chat-detail',           // or RouteNames.chatDetail
//     arguments: {
//       'groupId': group.id,
//       'groupName': group.name,
//       // optional: 'region': group.region,
//     },
//   );
// }

// Example: in your ChatScreen or group list onTap
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider<ChatDetailViewModel>(
        // Create ONLY ONCE per groupId
        create: (_) => ChatDetailViewModel(group.id),
        child: ChatDetailScreen(
          groupId: group.id,
          groupName: group.name,
        ),
      ),
    ),
  );
},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
