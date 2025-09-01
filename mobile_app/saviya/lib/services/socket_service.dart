import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class SocketService {
  late IO.Socket socket;
  final String baseUrl = 'http://10.0.2.2:8080/api/chat';

  /// Connect to Socket.IO server and join a chat room
  void connect(int userId, int friendId) {
    print('[SocketService] Connecting to WebSocket...');
    socket = IO.io(
      'http://10.0.2.2:8080', // Socket.IO server URL (without /api)
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('[SocketService] Connected: ${socket.id}');
      print('[SocketService] Joining room for users $userId & $friendId');
      socket.emit('joinRoom', {'userId1': userId, 'userId2': friendId});
    });

    socket.onConnectError(
      (error) => print('[SocketService] Connect error: $error'),
    );
    socket.onDisconnect((_) => print('[SocketService] Disconnected'));
  }

  /// Send a message via Socket.IO
  void sendMessage(int senderId, int receiverId, String message) {
    print('[SocketService] Sending message: $message');
    socket.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    });
  }

  /// Listen for incoming messages
  void onReceiveMessage(Function callback) {
    socket.on('receiveMessage', (data) {
      print('[SocketService] Received message: $data');
      callback(data);
    });
  }

  /// Typing indicator
  void sendTyping(int senderId, int receiverId) {
    socket.emit('typing', {'senderId': senderId, 'receiverId': receiverId});
  }

  /// Disconnect socket
  void dispose() {
    print('[SocketService] Disconnecting socket');
    socket.disconnect();
  }

  /// Fetch chat history
  Future<List<Map<String, dynamic>>> getChatHistory(
    int user1,
    int user2,
  ) async {
    final url = Uri.parse('$baseUrl/history?user1=$user1&user2=$user2');
    print('[SocketService] Fetching chat history: $url');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return List<Map<String, dynamic>>.from(data['messages']);
      }
    } catch (e) {
      print('[SocketService] Exception fetching chat history: $e');
    }
    return [];
  }

  /// Send message via REST API
  Future<Map<String, dynamic>?> sendMessageREST(
    int senderId,
    int receiverId,
    String message,
  ) async {
    final url = Uri.parse('$baseUrl/send');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
        }),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data['message'];
      }
    } catch (e) {
      print('[SocketService] Exception sending message via REST: $e');
    }
    return null;
  }

  /// Get all chat rooms for a user
  Future<List<Map<String, dynamic>>> getUserChats(int userId) async {
    final url = Uri.parse('$baseUrl/list?userId=$userId');
    print('[SocketService] Fetching user chats: $url');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return List<Map<String, dynamic>>.from(data['chats']);
      }
    } catch (e) {
      print('[SocketService] Exception fetching user chats: $e');
    }
    return [];
  }
}
