import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String userId1, String userId2) {
    socket = IO.io(
      'http://10.0.2.2:8080',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Connected to socket server: ${socket.id}');
      socket.emit('joinRoom', {'userId1': userId1, 'userId2': userId2});
    });

    socket.onDisconnect((_) => print('Disconnected from socket server'));
  }

  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    socket.on('receiveMessage', (data) {
      print('New message received: $data');
      callback(Map<String, dynamic>.from(data));
    });
  }

  void sendMessage(String senderId, String receiverId, String message) {
    socket.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    });
  }

  void onUserTyping(Function(String senderId) callback) {
    socket.on('userTyping', (data) {
      callback(data['senderId']);
    });
  }

  void sendTyping(String senderId, String receiverId) {
    socket.emit('typing', {'senderId': senderId, 'receiverId': receiverId});
  }
  

  void dispose() {
    socket.dispose();
  }
}
