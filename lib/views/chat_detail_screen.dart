import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_detail_viewmodel.dart';
import '../models/message_model.dart';
import '../utils/screen_unit_util.dart';
import '../resources/app_colors.dart';

/// Chat Detail Screen View for group conversations
class ChatDetailScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const ChatDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  // We'll create the viewmodel here
  late final ChatDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    // Create the viewmodel instance once
    _viewModel = ChatDetailViewModel(widget.groupId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start loading messages
      _viewModel.loadGroupMessages().then((_) {
        _scrollToBottom();
        // Start polling for new messages
        _viewModel.startPolling();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose(); // important: clean up the viewmodel (this will stop polling)
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return ChangeNotifierProvider<ChatDetailViewModel>.value(
      value: _viewModel,  // ← this makes Consumer and context.read work
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.groupName),  // simple & clean
        ),
        body: Consumer<ChatDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Messages list with pull-to-refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => viewModel.loadGroupMessages(forceRefresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUnitUtil.getSpacing(16),
                        vertical: ScreenUnitUtil.getSpacing(8),
                      ),
                      itemCount: viewModel.messages.length,
                      itemBuilder: (context, index) {
                        final message = viewModel.messages[index];
                        return _buildMessageBubble(context, message);
                      },
                    ),
                  ),
                ),
                // Message input
                _buildMessageInput(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildMessageBubble(BuildContext context, MessageModel message) {
    final isMe = message.isSentByMe;

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUnitUtil.getSpacing(12)),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar and message for received messages (left side)
          if (!isMe) ...[
            _buildAvatar(message.senderProfileImage, false),
            SizedBox(width: ScreenUnitUtil.getSpacing(8)),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUnitUtil.getSpacing(16),
                  vertical: ScreenUnitUtil.getSpacing(10),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurface.withOpacity(0.8)
                      : AppColors.secondaryHover,
                  borderRadius: BorderRadius.circular(
                    ScreenUnitUtil.getSpacing(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(10),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Message and avatar for sent messages (right side)
          if (isMe) ...[
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUnitUtil.getSpacing(16),
                  vertical: ScreenUnitUtil.getSpacing(10),
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(
                    ScreenUnitUtil.getSpacing(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(10),
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: ScreenUnitUtil.getSpacing(8)),
            _buildAvatar(message.senderProfileImage, true),
          ],
        ],
      ),
    );
  }
// Inside build() → the input part

Widget _buildMessageInput(BuildContext context, ChatDetailViewModel viewModel) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: ScreenUnitUtil.getSpacing(16),
      vertical: ScreenUnitUtil.getSpacing(8),
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: viewModel.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(24)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ScreenUnitUtil.getSpacing(16),
                  vertical: ScreenUnitUtil.getSpacing(12),
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              // onSubmitted: (value) async {
              //   await viewModel.sendMessage();
              //   _scrollToBottom();
              // },
            onSubmitted: (value) async {
  await viewModel.sendMessage();
  _scrollToBottom();
},
            ),
          ),
          SizedBox(width: ScreenUnitUtil.getSpacing(8)),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              // onPressed: () async {
              //   await viewModel.sendMessage();
              //   _scrollToBottom();
              // },
              onPressed: () async {
  await viewModel.sendMessage();
  _scrollToBottom();
},

            ),
          ),
        ],
      ),
    ),
  );
}

  String _formatMessageTime(DateTime time) {
    // Convert UTC time to local time
    final localTime = time.toLocal();
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Widget _buildAvatar(String? profileImageUrl, bool isMe) {
    final radius = ScreenUnitUtil.getWidth(16);
    
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        backgroundImage: NetworkImage(_getImageUrl(profileImageUrl)),
        onBackgroundImageError: (exception, stackTrace) {
          // Image failed to load - will show background color only
        },
        // Don't set child here to avoid icon overlay on successful image load
      );
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: isMe
          ? (Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkPrimary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1))
          : AppColors.secondary.withOpacity(0.1),
      child: _buildAvatarIcon(isMe),
    );
  }

  Widget _buildAvatarIcon(bool isMe) {
    return Icon(
      Icons.person,
      size: ScreenUnitUtil.getFontSize(16),
      color: isMe
          ? (Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkPrimary
              : AppColors.primary)
          : AppColors.secondary,
    );
  }

  String _getImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    } else {
      // Prepend base URL for relative paths
      return 'https://hr.aibitsoft.cloud$imageUrl';
    }
  }

  // Widget _buildJobImage(String? imageUrl) {
  //   final radius = ScreenUnitUtil.getWidth(20);
  //   if (imageUrl != null && imageUrl.isNotEmpty) {
  //     return CircleAvatar(
  //       radius: radius,
  //       backgroundColor: AppColors.secondary.withOpacity(0.1),
  //       backgroundImage: NetworkImage(_getImageUrl(imageUrl)),
  //       onBackgroundImageError: (_, __) {},
  //     );
  //   }

  //   return CircleAvatar(
  //     radius: radius,
  //     backgroundColor: AppColors.secondary.withOpacity(0.1),
  //     child: Icon(
  //       Icons.work_outline,
  //       size: ScreenUnitUtil.getFontSize(20),
  //       color: AppColors.secondary,
  //     ),
  //   );
  // }

  // void _showParticipantsDialog(BuildContext context, ChatDetailViewModel viewModel) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(ScreenUnitUtil.getSpacing(20)),
  //       ),
  //     ),
  //     builder: (context) => DraggableScrollableSheet(
  //       initialChildSize: 0.7,
  //       minChildSize: 0.5,
  //       maxChildSize: 0.95,
  //       expand: false,
  //       builder: (context, scrollController) => Column(
  //         children: [
  //           // Handle bar
  //           Container(
  //             margin: EdgeInsets.only(top: ScreenUnitUtil.getSpacing(12)),
  //             width: ScreenUnitUtil.getWidth(40),
  //             height: ScreenUnitUtil.getHeight(4),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
  //               borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(2)),
  //             ),
  //           ),
  //           // Title
  //           Padding(
  //             padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(16)),
  //             child: Row(
  //               children: [
  //                 Text(
  //                   'Participants',
  //                   style: TextStyle(
  //                     fontSize: ScreenUnitUtil.getFontSize(20),
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 SizedBox(width: ScreenUnitUtil.getSpacing(8)),
  //                 Container(
  //                   padding: EdgeInsets.symmetric(
  //                     horizontal: ScreenUnitUtil.getSpacing(8),
  //                     vertical: ScreenUnitUtil.getSpacing(4),
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: AppColors.secondary.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(12)),
  //                   ),
  //                   child: Text(
  //                     '${viewModel.participants.length}',
  //                     style: TextStyle(
  //                       fontSize: ScreenUnitUtil.getFontSize(14),
  //                       fontWeight: FontWeight.w600,
  //                       color: AppColors.secondary,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Divider(height: 1),
  //           // Participants list
  //           Expanded(
  //             child: ListView.builder(
  //               controller: scrollController,
  //               padding: EdgeInsets.symmetric(
  //                 vertical: ScreenUnitUtil.getSpacing(8),
  //               ),
  //               itemCount: viewModel.participants.length,
  //               itemBuilder: (context, index) {
  //                 final participant = viewModel.participants[index];
  //                 final fullName = participant['full_name']?.toString() ?? 'Unknown';
  //                 final email = participant['email']?.toString() ?? '';
  //                 final profileImage = participant['profile_image'];
  //                 final role = participant['role']?.toString() ?? 'member';
  //                 final String? profileImageUrl;
  //                 if (profileImage == null || profileImage == 'null' || profileImage.toString().isEmpty) {
  //                   profileImageUrl = null;
  //                 } else {
  //                   profileImageUrl = profileImage.toString();
  //                 }
                  
  //                 return ListTile(
  //                   leading: _buildParticipantAvatar(profileImageUrl),
  //                   title: Text(
  //                     fullName,
  //                     style: TextStyle(
  //                       fontSize: ScreenUnitUtil.getFontSize(16),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                   subtitle: email.isNotEmpty
  //                       ? Text(
  //                           email,
  //                           style: TextStyle(
  //                             fontSize: ScreenUnitUtil.getFontSize(14),
  //                             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  //                           ),
  //                         )
  //                       : null,
  //                   trailing: role == 'admin'
  //                       ? Container(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: ScreenUnitUtil.getSpacing(8),
  //                             vertical: ScreenUnitUtil.getSpacing(4),
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: AppColors.secondary.withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
  //                           ),
  //                           child: Text(
  //                             'Admin',
  //                             style: TextStyle(
  //                               fontSize: ScreenUnitUtil.getFontSize(12),
  //                               fontWeight: FontWeight.w600,
  //                               color: AppColors.secondary,
  //                             ),
  //                           ),
  //                         )
  //                       : null,
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildParticipantAvatar(String? profileImageUrl) {
  //   if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
  //     return CircleAvatar(
  //       radius: ScreenUnitUtil.getWidth(24),
  //       backgroundColor: AppColors.secondary.withOpacity(0.1),
  //       backgroundImage: NetworkImage(_getImageUrl(profileImageUrl)),
  //       onBackgroundImageError: (exception, stackTrace) {
  //         // Image failed to load - will show background color only
  //       },
  //       // Don't set child here to avoid icon overlay on successful image load
  //     );
  //   }
    
  //   return CircleAvatar(
  //     radius: ScreenUnitUtil.getWidth(24),
  //     backgroundColor: AppColors.secondary.withOpacity(0.1),
  //     child: _buildParticipantAvatarIcon(),
  //   );
  // }

  // Widget _buildParticipantAvatarIcon() {
  //   return Icon(
  //     Icons.person,
  //     size: ScreenUnitUtil.getFontSize(24),
  //     color: AppColors.secondary,
  //   );
  // }
}

