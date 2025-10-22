import 'dart:developer';

import 'package:chatup/data/repositories/auth_repository.dart';
import 'package:chatup/data/repositories/chat_repository.dart';
import 'package:chatup/data/repositories/contact_repository.dart';
import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/logic/cubits/auth/auth_cubit.dart';
import 'package:chatup/presentation/screens/auth/login_screen.dart';
import 'package:chatup/presentation/screens/chat/chat_message_screen.dart';
import 'package:chatup/presentation/widgets/chat_list_tile.dart';
import 'package:chatup/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentUser?.uid ?? "";

    if (mounted) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
      );
      _animationController?.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _showContactsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.95),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    "New Chat",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Color(0xFF3B9FA7),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Text(
                          "Search contacts...",
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _contactRepository.getRegisteredContacts(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error: ${snapshot.error}",
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(color: Color(0xFF3B9FA7)));
                        }

                        final contacts = snapshot.data!;
                        if (contacts.isEmpty) {
                          return Center(
                            child: Text(
                              "No contacts found",
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Color(0xFF3B9FA7).withValues(alpha: 0.1),
                                  child: Text(
                                    contact["name"]?.isNotEmpty == true
                                        ? contact["name"][0].toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      color: Color(0xFF3B9FA7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  contact["name"] ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  getIt<AppRouter>().push(
                                    ChatMessageScreen(
                                      receiverId: contact["id"],
                                      receiverName: contact["name"] ?? "Unknown",
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                  color: Color.fromRGBO(255, 255, 255, 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ChatUp",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(0xFF3B9FA7),
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Color(0xFF3B9FA7), size: 28),
                      onSelected: (value) async {
                        if (value == "logout") {
                          await getIt<AuthCubit>().logout();
                          if (mounted) {
                            getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "logout",
                          child: Text(
                            "Logout",
                            style: TextStyle(color: Color(0xFF3B9FA7), fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _animationController != null && _fadeAnimation != null
                    ? AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation!.value,
                      child: StreamBuilder(
                        stream: _chatRepository.getChatRooms(_currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            log(snapshot.error.toString());
                            return Center(
                              child: Text(
                                "Error: ${snapshot.error}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator(color: Color(0xFF3B9FA7)));
                          }

                          final chats = snapshot.data!;
                          if (chats.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No chats yet",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tap the button below to start a new conversation!",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];
                              final receiverId = chat.participants[0] == _currentUserId
                                  ? chat.participants[1]
                                  : chat.participants[0];
                              final isMessagesAvailable = chat.lastMessage != null;
                              final isLastMessageRead = (() {
                                final lastRead = chat.lastReadTime[receiverId]?.toDate();
                                final lastMessage = chat.lastMessageTime?.toDate();
                                if (lastRead == null || lastMessage == null) {
                                  return false;
                                }
                                return lastRead.isAfter(lastMessage) ||
                                    lastRead.isAtSameMomentAs(lastMessage);
                              })();
                              return AnimatedBuilder(
                                animation: _animationController!,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - _fadeAnimation!.value)),
                                    child: Opacity(
                                      opacity: _fadeAnimation!.value,
                                      child: ChatListTile(
                                        chat: chat,
                                        currentUserId: _currentUserId,
                                        isLastMessageRead: isLastMessageRead,
                                        isMessagesAvailable: isMessagesAvailable,
                                        onTap: () {
                                          final receiverName =
                                              chat.participantsName?[receiverId] ?? "Unknown";
                                          getIt<AppRouter>().push(
                                            ChatMessageScreen(
                                              receiverId: receiverId,
                                              receiverName: receiverName,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                )
                    : Center(child: CircularProgressIndicator(color: Color(0xFF3B9FA7))),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _animationController != null && _fadeAnimation != null
          ? ScaleTransition(
        scale: _fadeAnimation!,
        child: FloatingActionButton(
          onPressed: () => _showContactsList(context),
          backgroundColor: Color(0xFF3B9FA7),
          child: Icon(Icons.message, color: Colors.white, size: 28),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      )
          : null,
    );
  }
}