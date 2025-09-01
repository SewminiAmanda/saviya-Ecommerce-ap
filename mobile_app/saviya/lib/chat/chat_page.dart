import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/socket_service.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final int friendId;
  final String friendName;
  final String friendImage;

  const ChatPage({
    super.key,
    required this.userId,
    required this.friendId,
    required this.friendName,
    this.friendImage = '',
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SocketService socketService = SocketService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    initChat();
  }

  void initChat() async {
    // 1️⃣ Load chat history from backend
    final history = await socketService.getChatHistory(
      widget.userId,
      widget.friendId,
    );

    setState(() => messages = history);
    _scrollToBottom();

    // 2️⃣ Connect socket
    socketService.connect(widget.userId, widget.friendId);

    // 3️⃣ Listen for incoming messages
    socketService.onReceiveMessage((msg) {
      // Only add messages relevant to this chat
      if ((msg['senderId'] == widget.friendId &&
              msg['receiverId'] == widget.userId) ||
          (msg['senderId'] == widget.userId &&
              msg['receiverId'] == widget.friendId)) {
        setState(() => messages.add(msg));
        _scrollToBottom();
      }
    });
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final msg = _controller.text.trim();

    // Send via socket
    socketService.sendMessage(widget.userId, widget.friendId, msg);

    // Add locally
    setState(() {
      messages.add({
        'senderId': widget.userId,
        'receiverId': widget.friendId,
        'message': msg,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map msg) {
    bool isMe = msg['senderId'] == widget.userId; // ✅ Correct sender check
    DateTime time = DateTime.parse(msg['timestamp']);
    String formattedTime = DateFormat('hh:mm a').format(time);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for friend's messages only
          if (!isMe && widget.friendImage.isNotEmpty)
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.friendImage),
            ),
          if (!isMe && widget.friendImage.isNotEmpty) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color.fromARGB(255, 233, 165, 63)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 12),
                    ),
                  ),
                  child: Text(
                    msg['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socketService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.friendImage.isNotEmpty)
              CircleAvatar(backgroundImage: NetworkImage(widget.friendImage)),
            const SizedBox(width: 8),
            Text(widget.friendName),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 238, 177, 84),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (ctx, i) => _buildMessage(messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 245, 190, 72),
                  ),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
