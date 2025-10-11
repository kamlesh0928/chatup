import 'package:chatup/data/models/chat_room_model.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/services/service_locator.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  String _getOtherUsername() {
    final otherUserId = chat.participants[0] == currentUserId
        ? chat.participants[1]
        : chat.participants[0];
    return chat.participantsName![otherUserId] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF3B9FA7).withValues(alpha: 0.1),
          child: Text(
            _getOtherUsername().substring(0, 1),
            style: TextStyle(
              color: Color(0xFF3B9FA7),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          _getOtherUsername(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B9FA7),
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
        trailing: StreamBuilder<int>(
          stream: getIt<ChatRepository>().getUnreadCount(
            chat.id,
            currentUserId,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == 0) {
              return const SizedBox();
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
        onTap: onTap,
      ),
    );
  }
}
