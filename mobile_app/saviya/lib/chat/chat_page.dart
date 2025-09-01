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
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadHistory();
    connectSocket();
  }

  void loadHistory() async {
    final history = await socketService.getChatHistory(
      widget.userId.toString(),
      widget.friendId.toString(),
    );
    setState(() {
      messages = history;
    });
    _scrollToBottom();
  }

  void connectSocket() {
    socketService.connect(widget.userId.toString(), widget.friendId.toString());
    socketService.onReceiveMessage((msg) {
      // Avoid duplicate messages
      if (msg['senderId'] != widget.userId) {
        setState(() {
          messages.add(msg);
        });
        _scrollToBottom();
      }
    });
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final msg = _controller.text.trim();

    socketService.sendMessage(
      widget.userId.toString(),
      widget.friendId.toString(),
      msg,
    );

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
    bool isMe = msg['senderId'] == widget.userId;
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
