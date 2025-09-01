import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocketService {
  late IO.Socket socket;

  
  void connect(String userId1, String userId2) {
    print('[SocketService] Connecting to socket server...');
    socket = IO.io(
      'http://10.0.2.2:8080', 
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('[SocketService] Connected: ${socket.id}');
      socket.emit('joinRoom', {'userId1': userId1, 'userId2': userId2});
    });

    socket.onDisconnect((_) {
      print('[SocketService] Disconnected');
    });

    socket.onConnectError((err) {
      print('[SocketService] Connection error: $err');
    });

    socket.onError((err) {
      print('[SocketService] Socket error: $err');
    });
  }

  // Listen for incoming messages
  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    socket.on('receiveMessage', (data) {
      print('[SocketService] Received message: $data');
      try {
        callback(Map<String, dynamic>.from(data));
      } catch (e) {
        print('[SocketService] Error parsing message: $e');
      }
    });
  }

  // Send message
  void sendMessage(String senderId, String receiverId, String message) {
    print('[SocketService] Sending message: $message');
    socket.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    });
  }

  void dispose() {
    print('[SocketService] Disposing socket connection');
    socket.disconnect();
    socket.destroy();
  }

  // Get chat history
  Future<List<Map<String, dynamic>>> getChatHistory(
    String user1,
    String user2,
  ) async {
    print('[SocketService] Fetching chat history...');
    try {
      final res = await http.get(
        Uri.parse(
          'http://10.0.2.2:8080/api/chat/history?user1=$user1&user2=$user2',
        ),
      );

      print('[SocketService] Status code: ${res.statusCode}');
      print('[SocketService] Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['messages']);
        }
      }
      return [];
    } catch (e) {
      print('[SocketService] Exception fetching chat history: $e');
      return [];
    }
  }
}
