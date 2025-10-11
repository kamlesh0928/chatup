import 'dart:io';
import 'package:chatup/data/models/chat_message.dart';
import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/logic/cubits/chat/chat_cubit.dart';
import 'package:chatup/logic/cubits/chat/chat_state.dart';
import 'package:chatup/presentation/widgets/loading_dots.dart';
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

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit;
  final _scrollController = ScrollController();
  List<ChatMessage> _previousMessages = [];
  bool _isTyping = false;
  bool _showEmoji = false;

  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChange);
    _scrollController.addListener(_onScroll);
    super.initState();
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
        duration: Duration(milliseconds: 300),
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

    return;
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

  @override
  void dispose() {
    messageController.dispose();
    _chatCubit.leaveChat();
    _scrollController.dispose();
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.85),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Color(0xFF3B9FA7)),
                    ),
                    CircleAvatar(
                      backgroundColor: Color(0xFF3B9FA7).withValues(alpha: 0.1),
                      child: Text(
                        widget.receiverName[0],
                        style: TextStyle(
                          color: Color(0xFF3B9FA7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.receiverName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B9FA7),
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
                                    SizedBox(width: 4),
                                    const LoadingDots(),
                                  ],
                                );
                              }

                              if (state.isReceiverOnline) {
                                return Text(
                                  "Online",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
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

                              return SizedBox();
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
                            label: Text(
                              "Unblock",
                              style: TextStyle(color: Color(0xFF3B9FA7)),
                            ),
                            icon: Icon(Icons.block, color: Color(0xFF3B9FA7)),
                          );
                        }

                        return PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Color(0xFF3B9FA7)),
                          onSelected: (value) async {
                            if (value == "block") {
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    0.85,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    "Are you sure you want to block ${widget.receiverName}?",
                                    style: TextStyle(color: Color(0xFF3B9FA7)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        "Block",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await _chatCubit.blockUser(widget.receiverId);
                              }
                            }
                          },
                          itemBuilder: (context) => <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: "block",
                              child: Text(
                                "Block",
                                style: TextStyle(color: Color(0xFF3B9FA7)),
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
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B9FA7),
                        ),
                      );
                    }

                    if (state.status == ChatStatus.error) {
                      return Center(
                        child: Text(
                          state.error ?? "Something went wrong",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (state.amIBlocked)
                          Container(
                            padding: EdgeInsets.all(12),
                            color: Color.fromRGBO(255, 255, 255, 0.85),
                            child: Text(
                              "You have been blocked",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.all(16),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe =
                                  message.senderId == _chatCubit.currentUserId;

                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                              );
                            },
                          ),
                        ),
                        if (!state.amIBlocked && !state.isUserBlocked)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.85),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  offset: Offset(0, -5),
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
                                      icon: Icon(
                                        Icons.emoji_emotions_outlined,
                                        color: Color(0xFF3B9FA7),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: TextField(
                                          onTap: () {
                                            if (_showEmoji) {
                                              setState(() {
                                                _showEmoji = !_showEmoji;
                                              });
                                            }
                                          },
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller: messageController,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                            hintText: "Type a message",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _isTyping
                                          ? _handleSendMessage
                                          : null,
                                      icon: Icon(
                                        Icons.send,
                                        color: _isTyping
                                            ? Color(0xFF3B9FA7)
                                            : Colors.grey[400],
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
                                          backgroundColor: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.85,
                                          ),
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
                                              backgroundColor: Color.fromRGBO(
                                                255,
                                                255,
                                                255,
                                                0.85,
                                              ),
                                              buttonColor: Color(0xFF3B9FA7),
                                            ),
                                        skinToneConfig: const SkinToneConfig(
                                          enabled: true,
                                          dialogBackgroundColor: Colors.white,
                                          indicatorColor: Colors.grey,
                                        ),
                                        searchViewConfig: SearchViewConfig(
                                          backgroundColor: Color.fromRGBO(
                                            255,
                                            255,
                                            255,
                                            0.85,
                                          ),
                                          buttonIconColor: Color(0xFF3B9FA7),
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

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 16,
          right: isMe ? 16 : 64,
          top: 8,
          bottom: 8,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFF3B9FA7) : Color.fromRGBO(255, 255, 255, 0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(16),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
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
                SizedBox(width: 4),
                if (isMe)
                  Icon(
                    Icons.done_all,
                    color: message.status == MessageStatus.read
                        ? Colors.white
                        : Colors.white70,
                    size: 16,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
