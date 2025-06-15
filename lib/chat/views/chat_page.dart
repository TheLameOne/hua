import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hua/chat/providers/chat_provider.dart';

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
  final List<Color> _avatarColors = [
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFC107), // Amber
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFF5722), // Deep Orange
  ];

  // Message bubble colors - replacing gradients with solid colors
  final List<Color> _messageColors = [
    const Color(0xFF6200EA), // Deep Purple
    const Color(0xFF00BFA5), // Teal
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2979FF), // Blue
    const Color(0xFF00C853), // Green
    const Color(0xFFD500F9), // Purple
    const Color(0xFF64B5F6), // Light Blue
    const Color(0xFF455A64), // Blue Grey
  ];

  // Own message color
  Color get _ownMessageColor => const Color(0xFFEEEEEE); // Light gray
  Color get _otherMessageColor => Colors.white; // White
  Color get _systemMessageColor => const Color(0xFFF5F5F5); // Very light gray

  Color _getUserMessageColor(String name) {
    // Always return the same color for other users' messages
    return _otherMessageColor;
  }

  @override
  void initState() {
    super.initState();
    _autoConnect();
    _messageFocusNode.addListener(_onFocusChange);
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
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Use a slight delay to ensure messages are fully rendered
    Future.delayed(const Duration(milliseconds: 2000), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          try {
            _scrollController
                .animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic, // Smoother animation curve
                )
                .then((_) {});
          } catch (e) {
            print('Error scrolling to bottom: $e');
          }
        }
      });
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.length > 1
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();
  }

  Color _getUserColor(String name) {
    if (name == 'System') return Colors.grey;
    int hash = 0;
    for (var i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return _avatarColors[hash.abs() % _avatarColors.length];
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.05),
              titleSpacing: 0,
              title: Row(
                children: [
                  // User avatar
                  SizedBox(width: 16),
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getUserColor(chatProvider.username ?? 'User'),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getUserColor(chatProvider.username ?? 'User')
                              .withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 18,
                      child: Text(
                        _getInitials(chatProvider.username ?? 'User'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Username and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chatProvider.username ?? 'User',
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
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
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Add more action buttons here if needed
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF3F51B5)),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh, color: Color(0xFF3F51B5)),
            title: const Text('Reconnect'),
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
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet

              // Show a confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('LOGOUT',
                          style: TextStyle(color: Colors.red)),
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
                  ]);

                  // Add timeout to logout
                  await Future.any([
                    authProvider.logout(),
                    Future.delayed(const Duration(seconds: 2))
                  ]);

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
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    _scrollToBottom();

    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: Colors.grey.shade400,
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
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              chatProvider.isConnected
                  ? 'Send a message to begin'
                  : 'Please wait while we establish connection',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        final isLastMessage = index == chatProvider.messages.length - 1;
        return _buildMessageBubble(message, isLastMessage);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isLastMessage) {
    final isSystem = message.isSystemMessage;

    if (isSystem) {
      // Check if this is a date separator message
      final isDateSeparator = _isDateSeparatorMessage(message.message);

      if (isDateSeparator) {
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
                        Colors.grey.shade300,
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
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
                        Colors.grey.shade300,
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
              color: _systemMessageColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: message.isOwnMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isOwnMessage)
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: _getUserColor(message.username),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getUserColor(message.username).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 18,
                  child: Text(
                    _getInitials(message.username),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 80,
              ),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: message.isOwnMessage
                    ? _ownMessageColor
                    : _otherMessageColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(message.isOwnMessage ? 24 : 6),
                  bottomRight: Radius.circular(message.isOwnMessage ? 6 : 24),
                ),
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
                    if (!message.isOwnMessage)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          message.username,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: _getUserColor(message
                                .username), // Keep username color matching avatar
                          ),
                        ),
                      ),
                    // Message text and timestamp with updated colors
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      children: [
                        Text(
                          message.message,
                          style: TextStyle(
                            color: Colors.grey
                                .shade800, // Dark gray text for better contrast
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (message.isOwnMessage) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.done_all,
                                size: 14,
                                color: Colors.blue
                                    .shade300, // Keep blue for status indicators
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

  Widget _buildMessageInput(ChatProvider chatProvider) {
    final isConnected = chatProvider.isConnected;
    final isConnecting = chatProvider.isConnecting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
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
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(chatProvider),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Updated send button to match the minimalist design
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(
                    0xFF3F51B5), // Keep a subtle color for the send button
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
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
    }
  }
}
