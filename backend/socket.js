const Message = require('./models/messageModel');

module.exports = (io) => {
    io.on('connection', (socket) => {
        console.log(`User connected: ${socket.id}`);

        // Join chat room
        socket.on('joinRoom', ({ userId1, userId2 }) => {
            const roomName = [userId1, userId2].sort().join('-');
            socket.join(roomName);
            console.log(`Socket ${socket.id} joined room ${roomName}`);
        });

        // Send a message
        socket.on('sendMessage', async ({ senderId, receiverId, message }) => {
            const roomName = [senderId, receiverId].sort().join('-');

            const msgObj = {
                senderId,
                receiverId,
                message,
                timestamp: new Date().toISOString(),
            };

            // Emit to everyone in the room including sender
            io.to(roomName).emit('receiveMessage', msgObj);

            // Save message to DB
            try {
                await Message.create({
                    sender_id: senderId,
                    receiver_id: receiverId,
                    message,
                });
            } catch (err) {
                console.error('Error saving message:', err);
            }
        });

        // Typing indicator
        socket.on('typing', ({ senderId, receiverId }) => {
            const roomName = [senderId, receiverId].sort().join('-');
            socket.to(roomName).emit('userTyping', { senderId });
        });

        socket.on('disconnect', () => console.log(`User disconnected: ${socket.id}`));
    });
};
