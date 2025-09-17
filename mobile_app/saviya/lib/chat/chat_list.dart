import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import 'chat_page.dart';

/// A page that displays the list of chats for the current user.
/// Uses [AuthService] to get the logged-in user's ID and [SocketService]
/// to fetch the user's chats from the backend.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int? _currentUserId; // Holds the logged-in user's ID
  List<Map<String, dynamic>> _chats =
      []; // List of chats retrieved from backend
  bool _loading = true; // Loading state for displaying a progress indicator

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndChats();
  }

  /// Loads the current user's ID and fetches their chats.
  Future<void> _loadCurrentUserAndChats() async {
    final id =
        await AuthService.getUserId(); 
    if (!mounted)
      return; 
    setState(() => _currentUserId = id);
    await _fetchChats();
  }

  /// Fetches chats for the current user from [SocketService].
  Future<void> _fetchChats() async {
    if (_currentUserId == null) return;

    setState(() => _loading = true);

    try {
      // Fetch chats from backend
      final chats = await SocketService().getUserChats(_currentUserId!);
      if (!mounted) return;
      setState(() {
        _chats = chats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      // Show error if fetching chats fails
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load chats: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), centerTitle: true),
      body: _loading
          // Show loading indicator while fetching chats
          ? const Center(child: CircularProgressIndicator())
          // Show message if there are no chats
          : _chats.isEmpty
          ? const Center(child: Text('No chats yet.'))
          // Display list of chats
          : ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final chat = _chats[index];

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    // Display friend name or fallback to user ID
                    chat['friendName'] ?? 'User ${chat['otherUserId']}',
                  ),
                  subtitle: Text(chat['lastMessage'] ?? ''),
                  trailing: chat['lastMessageTimestamp'] != null
                      // Show only date portion (e.g. "2025-09-15")
                      ? Text(
                          chat['lastMessageTimestamp'].toString().split('T')[0],
                        )
                      : null,

                  // Navigate to ChatPage when chat item is tapped
                  onTap: () {
                    if (_currentUserId == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          userId: _currentUserId!,
                          friendId: chat['otherUserId'],
                          friendName:
                              chat['friendName'] ??
                              'User ${chat['otherUserId']}',
                          friendImage: chat['friendImage'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
