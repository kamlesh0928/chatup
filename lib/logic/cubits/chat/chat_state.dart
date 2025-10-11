import 'package:chatup/data/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessage> messages;
  final bool isReceiverOnline;
  final bool isReceiverTyping;
  final Timestamp? receiverLastSeen;
  final bool hasMoreMessages;
  final bool isLoadingMore;
  final bool isUserBlocked;
  final bool amIBlocked;

  const ChatState({
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
    this.messages = const [],
    this.isReceiverOnline = false,
    this.isReceiverTyping = false,
    this.receiverLastSeen,
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
    this.isUserBlocked = false,
    this.amIBlocked = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? error,
    String? receiverId,
    String? chatRoomId,
    List<ChatMessage>? messages,
    bool? isReceiverOnline,
    bool? isReceiverTyping,
    Timestamp? receiverLastSeen,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    bool? isUserBlocked,
    bool? amIBlocked,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
      isReceiverOnline: isReceiverOnline ?? this.isReceiverOnline,
      isReceiverTyping: isReceiverTyping ?? this.isReceiverTyping,
      receiverLastSeen: receiverLastSeen ?? this.receiverLastSeen,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      amIBlocked: amIBlocked ?? this.amIBlocked,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    receiverId,
    chatRoomId,
    messages,
    isReceiverOnline,
    isReceiverTyping,
    receiverLastSeen,
    hasMoreMessages,
    isLoadingMore,
    isUserBlocked,
    amIBlocked,
  ];
}
