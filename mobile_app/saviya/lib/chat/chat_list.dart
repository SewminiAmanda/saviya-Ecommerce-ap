import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  int? _currentUserId;
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndChats();
  }

  Future<void> _loadCurrentUserAndChats() async {
    final id = await AuthService.getUserId();
    if (!mounted) return;
    setState(() => _currentUserId = id);
    await _fetchChats();
  }

  Future<void> _fetchChats() async {
    if (_currentUserId == null) return;
    setState(() => _loading = true);

    try {
      final chats = await SocketService().getUserChats(_currentUserId!);
      if (!mounted) return;
      setState(() {
        _chats = chats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? const Center(child: Text('No chats yet.'))
          : ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    chat['friendName'] ?? 'User ${chat['otherUserId']}',
                  ),
                  subtitle: Text(chat['lastMessage'] ?? ''),
                  trailing: chat['lastMessageTimestamp'] != null
                      ? Text(
                          chat['lastMessageTimestamp'].toString().split('T')[0],
                        )
                      : null,
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
