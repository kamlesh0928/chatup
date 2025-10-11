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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;
  AnimationController?
  _animationController; // Made nullable to avoid uninitialized access
  Animation<double>? _fadeAnimation; // Made nullable for safety

  @override
  void initState() {
    super.initState();
    // Initialize repositories and user ID
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentUser?.uid ?? "";

    // Initialize animation controller only if context is mounted
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

  @override
  void dispose() {
    // Safely dispose animation controller if initialized
    _animationController?.dispose();
    super.dispose();
  }

  void _showContactsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensure modal handles content height well
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Color.fromRGBO(255, 255, 255, 0.95),
      builder: (context) {
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
            mainAxisSize:
                MainAxisSize.min, // Prevent modal from taking full height
            children: [
              Text(
                "New Chat",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Color(0xFF3B9FA7),
                  fontWeight: FontWeight.bold,
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B9FA7),
                        ),
                      );
                    }

                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return Center(
                        child: Text(
                          "No contacts found",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true, // Ensure ListView fits content
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(
                                0xFF3B9FA7,
                              ).withValues(alpha: 0.1),
                              child: Text(
                                contact["name"]?.isNotEmpty == true
                                    ? contact["name"][0].toUpperCase()
                                    : "?",
                                style: TextStyle(
                                  color: Color(0xFF3B9FA7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
                              Navigator.pop(
                                context,
                              ); // Close modal before navigation
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
                        fontSize: 24,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Color(0xFF3B9FA7)),
                      onSelected: (value) async {
                        if (value == "logout") {
                          await getIt<AuthCubit>().logout();
                          if (mounted) {
                            getIt<AppRouter>().pushAndRemoveUntil(
                              const LoginScreen(),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "logout",
                          child: Text(
                            "Logout",
                            style: TextStyle(color: Color(0xFF3B9FA7)),
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
                              stream: _chatRepository.getChatRooms(
                                _currentUserId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  log(snapshot.error.toString());
                                  return Center(
                                    child: Text(
                                      "Error: ${snapshot.error}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF3B9FA7),
                                    ),
                                  );
                                }

                                final chats = snapshot.data!;
                                if (chats.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "No chats yet",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Start a new conversation!",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  itemCount: chats.length,
                                  itemBuilder: (context, index) {
                                    final chat = chats[index];
                                    return ChatListTile(
                                      chat: chat,
                                      currentUserId: _currentUserId,
                                      onTap: () {
                                        final receiverId =
                                            chat.participants[0] ==
                                                _currentUserId
                                            ? chat.participants[1]
                                            : chat.participants[0];
                                        final receiverName =
                                            chat.participantsName?[receiverId] ??
                                            "Unknown";
                                        getIt<AppRouter>().push(
                                          ChatMessageScreen(
                                            receiverId: receiverId,
                                            receiverName: receiverName,
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
                    : Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B9FA7),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _animationController != null && _fadeAnimation != null
          ? ScaleTransition(
              scale: _fadeAnimation!,
              child: FloatingActionButton(
                onPressed: () => _showContactsList(context),
                backgroundColor: Color(0xFF3B9FA7),
                child: Icon(Icons.message, color: Colors.white, size: 28),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : null,
    );
  }
}
