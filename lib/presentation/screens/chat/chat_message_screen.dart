import 'dart:io';
import 'package:chatup/data/models/chat_message.dart';
import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/logic/cubits/chat/chat_cubit.dart';
import 'package:chatup/logic/cubits/chat/chat_state.dart';
import 'package:chatup/presentation/widgets/loading_dots.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  const ChatMessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit;
  final _scrollController = ScrollController();
  List<ChatMessage> _previousMessages = [];
  bool _isTyping = false;
  bool _showEmoji = false;
  String? _lastDate;
  bool _showDate = false;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChange);
    _scrollController.addListener(_onScroll);

    if (mounted) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
      );
      _animationController?.forward();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _chatCubit.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _hasNewMessages(List<ChatMessage> messages) {
    if (messages.length != _previousMessages.length) {
      _previousMessages = messages;
      _scrollToBottom();
    }
  }

  Future<void> _handleSendMessage() async {
    if (messageController.text.isEmpty) {
      return;
    }

    final messageText = messageController.text;
    messageController.clear();

    await _chatCubit.sendMessage(
      content: messageText,
      receiverId: widget.receiverId,
    );
  }

  void _onTextChange() {
    final isTyping = messageController.text.isNotEmpty;

    if (isTyping != _isTyping) {
      setState(() {
        _isTyping = isTyping;
      });

      if (isTyping) {
        _chatCubit.startTyping();
      }
    }
  }

  String _getDateLabel(Timestamp messageTime) {
    final now = DateTime.now();
    final difference = now.difference(messageTime.toDate()).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else {
      return DateFormat("dd MMM, yyyy").format(messageTime.toDate());
    }
  }

  Future<void> _handleDeleteMessage(ChatMessage message, String type) async {
    if (type == 'deleteForMe') {
      await _chatCubit.deleteMessageForMe(message.id, widget.receiverId);
    } else if (type == 'deleteForEveryone') {
      await _chatCubit.deleteMessageForEveryone(message.id, widget.receiverId);
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _chatCubit.leaveChat();
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFECF4F4), Color(0xFFCEE6E8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // Adjusted for 0.95 opacity
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26), // 0.1 opacity
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF3B9FA7),
                        size: 28,
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(
                        0xFF3B9FA7,
                      ).withAlpha(26), // 0.1 opacity
                      child: Text(
                        widget.receiverName.isNotEmpty
                            ? widget.receiverName[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          color: Color(0xFF3B9FA7),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.receiverName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          BlocBuilder<ChatCubit, ChatState>(
                            bloc: _chatCubit,
                            builder: (context, state) {
                              if (state.isReceiverTyping) {
                                return Row(
                                  children: [
                                    Text(
                                      "Typing",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const LoadingDots(),
                                  ],
                                );
                              }

                              if (state.isReceiverOnline) {
                                return Text(
                                  "Online",
                                  style: const TextStyle(
                                    color: Color(0xFF3B9FA7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }

                              if (state.receiverLastSeen != null) {
                                final lastSeen = state.receiverLastSeen!
                                    .toDate();
                                return Text(
                                  "Last seen: ${DateFormat("h:mm a").format(lastSeen)}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                );
                              }

                              return const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<ChatCubit, ChatState>(
                      bloc: _chatCubit,
                      builder: (context, state) {
                        if (state.isUserBlocked) {
                          return TextButton.icon(
                            onPressed: () =>
                                _chatCubit.unBlockUser(widget.receiverId),
                            label: const Text(
                              "Unblock",
                              style: TextStyle(
                                color: Color(0xFF3B9FA7),
                                fontSize: 14,
                              ),
                            ),
                            icon: const Icon(
                              Icons.block,
                              color: Color(0xFF3B9FA7),
                              size: 20,
                            ),
                          );
                        }

                        return PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFF3B9FA7),
                            size: 28,
                          ),
                          onSelected: (value) async {
                            if (value == "block") {
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(
                                    0xFFF5F5F5,
                                  ), // 0.95 opacity
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    "Block ${widget.receiverName}?",
                                    style: const TextStyle(
                                      color: Color(0xFF3B9FA7),
                                      fontSize: 18,
                                    ),
                                  ),
                                  content: Text(
                                    "Blocked contacts will not be able to message you.",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Block",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _chatCubit.blockUser(widget.receiverId);
                              }
                            } else if (value == "clearChat") {
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(
                                    0xFFF5F5F5,
                                  ), // 0.95 opacity
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    "Clear Chat",
                                    style: TextStyle(
                                      color: Color(0xFF3B9FA7),
                                      fontSize: 18,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to clear all messages in this chat?",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        "Clear",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _chatCubit.clearChat(widget.receiverId);
                              }
                            }
                          },
                          itemBuilder: (context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem(
                              value: "block",
                              child: Text(
                                "Block",
                                style: TextStyle(
                                  color: Color(0xFF3B9FA7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const PopupMenuItem(
                              value: "clearChat",
                              child: Text(
                                "Clear Chat",
                                style: TextStyle(
                                  color: Color(0xFF3B9FA7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (context, state) {
                    _hasNewMessages(state.messages);
                  },
                  bloc: _chatCubit,
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B9FA7),
                        ),
                      );
                    }

                    if (state.status == ChatStatus.error) {
                      return Center(
                        child: Text(
                          state.error ?? "Something went wrong",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (state.amIBlocked)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5), // 0.95 opacity
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    26,
                                  ), // 0.1 opacity
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "You have been blocked",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe =
                                  message.senderId == _chatCubit.currentUserId;
                              final dateLabel = _getDateLabel(
                                message.timestamp,
                              );
                              _showDate = dateLabel != _lastDate;
                              _lastDate = dateLabel;

                              return AnimatedBuilder(
                                animation:
                                    _animationController ??
                                    AnimationController(vsync: this),
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _fadeAnimation?.value ?? 1.0,
                                    child: Column(
                                      children: [
                                        if (_showDate)
                                          Center(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFF5F5F5,
                                                ), // 0.95 opacity
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(
                                                          26,
                                                        ), // 0.1 opacity
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                dateLabel,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        MessageBubble(
                                          message: message,
                                          isMe: isMe,
                                          onDelete: (type) =>
                                              _handleDeleteMessage(
                                                message,
                                                type,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (!state.amIBlocked && !state.isUserBlocked)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5), // 0.95 opacity
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    26,
                                  ), // 0.1 opacity
                                  blurRadius: 15,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _showEmoji = !_showEmoji;
                                          if (_showEmoji) {
                                            FocusScope.of(context).unfocus();
                                          }
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.emoji_emotions_outlined,
                                        color: Color(0xFF3B9FA7),
                                        size: 28,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(
                                                13,
                                              ), // 0.05 opacity
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          onTap: () {
                                            if (_showEmoji) {
                                              setState(() {
                                                _showEmoji = false;
                                              });
                                            }
                                          },
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller: messageController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            hintText: "Message",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _isTyping
                                          ? _handleSendMessage
                                          : null,
                                      icon: Icon(
                                        Icons.send,
                                        color: _isTyping
                                            ? const Color(0xFF3B9FA7)
                                            : Colors.grey[400],
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_showEmoji)
                                  SizedBox(
                                    height: 250,
                                    child: EmojiPicker(
                                      textEditingController: messageController,
                                      onEmojiSelected: (category, emoji) {
                                        messageController
                                          ..text += emoji.emoji
                                          ..selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: messageController
                                                      .text
                                                      .length,
                                                ),
                                              );
                                        setState(() {
                                          _isTyping =
                                              messageController.text.isNotEmpty;
                                        });
                                      },
                                      config: Config(
                                        height: 250,
                                        emojiViewConfig: EmojiViewConfig(
                                          columns: 7,
                                          emojiSizeMax:
                                              32.0 *
                                              (Platform.isIOS ? 1.30 : 1.0),
                                          verticalSpacing: 0,
                                          horizontalSpacing: 0,
                                          gridPadding: EdgeInsets.zero,
                                          backgroundColor: const Color(
                                            0xFFF5F5F5,
                                          ), // 0.95 opacity
                                          loadingIndicator:
                                              const SizedBox.shrink(),
                                        ),
                                        categoryViewConfig:
                                            const CategoryViewConfig(
                                              initCategory: Category.RECENT,
                                            ),
                                        bottomActionBarConfig:
                                            BottomActionBarConfig(
                                              enabled: true,
                                              backgroundColor: const Color(
                                                0xFFF5F5F5,
                                              ), // 0.95 opacity
                                              buttonColor: const Color(
                                                0xFF3B9FA7,
                                              ),
                                            ),
                                        skinToneConfig: const SkinToneConfig(
                                          enabled: true,
                                          dialogBackgroundColor: Colors.white,
                                          indicatorColor: Colors.grey,
                                        ),
                                        searchViewConfig: SearchViewConfig(
                                          backgroundColor: const Color(
                                            0xFFF5F5F5,
                                          ), // 0.95 opacity
                                          buttonIconColor: const Color(
                                            0xFF3B9FA7,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Function(String) onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFF5F5F5), // 0.95 opacity
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Delete Message?",
              style: TextStyle(color: Color(0xFF3B9FA7), fontSize: 18),
            ),
            content: Text(
              "Choose how you want to delete this message.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete('deleteForMe');
                },
                child: Text(
                  "Delete for Me",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
              if (isMe)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete('deleteForEveryone');
                  },
                  child: const Text(
                    "Delete for Everyone",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(
            left: 48,
            right: 12,
            top: 6,
            bottom: 6,
          ).copyWith(left: isMe ? 48 : 12, right: isMe ? 12 : 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF3B9FA7)
                : const Color(0xFFF5F5F5), // 0.95 opacity
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe
                  ? const Radius.circular(20)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26), // 0.1 opacity
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.type == MessageType.deleted)
                Text(
                  'This message was deleted',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[700],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                )
              else
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat("h:mm a").format(message.timestamp.toDate()),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (isMe && message.type != MessageType.deleted)
                    const SizedBox(width: 6),
                  if (isMe && message.type != MessageType.deleted)
                    Icon(
                      Icons.done_all,
                      color: message.status == MessageStatus.read
                          ? const Color(0xFF25D366)
                          : Colors.grey[500],
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
