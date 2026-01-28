import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/chat_detail_viewmodel.dart';
import '../models/chat_model.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';
import 'chat_detail_screen.dart';

/// Chat Screen View with chat list
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
      context.read<ChatViewModel>().loadChats();
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
          'Chat',
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
              onRefresh: () => viewModel.loadChats(),
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

          if (viewModel.chats.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => viewModel.loadChats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: ScreenUnitUtil.getFontSize(64),
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        SizedBox(height: ScreenUnitUtil.getSpacing(16)),
                        Text(
                          'No chats yet',
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

          return RefreshIndicator(
            onRefresh: () => viewModel.loadChats(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.chats.length,
              padding: EdgeInsets.only(
                top: ScreenUnitUtil.getSpacing(8),
                bottom: MediaQuery.of(context).padding.bottom + ScreenUnitUtil.getSpacing(8),
              ),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                indent: ScreenUnitUtil.getSpacing(68),
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final chat = viewModel.chats[index];
                return _buildChatItem(context, chat);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => ChatDetailViewModel(chat.id),
              child: ChatDetailScreen(chat: chat),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUnitUtil.getSpacing(16),
          vertical: ScreenUnitUtil.getSpacing(12),
        ),
        child: Row(
          children: [
            _buildJobAvatar(chat.jobImage ?? chat.avatarUrl),
            SizedBox(width: ScreenUnitUtil.getSpacing(12)),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.jobTitle,
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(16),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ScreenUnitUtil.getSpacing(2)),
                      Text(
                        '${chat.memberCount} members',
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(12),
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: ScreenUnitUtil.getFontSize(14),
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUnitUtil.getSpacing(8),
                            vertical: ScreenUnitUtil.getSpacing(4),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(
                              ScreenUnitUtil.getSpacing(12),
                            ),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(12),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobAvatar(String? imageUrl) {
    final radius = ScreenUnitUtil.getWidth(28);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        backgroundImage: NetworkImage(_getImageUrl(imageUrl)),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondary.withOpacity(0.1),
      child: Icon(
        Icons.work_outline,
        size: ScreenUnitUtil.getFontSize(28),
        color: AppColors.secondary,
      ),
    );
  }

  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return 'https://hr.aibitsoft.cloud$imageUrl';
  }
}
