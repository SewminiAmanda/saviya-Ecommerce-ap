const Message = require('./models/messageModel');

module.exports = (io) => {
    io.on('connection', (socket) => {
        console.log(`User connected: ${socket.id}`);

        socket.on('joinRoom', ({ userId1, userId2 }) => {
            const roomName = [userId1, userId2].sort().join('-');
            socket.join(roomName);
            console.log(`Socket ${socket.id} joined room ${roomName}`);
        });

        socket.on('sendMessage', async ({ senderId, receiverId, message }) => {
            const roomName = [senderId, receiverId].sort().join('-');

            // Broadcast to room
            socket.to(roomName).emit('receiveMessage', {
                senderId,
                message,
                timestamp: new Date().toISOString(),
            });

            try {
                await Message.create({
                    sender_id: senderId,
                    receiver_id: receiverId,
                    message: message,
                });
            } catch (err) {
                console.error('Error saving message:', err);
            }
        });
          

        socket.on('disconnect', () => {
            console.log(`User disconnected: ${socket.id}`);
        });
    });
};
  