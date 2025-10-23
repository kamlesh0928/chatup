import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, deleted }

enum MessageStatus { sent, read }

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final Timestamp timestamp;
  final List<String> readBy;
  final List<String> deletedFor;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    required this.readBy,
    this.deletedFor = const [],
  });

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    Timestamp? timestamp,
    List<String>? readBy,
    List<String>? deletedFor,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      chatRoomId: data["chatRoomId"] as String,
      senderId: data["senderId"] as String,
      receiverId: data["receiverId"] as String,
      content: data["content"] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == data["type"],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == data["status"],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: data["timestamp"] as Timestamp,
      readBy: List<String>.from(data["readBy"] ?? []),
      deletedFor: List<String>.from(data["isDeletedFor"] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "senderId": senderId,
      "receiverId": receiverId,
      "content": content,
      "type": type.toString(),
      "status": status.toString(),
      "timestamp": timestamp,
      "readBy": readBy,
      "isDeletedFor": deletedFor,
    };
  }
}
