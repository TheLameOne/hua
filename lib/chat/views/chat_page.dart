import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hua/chat/providers/chat_provider.dart';
import 'package:hua/theme/chat_theme.dart';
import 'package:hua/theme/app_colors.dart';
import 'package:hua/users_profile/views/user_profile_view.dart';
import 'package:hua/users_profile/providers/user_profile_provider.dart';
import 'package:hua/utils/profile_color.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/chat_message_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _showScrollToBottomButton = false;
  int _unreadMessageCount = 0;
  int _lastMessageCount = 0;

  // Message colors - using theme extension
  Color _getOwnMessageColor(BuildContext context) {
    final chatTheme = Theme.of(context).extension<ChatTheme>();
    return chatTheme?.myMessageColor ?? const Color(0xFF2196F3);
  }

  Color _getOtherMessageColor(BuildContext context) {
    final chatTheme = Theme.of(context).extension<ChatTheme>();
    return chatTheme?.otherMessageColor ?? const Color(0xFFE0E0E0);
  }

  @override
  void initState() {
    super.initState();
    _autoConnect();
    _messageFocusNode.addListener(_onFocusChange);
    _scrollController
        .addListener(_onScroll); // Fetch all users profile pictures
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().fetchAllUsersProfilePics().then((_) {
        // Preload profile images for better performance
        final userProfileProvider = context.read<UserProfileProvider>();
        final profilePics = userProfileProvider.usersProfilePics.values
            .where((profilePic) => profilePic?.isNotEmpty == true)
            .map((profilePic) => profilePic!)
            .toList();
        ProfileUtils.preloadProfileImages(profilePics);
      });
      _startProfilePicsRefreshTimer();
    });
  }

  Timer? _profilePicsRefreshTimer;

  void _startProfilePicsRefreshTimer() {
    // Refresh profile pictures every 5 minutes
    _profilePicsRefreshTimer =
        Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        context.read<UserProfileProvider>().fetchAllUsersProfilePics();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;

      if (isAtBottom && _showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = false;
          _unreadMessageCount = 0;
        });
      } else if (!isAtBottom &&
          !_showScrollToBottomButton &&
          _scrollController.position.maxScrollExtent > 200) {
        setState(() {
          _showScrollToBottomButton = true;
        });
      }
    }
  }

  void _onFocusChange() {
    if (_messageFocusNode.hasFocus) {
      _scrollToBottom();
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (!chatProvider.isConnected && !chatProvider.isConnecting) {
        _autoConnect();
      }
    }
  }

  void _autoConnect() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.connectWithStoredUsername();
    _lastMessageCount = chatProvider.messages.length;

    // Simple scroll to bottom after connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _profilePicsRefreshTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottomAnimated() {
    if (_scrollController.hasClients) {
      HapticFeedback.lightImpact();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() {
        _showScrollToBottomButton = false;
        _unreadMessageCount = 0;
      });
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  bool _isDateSeparatorMessage(String message) {
    // Check if the message is a date separator
    return message == 'Today' ||
        message == 'Yesterday' ||
        RegExp(r'^[A-Za-z]+ \d{1,2}, \d{4}$').hasMatch(message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.05),
              titleSpacing: 0,
              title: Row(
                children: [
                  // User avatar
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      // Navigate to my profile page
                      Navigator.pushNamed(context, '/profilepage');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Consumer<UserProfileProvider>(
                        builder: (context, userProfileProvider, child) {
                          final profilePic =
                              userProfileProvider.getProfilePicForUsername(
                                  chatProvider.username ?? 'User');
                          return ProfileUtils.buildUserChatAvatar(
                            username: chatProvider.username ?? 'User',
                            profilePic: profilePic,
                            radius: 22,
                            onTap: () {
                              Navigator.pushNamed(context, '/profilepage');
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  // Username and status
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to my profile page
                        Navigator.pushNamed(context, '/profilepage');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chatProvider.username ?? 'User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: chatProvider.isConnected
                                      ? Colors.green
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                chatProvider.isConnected
                                    ? 'Online'
                                    : 'Connecting...',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                // Add more action buttons here if needed
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color:
                        isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                  onPressed: () {
                    // Show options menu
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => _buildOptionsMenu(chatProvider),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: _buildMessageList(chatProvider),
                ),
                _buildMessageInput(chatProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            title: Text(
              'Reconnect',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await chatProvider.reconnect();
                if (mounted) {
                  Navigator.pop(context); // Dismiss loading dialog

                  _scrollToBottom();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Dismiss loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error reconnecting: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: isDark ? AppColors.errorDark : AppColors.errorLight,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet

              // Show a confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.cardDark : AppColors.cardLight,
                  title: Text(
                    'Confirm Logout',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'LOGOUT',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.errorDark
                              : AppColors.errorLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Get the auth provider
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  // Add timeout to disconnect operation
                  await Future.any([
                    chatProvider.disconnect(),
                    Future.delayed(const Duration(seconds: 3))
                  ]);

                  // Add timeout to clearing username
                  await Future.any([
                    chatProvider.clearStoredUsername(),
                    Future.delayed(const Duration(seconds: 2))
                  ]); // Add timeout to logout
                  await Future.any([
                    authProvider.logout(),
                    Future.delayed(const Duration(seconds: 2))
                  ]);

                  // Clear profile image caches for security
                  ProfileUtils.clearAllCaches();

                  // Navigate to splash screen
                  if (mounted) {
                    // Force navigation even if some operations failed
                    Navigator.of(context).pop(); // Dismiss loading dialog
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/splashpage',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print('Error during logout: $e');

                  // Ensure we always navigate away even if there's an error
                  if (mounted) {
                    Navigator.of(context).pop(); // Dismiss loading dialog

                    // Show error briefly
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Error during logout, but proceeding anyway')),
                    );

                    // Navigate away after showing error
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/splashpage',
                          (route) => false,
                        );
                      }
                    });
                  }
                }
              }
            },
          ),
          // ListTile(
          //   leading: Icon(
          //     Icons.people_outline,
          //     color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          //   ),
          //   title: Text(
          //     'Refresh Profile Pictures',
          //     style: TextStyle(
          //       color: isDark
          //           ? AppColors.textPrimaryDark
          //           : AppColors.textPrimaryLight,
          //     ),
          //   ),
          //   onTap: () async {
          //     Navigator.pop(context); // Close bottom sheet

          //     // Show loading indicator
          //     showDialog(
          //       context: context,
          //       barrierDismissible: false,
          //       builder: (context) => const Center(
          //         child: CircularProgressIndicator(),
          //       ),
          //     );

          //     try {
          //       await context
          //           .read<UserProfileProvider>()
          //           .fetchAllUsersProfilePics();
          //       if (mounted) {
          //         Navigator.pop(context); // Dismiss loading dialog
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('Profile pictures refreshed')),
          //         );
          //       }
          //     } catch (e) {
          //       if (mounted) {
          //         Navigator.pop(context); // Dismiss loading dialog
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //               content: Text('Error refreshing profile pictures: $e')),
          //         );
          //       }
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check for new messages and update unread count
    if (chatProvider.messages.length > _lastMessageCount) {
      final newMessageCount = chatProvider.messages.length - _lastMessageCount;

      // Only update unread count if user is not at bottom
      if (_showScrollToBottomButton) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _unreadMessageCount += newMessageCount;
          });
        });
      } else {
        // Auto-scroll to bottom if user is already at bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
      _lastMessageCount = chatProvider.messages.length;
    }

    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.primaryDark.withOpacity(0.2),
                          AppColors.accentDark.withOpacity(0.1)
                        ]
                      : [
                          AppColors.primaryLight.withOpacity(0.1),
                          AppColors.accentLight.withOpacity(0.1)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              chatProvider.isConnected
                  ? 'Start your conversation'
                  : 'Connecting to chat...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              chatProvider.isConnected
                  ? 'Send a message to begin'
                  : 'Please wait while we establish connection',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: chatProvider.messages.length,
          itemBuilder: (context, index) {
            final message = chatProvider.messages[index];
            return _buildMessageBubble(
                message, index == chatProvider.messages.length - 1);
          },
        ),
        // Scroll to bottom button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: 16,
          bottom: _showScrollToBottomButton ? 16 : -60,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showScrollToBottomButton ? 1.0 : 0.0,
            child: _buildScrollToBottomButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isLastMessage) {
    final isSystem = message.isSystemMessage;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isSystem) {
      // Check if this is a date separator message
      final isDateSeparator = _isDateSeparatorMessage(message.message);
      if (isDateSeparator) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Regular system message
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                      .extension<ChatTheme>()
                      ?.systemMessageColor ??
                  (isDark ? AppColors.cardDark : AppColors.cardLight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
                      .withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                        .extension<ChatTheme>()
                        ?.systemMessageTextColor ??
                    (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return _buildUserMessage(message);
  }

  Widget _buildUserMessage(ChatMessage message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentIndex = chatProvider.messages.indexOf(message);

    // Check if this is the first message in a group
    bool isFirstInGroup =
        _isFirstMessageInGroup(message, currentIndex, chatProvider.messages);

    // Check if this is the last message in a group
    bool isLastInGroup =
        _isLastMessageInGroup(message, currentIndex, chatProvider.messages);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 8 : 2,
        left: 0,
        right: 0,
      ),
      child: Row(
        mainAxisAlignment: message.isOwnMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar - only show for first message in group from others
          if (!message.isOwnMessage)
            Container(
              width: 46, // Increased from 36 to accommodate larger avatar
              child: isFirstInGroup
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 4),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to user profile view
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserProfileView(
                                username: message.username,
                              ),
                            ),
                          );
                        },
                        child: Consumer<UserProfileProvider>(
                          builder: (context, userProfileProvider, child) {
                            final profilePic = userProfileProvider
                                .getProfilePicForUsername(message.username);
                            return ProfileUtils.buildUserChatAvatar(
                              username: message.username,
                              profilePic: profilePic,
                              radius: 22,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileView(
                                      username: message.username,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox(width: 12), // Spacer for grouped messages
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 80,
              ),
              margin: const EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                color: message.isOwnMessage
                    ? _getOwnMessageColor(context)
                    : _getOtherMessageColor(context),
                borderRadius: _getMessageBorderRadius(
                    message, isFirstInGroup, isLastInGroup),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username - only show for first message in group from others
                    if (!message.isOwnMessage && isFirstInGroup)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          message.username,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: ProfileUtils.getUserColor(message.username),
                          ),
                        ),
                      ), // Message text and timestamp
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Message text - takes only needed space
                        Flexible(
                          child: Text(
                            message.message,
                            style: TextStyle(
                              color: message.isOwnMessage
                                  ? Theme.of(context)
                                          .extension<ChatTheme>()
                                          ?.myMessageTextColor ??
                                      Colors.white
                                  : Theme.of(context)
                                          .extension<ChatTheme>()
                                          ?.otherMessageTextColor ??
                                      (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Timestamp - fixed width at the end
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 8,
                                color: message.isOwnMessage
                                    ? Colors.white.withOpacity(0.8)
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (message.isOwnMessage) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.done_all,
                                size: 14,
                                color: AppColors.accentLight,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message.isOwnMessage) const SizedBox(width: 12),
        ],
      ),
    );
  }

  bool _isFirstMessageInGroup(
      ChatMessage message, int currentIndex, List<ChatMessage> messages) {
    if (currentIndex == 0) return true;

    final previousMessage = messages[currentIndex - 1];

    // Different user = start of new group
    if (previousMessage.username != message.username) return true;

    // System message before = start of new group
    if (previousMessage.isSystemMessage) return true;

    // Time gap > 5 minutes = start of new group
    final timeDifference =
        message.timestamp.difference(previousMessage.timestamp);
    if (timeDifference.inMinutes > 5) return true;

    return false;
  }

  bool _isLastMessageInGroup(
      ChatMessage message, int currentIndex, List<ChatMessage> messages) {
    if (currentIndex == messages.length - 1) return true;

    final nextMessage = messages[currentIndex + 1];

    // Different user = end of group
    if (nextMessage.username != message.username) return true;

    // System message after = end of group
    if (nextMessage.isSystemMessage) return true;

    // Time gap > 5 minutes = end of group
    final timeDifference = nextMessage.timestamp.difference(message.timestamp);
    if (timeDifference.inMinutes > 5) return true;

    return false;
  }

  BorderRadius _getMessageBorderRadius(
      ChatMessage message, bool isFirstInGroup, bool isLastInGroup) {
    const double radius = 24.0;
    const double smallRadius = 6.0;

    if (message.isOwnMessage) {
      // Own messages (right side)
      if (isFirstInGroup && isLastInGroup) {
        // Single message
        return BorderRadius.circular(radius);
      } else if (isFirstInGroup) {
        // First message in group - only bottom right non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(smallRadius),
        );
      } else if (isLastInGroup) {
        // Last message in group - only top right non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(smallRadius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      } else {
        // Middle message - top right and bottom right non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(smallRadius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(smallRadius),
        );
      }
    } else {
      // Other messages (left side)
      if (isFirstInGroup && isLastInGroup) {
        // Single message - bottom left non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(smallRadius),
          bottomRight: Radius.circular(radius),
        );
      } else if (isFirstInGroup) {
        // First message in group - only bottom left non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(smallRadius),
          bottomRight: Radius.circular(radius),
        );
      } else if (isLastInGroup) {
        // Last message in group - only top left non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      } else {
        // Middle message - top left and bottom left non-circular
        return const BorderRadius.only(
          topLeft: Radius.circular(smallRadius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(smallRadius),
          bottomRight: Radius.circular(radius),
        );
      }
    }
  }

  Widget _buildMessageInput(ChatProvider chatProvider) {
    final isConnected = chatProvider.isConnected;
    final isConnecting = chatProvider.isConnecting;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)
                .withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.inputBorderDark
                        : AppColors.inputBorderLight,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  enabled: isConnected,
                  decoration: InputDecoration(
                    hintText: isConnecting
                        ? 'Connecting...'
                        : isConnected
                            ? ' Type a message'
                            : ' Disconnected',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.inputFocusedBorderDark
                            : AppColors.inputFocusedBorderLight,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(chatProvider),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Beautiful gradient-inspired send button
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.gradientStartDark, AppColors.gradientEndDark]
                      : [
                          AppColors.primaryLight,
                          Color(0xFF7FDEFF)
                        ], // Ultra Violet to Pale Azure
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: isConnected ? () => _sendMessage(chatProvider) : null,
                  child: Center(
                    child: isConnecting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(ChatProvider chatProvider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      chatProvider.sendMessage(message);
      _messageController.clear();
      FocusScope.of(context).requestFocus(_messageFocusNode);

      // Always scroll to bottom and reset unread count when sending a message
      setState(() {
        _showScrollToBottomButton = false;
        _unreadMessageCount = 0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Widget _buildScrollToBottomButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _scrollToBottomAnimated,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 24,
              ),
            ),
            // Unread message count badge
            if (_unreadMessageCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.errorDark : AppColors.errorLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    _unreadMessageCount > 99
                        ? '99+'
                        : _unreadMessageCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
