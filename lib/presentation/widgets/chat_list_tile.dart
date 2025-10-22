import 'package:chatup/data/models/chat_room_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/service_locator.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback onTap;
  final bool isLastMessageRead;
  final bool isMessagesAvailable;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
    required this.isLastMessageRead,
    required this.isMessagesAvailable,
  });

  String _getOtherUsername() {
    final otherUserId = chat.participants[0] == currentUserId
        ? chat.participants[1]
        : chat.participants[0];
    return chat.participantsName?[otherUserId] ?? "Unknown";
  }

  String _getLastMessageDateOrTime(DateTime lastMessageTime) {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime).inSeconds;

    if (difference <= 60) {
      return "now";
    } else if (difference <= (24 * 60 * 60)) {
      return DateFormat("h:mm a").format(lastMessageTime);
    } else if (difference <= (2 * 24 * 60 * 60)) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yy").format(lastMessageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF3B9FA7).withValues(alpha: 0.1),
              child: Text(
                _getOtherUsername().isNotEmpty
                    ? _getOtherUsername()[0].toUpperCase()
                    : "?",
                style: TextStyle(
                  color: Color(0xFF3B9FA7),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getOtherUsername(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (isMessagesAvailable &&
                          chat.lastMessageSenderId == currentUserId)
                        Icon(
                          Icons.done_all,
                          color: isLastMessageRead
                              ? Color(0xFF25D366)
                              : Colors.grey[500],
                          size: 16,
                        ),
                      if (isMessagesAvailable &&
                          chat.lastMessageSenderId == currentUserId)
                        SizedBox(width: 4),
                      if (isMessagesAvailable &&
                          chat.lastMessageSenderId == currentUserId)
                        Text(
                          "You: ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat.lastMessage ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (chat.lastMessageTime != null && chat.lastMessage != null)
                  Text(
                    _getLastMessageDateOrTime(chat.lastMessageTime!.toDate()),
                    style: TextStyle(
                      color: Color(0xFF3B9FA7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                SizedBox(height: 4),
                StreamBuilder<int>(
                  stream: getIt<ChatRepository>().getUnreadCount(
                    chat.id,
                    currentUserId,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == 0) {
                      return SizedBox();
                    }
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B9FA7),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        snapshot.data.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
